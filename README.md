# At Your Service

At Your Service is a Flutter and Firebase marketplace for South African home
services. Customers can discover and book services, providers can accept and
manage work, and administrators can review platform activity.

## One codebase, two native design languages

The app does not maintain separate iOS and Android feature trees. Screens,
models, Firebase services, validation, and navigation destinations are shared.
Platform adaptation is concentrated in `lib/core`:

| Area | iOS | Android |
| --- | --- | --- |
| Primary navigation | `CupertinoTabBar` | Material 3 `NavigationBar` |
| Route motion | Cupertino push/pop | Material zoom transition |
| Detail headers | Centred title and Cupertino back control | Leading Material-style title and back control |
| Bottom sheets | Rounded Cupertino modal popup | Draggable Material 3 sheet |
| System chrome | Transparent iOS home-indicator region | Edge-to-edge status bar and themed navigation bar |
| Shapes and feedback | Tighter radii and no ink splash | Larger Material radii and ink feedback |
| Desktop preview | 42 px iPhone frame | 28 px Android frame |

Brand colours, Manrope typography, content hierarchy, business rules, and
Firebase data remain shared. Manrope is bundled with the application, so the
brand typography does not depend on a live Google Fonts request.

## Implemented flows

- Onboarding, email/password authentication, phone verification, Google
  customer authentication, and role selection.
- Customer discovery, search, booking, real upcoming dates, service-address
  capture, booking confirmation, tracking states, reviews, messages,
  notifications, profile, and disputes.
- Provider job acceptance, customer chat, travel, job start/completion,
  schedule, earnings, profile, verification, a dedicated message inbox, and
  disputes.
- Mobile admin overview, live booking monitoring with customer/provider names
  and lifecycle states, providers, review workflow, and sign-out.
- Responsive desktop admin shell at 900 px and wider.
- Desktop admin account provisioning for customers/providers, including
  password-setup emails, plus service-category creation and full-width
  responsive directory tables.
- Real-time booking chat with participant-only rules, customer/provider
  inboxes, read receipts, and unread navigation badges.
- Transactional Johannesburg Cloud Functions for single-winner job claims and
  ordered job-state transitions, plus a minimal REST health endpoint.
  Second-generation Cloud Functions provide managed request distribution and
  autoscaling.

## Running locally

```sh
flutter pub get
flutter run
```

Native support starts at Android 6.0 (API 23) and iOS 15.0, matching the
minimum versions required by the checked-in FlutterFire dependencies.

Quality checks:

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --debug --no-codesign
```

The `Mobile CI` workflow repeats those checks on GitHub-hosted Android and
iOS toolchains and publishes unsigned debug artifacts for both platforms on
pull requests.

## Native branding

The editable source app mark is
`assets/branding/app_icon.svg`. Generated iOS icon sizes and Android legacy
icons use that source. Android 8 and newer use the matching adaptive icon.
Both native launch screens use the dark brand surface to avoid a white flash
before Flutter renders.

## Production-readiness boundaries

These items are deliberately not presented as working product functionality.
The complete prerequisites and acceptance criteria are tracked in
[`docs/production-roadmap.md`](docs/production-roadmap.md).

- Online payment processing is not integrated. The app now says **Confirm
  Booking** and explicitly tells the customer that no charge will occur.
- Desktop admin payments, discounts, and unaggregated chart sections remain
  clearly labelled design-preview data until backing collections exist.
- Provider before/after photo upload remains a next milestone.
- The moving-provider map is demo-only; real bookings show honest waiting and
  assigned states because no live-location backend exists.
- In-app notification records are created for provider assignment, travel,
  work start, and completion, but push delivery is not implemented.

Before store submission:

1. Provision final Apple and Android application identifiers in Firebase, then
   replace the current Firebase-provisioned `com.example...` identifiers and
   regenerate both Firebase configuration files together.
2. Copy `android/key.properties.example` to the ignored
   `android/key.properties`, configure the upload keystore, and use that
   signing configuration for store artifacts. Until then, local release
   builds deliberately fall back to the debug key and are not distributable.
3. Configure the Apple signing team, distribution certificate, and App Store
   provisioning profile.
4. Add a real payment provider before restoring payment-method selection or
   payment language.

## Backend and scaling

The mobile/web clients use Firebase SDKs for ordinary authenticated data and
Firestore listeners for real-time chat and booking monitoring. Sensitive job
claiming and ordered lifecycle changes use the `claimJob` and
`updateJobStatus` callable functions in `africa-south1`. The same
second-generation runtime supplies managed load distribution and horizontal
autoscaling, so there is no standalone load-balancer server to operate at this
stage.

Backend checks:

```sh
cd functions
npm install
npm test
npm audit --omit=dev
```

The editable product-flow reference is available in the project’s Figma file:
<https://www.figma.com/design/cmWvK32jt9vU6JMwqa7ex2>.
