import assert from "node:assert/strict";
import test from "node:test";

import {ClaimState, validateClaim} from "./claim_validation.js";

const validState: ClaimState = {
  authenticated: true,
  role: "provider",
  providerStatus: "active",
  bookingExists: true,
  bookingStatus: "pending",
  assignedProviderId: null,
};

test("an active provider can claim an open unassigned booking", () => {
  assert.equal(validateClaim(validState), null);
});

test("an already-assigned booking cannot be claimed again", () => {
  assert.equal(
    validateClaim({...validState, assignedProviderId: "provider-2"}),
    "already-claimed",
  );
});

test("inactive and non-provider accounts cannot claim work", () => {
  assert.equal(
    validateClaim({...validState, providerStatus: "pending"}),
    "provider-inactive",
  );
  assert.equal(
    validateClaim({...validState, role: "customer"}),
    "not-provider",
  );
});
