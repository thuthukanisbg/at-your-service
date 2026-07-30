import assert from "node:assert/strict";
import test from "node:test";

import {validateStatusTransition} from "./job_status_validation.js";

const valid = {
  authenticated: true,
  requesterId: "provider-1",
  role: "provider",
  providerStatus: "active",
  bookingExists: true,
  assignedProviderId: "provider-1",
};

test("allows the ordered provider lifecycle", () => {
  assert.equal(
    validateStatusTransition({
      ...valid,
      currentStatus: "accepted",
      targetStatus: "en_route",
    }),
    null,
  );
  assert.equal(
    validateStatusTransition({
      ...valid,
      currentStatus: "en_route",
      targetStatus: "in_progress",
    }),
    null,
  );
  assert.equal(
    validateStatusTransition({
      ...valid,
      currentStatus: "in_progress",
      targetStatus: "completed",
    }),
    null,
  );
});

test("allows legacy assigned pending bookings to start travel", () => {
  assert.equal(
    validateStatusTransition({
      ...valid,
      currentStatus: "pending",
      targetStatus: "en_route",
    }),
    null,
  );
});

test("rejects skipped stages and a different provider", () => {
  assert.equal(
    validateStatusTransition({
      ...valid,
      currentStatus: "accepted",
      targetStatus: "completed",
    }),
    "invalid-transition",
  );
  assert.equal(
    validateStatusTransition({
      ...valid,
      assignedProviderId: "provider-2",
      currentStatus: "accepted",
      targetStatus: "en_route",
    }),
    "not-assigned",
  );
});
