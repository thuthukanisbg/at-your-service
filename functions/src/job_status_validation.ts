export const providerJobStatuses = [
  "en_route",
  "in_progress",
  "completed",
] as const;

export type ProviderJobStatus = (typeof providerJobStatuses)[number];

export type StatusFailure =
  | "unauthenticated"
  | "not-provider"
  | "provider-inactive"
  | "booking-not-found"
  | "not-assigned"
  | "invalid-status"
  | "invalid-transition";

type StatusInput = {
  authenticated: boolean;
  requesterId?: string;
  role?: unknown;
  providerStatus?: unknown;
  bookingExists: boolean;
  assignedProviderId?: unknown;
  currentStatus?: unknown;
  targetStatus?: unknown;
};

export function validateStatusTransition(
  input: StatusInput,
): StatusFailure | null {
  if (!input.authenticated) return "unauthenticated";
  if (input.role !== "provider") return "not-provider";
  if (input.providerStatus !== "active") return "provider-inactive";
  if (!input.bookingExists) return "booking-not-found";
  if (
    typeof input.requesterId !== "string" ||
    input.assignedProviderId !== input.requesterId
  ) {
    return "not-assigned";
  }
  if (
    typeof input.targetStatus !== "string" ||
    !providerJobStatuses.includes(input.targetStatus as ProviderJobStatus)
  ) {
    return "invalid-status";
  }
  if (input.currentStatus === input.targetStatus) return null;

  const allowedPrevious: Record<ProviderJobStatus, string[]> = {
    // Historical assigned bookings may still be `pending`; accepting new
    // bookings now writes `accepted`.
    en_route: ["pending", "accepted"],
    in_progress: ["en_route"],
    completed: ["in_progress"],
  };
  return allowedPrevious[input.targetStatus as ProviderJobStatus].includes(
    String(input.currentStatus),
  )
    ? null
    : "invalid-transition";
}
