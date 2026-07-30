import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {setGlobalOptions} from "firebase-functions/v2";
import {HttpsError, onCall, onRequest} from "firebase-functions/v2/https";

import {ClaimFailure, validateClaim} from "./claim_validation.js";
import {
  ProviderJobStatus,
  StatusFailure,
  validateStatusTransition,
} from "./job_status_validation.js";

initializeApp();

setGlobalOptions({
  region: "africa-south1",
  memory: "256MiB",
  timeoutSeconds: 30,
  concurrency: 80,
  maxInstances: 20,
});

const db = getFirestore();

const claimErrors: Record<
  ClaimFailure,
  {code: "unauthenticated" | "permission-denied" | "not-found" | "failed-precondition" | "already-exists"; message: string}
> = {
  unauthenticated: {
    code: "unauthenticated",
    message: "Sign in before accepting a job.",
  },
  "not-provider": {
    code: "permission-denied",
    message: "Only provider accounts can accept jobs.",
  },
  "provider-inactive": {
    code: "permission-denied",
    message: "Your provider account must be active before accepting jobs.",
  },
  "booking-not-found": {
    code: "not-found",
    message: "This booking no longer exists.",
  },
  "booking-closed": {
    code: "failed-precondition",
    message: "This booking is no longer open.",
  },
  "already-claimed": {
    code: "already-exists",
    message: "This job was just claimed by another provider.",
  },
};

/// Atomically assigns an open booking to the authenticated active provider.
/// Callable functions carry Firebase Auth/App Check tokens automatically and
/// are the app-facing API for sensitive marketplace state transitions.
export const claimJob = onCall(async (request) => {
  const uid = request.auth?.uid;
  const bookingId =
    typeof request.data?.bookingId === "string"
      ? request.data.bookingId.trim()
      : "";
  if (!bookingId) {
    throw new HttpsError("invalid-argument", "A booking ID is required.");
  }

  const userRef = db.collection("users").doc(uid ?? "_unauthenticated");
  const providerRef = db.collection("providers").doc(uid ?? "_unauthenticated");
  const bookingRef = db.collection("bookings").doc(bookingId);

  await db.runTransaction(async (transaction) => {
    const [user, provider, booking] = await Promise.all([
      transaction.get(userRef),
      transaction.get(providerRef),
      transaction.get(bookingRef),
    ]);
    const bookingData = booking.data();
    const failure = validateClaim({
      authenticated: uid != null,
      role: user.data()?.role,
      providerStatus: provider.data()?.status,
      bookingExists: booking.exists,
      bookingStatus: bookingData?.status,
      assignedProviderId: bookingData?.providerId,
    });
    if (failure != null) {
      const error = claimErrors[failure];
      throw new HttpsError(error.code, error.message);
    }

    transaction.update(bookingRef, {
      providerId: uid,
      status: "accepted",
      acceptedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const customerId = bookingData?.customerId;
    if (typeof customerId === "string" && customerId.length > 0) {
      transaction.create(db.collection("notifications").doc(), {
        userId: customerId,
        bookingId,
        type: "provider_assigned",
        title: "Provider assigned",
        body: "A provider accepted your service request.",
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  });

  return {bookingId, providerId: uid};
});

const statusErrors: Record<
  StatusFailure,
  {
    code:
      | "unauthenticated"
      | "permission-denied"
      | "not-found"
      | "invalid-argument"
      | "failed-precondition";
    message: string;
  }
> = {
  unauthenticated: {
    code: "unauthenticated",
    message: "Sign in before updating a job.",
  },
  "not-provider": {
    code: "permission-denied",
    message: "Only provider accounts can update jobs.",
  },
  "provider-inactive": {
    code: "permission-denied",
    message: "Your provider account must be active before updating jobs.",
  },
  "booking-not-found": {
    code: "not-found",
    message: "This booking no longer exists.",
  },
  "not-assigned": {
    code: "permission-denied",
    message: "This job is not assigned to your provider account.",
  },
  "invalid-status": {
    code: "invalid-argument",
    message: "That job status is not supported.",
  },
  "invalid-transition": {
    code: "failed-precondition",
    message: "Complete the previous job stage first.",
  },
};

const statusMetadata: Record<
  ProviderJobStatus,
  {
    timestampField: "enRouteAt" | "startedAt" | "completedAt";
    notificationType: string;
    title: string;
    body: string;
  }
> = {
  en_route: {
    timestampField: "enRouteAt",
    notificationType: "provider_en_route",
    title: "Provider on the way",
    body: "Your provider has started travelling to your service address.",
  },
  in_progress: {
    timestampField: "startedAt",
    notificationType: "job_started",
    title: "Service started",
    body: "Your provider has arrived and started the job.",
  },
  completed: {
    timestampField: "completedAt",
    notificationType: "job_completed",
    title: "Service completed",
    body: "Your provider marked the job complete. You can now rate the service.",
  },
};

/// Advances an assigned provider's job through accepted -> en_route ->
/// in_progress -> completed. Every transition is checked and written in a
/// transaction so the customer and admin always observe the same state.
export const updateJobStatus = onCall(async (request) => {
  const uid = request.auth?.uid;
  const bookingId =
    typeof request.data?.bookingId === "string"
      ? request.data.bookingId.trim()
      : "";
  const targetStatus =
    typeof request.data?.status === "string" ? request.data.status.trim() : "";
  if (!bookingId) {
    throw new HttpsError("invalid-argument", "A booking ID is required.");
  }

  const userRef = db.collection("users").doc(uid ?? "_unauthenticated");
  const providerRef = db.collection("providers").doc(uid ?? "_unauthenticated");
  const bookingRef = db.collection("bookings").doc(bookingId);

  await db.runTransaction(async (transaction) => {
    const [user, provider, booking] = await Promise.all([
      transaction.get(userRef),
      transaction.get(providerRef),
      transaction.get(bookingRef),
    ]);
    const bookingData = booking.data();
    const failure = validateStatusTransition({
      authenticated: uid != null,
      requesterId: uid,
      role: user.data()?.role,
      providerStatus: provider.data()?.status,
      bookingExists: booking.exists,
      assignedProviderId: bookingData?.providerId,
      currentStatus: bookingData?.status,
      targetStatus,
    });
    if (failure != null) {
      const error = statusErrors[failure];
      throw new HttpsError(error.code, error.message);
    }

    if (bookingData?.status === targetStatus) return;
    const metadata = statusMetadata[targetStatus as ProviderJobStatus];
    transaction.update(bookingRef, {
      status: targetStatus,
      [metadata.timestampField]: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const customerId = bookingData?.customerId;
    if (typeof customerId === "string" && customerId.length > 0) {
      transaction.create(db.collection("notifications").doc(), {
        userId: customerId,
        bookingId,
        type: metadata.notificationType,
        title: metadata.title,
        body: metadata.body,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  });

  return {bookingId, status: targetStatus};
});

/// Small operational REST endpoint for uptime checks. Product mutations use
/// authenticated callable functions; this endpoint intentionally exposes no
/// customer or marketplace data.
export const api = onRequest((request, response) => {
  if (request.method === "GET" && request.path === "/v1/health") {
    response.status(200).json({
      status: "ok",
      service: "at-your-service-api",
      region: "africa-south1",
    });
    return;
  }
  response.status(404).json({error: "not_found"});
});
