export type ClaimState = {
  authenticated: boolean;
  role: unknown;
  providerStatus: unknown;
  bookingExists: boolean;
  bookingStatus: unknown;
  assignedProviderId: unknown;
};

export type ClaimFailure =
  | "unauthenticated"
  | "not-provider"
  | "provider-inactive"
  | "booking-not-found"
  | "booking-closed"
  | "already-claimed";

export function validateClaim(state: ClaimState): ClaimFailure | null {
  if (!state.authenticated) return "unauthenticated";
  if (state.role !== "provider") return "not-provider";
  if (state.providerStatus !== "active") return "provider-inactive";
  if (!state.bookingExists) return "booking-not-found";
  if (state.bookingStatus !== "pending") return "booking-closed";
  if (state.assignedProviderId != null) return "already-claimed";
  return null;
}
