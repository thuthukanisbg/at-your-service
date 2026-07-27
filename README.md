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

- Onboarding, email/password authentication, phone verification UI, and role
  selection.
- Customer discovery, search, booking, real upcoming dates, service-address
  capture, booking confirmation, tracking states, reviews, messages,
  notifications, profile, and disputes.
- Provider job acceptance, navigation handoff, job progress, schedule,
  earnings, profile, verification, messages, and disputes.
- Mobile admin overview, bookings, providers, review workflow, and sign-out.
- Responsive desktop admin shell at 900 px and wider.

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

These items are deliberately not presented as working product functionality:

- Online payment processing is not integrated. The app now says **Confirm
  Booking** and explicitly tells the customer that no charge will occur.
- Desktop admin payments, discounts, and unaggregated chart sections remain
  clearly labelled design-preview data until backing collections exist.
- Google sign-in remains a next milestone.
- Provider before/after photo upload remains a next milestone.
- The moving-provider map is demo-only; real bookings show honest waiting and
  assigned states because no live-location backend exists.
- Notification records can be displayed but automatic booking-event triggers
  are not implemented.
- Unread-message badges are not shown because read receipts are not stored.

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

The editable product-flow reference is available in the project’s Figma file:
<https://www.figma.com/design/cmWvK32jt9vU6JMwqa7ex2>.
