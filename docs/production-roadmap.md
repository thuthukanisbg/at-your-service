# Production roadmap

This list distinguishes product work from external setup. A feature is not
called complete until its code, Firebase/provider configuration, security
rules, and Android/iOS verification all pass.

## In this development branch

- Google authentication code for web, Android, and iOS. New Google accounts
  become customers; existing roles are preserved.
- Customer and provider conversation inboxes.
- Conversation read receipts and real unread badges.
- Booking chat restricted to the assigned customer/provider pair after job
  assignment, with immutable messages and a 2,000-character limit.
- Transactional provider job claiming in a second-generation Cloud Function.
- Automatic in-app notification record when a provider accepts a booking.
- Johannesburg backend region (`africa-south1`) with concurrency 80 and a
  20-instance cost guardrail. Google manages request distribution and
  autoscaling for this runtime.
- Operational `GET /v1/health` REST endpoint. App mutations use Firebase
  callable functions so authentication tokens are validated automatically.

## External configuration required

### Google sign-in

- Choose the public support email shown on the Google consent screen.
- Enable Google in Firebase Authentication.
- Replace the temporary `com.example...` Android/iOS identifiers with the
  final store identifiers.
- Register Android debug, upload, and Play App Signing SHA-1/SHA-256
  fingerprints.
- Download regenerated `google-services.json` and
  `GoogleService-Info.plist`; the iOS file must contain its client ID and
  reversed-client-ID URL scheme.
- Verify one new and one returning customer on web, Android, and iOS.

### Store and device credentials

- Android upload keystore and Play App Signing configuration.
- Apple development/distribution team and provisioning profiles.
- APNs authentication key uploaded to Firebase before iOS push delivery.
- App Check providers for Android, iOS, web, Firestore, and callable
  functions.

## Next implementation milestones

### 1. Push notifications

Add Firebase Cloud Messaging token registration, per-device token cleanup,
foreground/background handlers, and backend events for booking accepted,
provider en route, work started/completed, disputes, and new messages.

Acceptance: notification permission is requested at an appropriate moment;
tap-through opens the correct booking/conversation; stale tokens are removed;
no message body is leaked on a locked device unless the user allows previews.

### 2. Provider evidence photos

Add camera/gallery capture, compression, Firebase Storage paths scoped to the
assigned provider and booking, upload progress/retry, before/after labels, and
admin/customer review.

Acceptance: only the assigned provider can upload; only booking participants
and admins can read; metadata is stored atomically enough that abandoned files
can be cleaned up.

### 3. Payments and payouts

Select a South African payment provider and complete merchant onboarding
before writing the integration. Use backend-created payment intents, signed
webhook verification, idempotency keys, refunds, provider payout ledger, and
reconciliation. Never put secret payment keys in Flutter.

Acceptance: sandbox success/failure/refund flows pass; repeated webhooks do not
double-charge or double-credit; admin finance screens use the real ledger.

### 4. Live location, navigation, and calling

Provider location sharing needs explicit consent, foreground/background
permission behavior, update throttling, retention limits, and automatic stop
conditions. Customer calling needs a privacy decision: direct phone numbers,
masked calling, or in-app voice.

Acceptance: tracking stops when the job ends, users can revoke consent, stale
locations are visibly marked, and private numbers are not exposed unless the
product policy explicitly allows it.

### 5. Chat completion

Add push delivery, typing indicators, presence with an honest last-seen model,
attachments, moderation/reporting, pagination, and retention controls.
Firestore listeners remain the real-time transport; a custom WebSocket fleet
is not required unless future requirements outgrow Firestore.

### 6. Marketplace and admin data completion

Replace the remaining demo revenue/discount/payment panels, review aggregates,
city list, provider live-location map, and static schedule/earnings sections
with backed collections and trusted calculations.

## API and load-balancing direction

Keep ordinary participant-scoped reads on Firebase SDKs. Put payments, job
claiming, notification fan-out, admin audit logging, and future partner
operations behind trusted functions.

Cloud Functions second generation is already backed by Cloud Run and managed
request distribution. Add an explicit external HTTPS load balancer/API Gateway
only when we need a custom domain, partner API keys/quotas, multi-region
failover, WAF policy, or non-Firebase clients. Adding one before those
requirements would create cost and operational work without improving the
current app.
