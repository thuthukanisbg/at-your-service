# At Your Service

## Project Context

This is a Flutter rebuild of the **At Your Service** home services marketplace.

The previous local project folder was lost from:

`/Users/thuthukaninxumalo/Downloads/at_your_service_mvp1_flutter`

We are rebuilding inside:

`/Users/thuthukaninxumalo/Documents/Codex/2026-05-21/home-services`

## Product Direction

At Your Service is a South African home services marketplace for customers, service providers, and administrators.

The app should feel premium, trustworthy, practical, and investor-ready. It should avoid a generic dashboard look. The target quality bar is closer to modern consumer marketplace and banking apps: clear flows, strong spacing, polished cards, useful icons, and concise wording.

Currency should use South African Rand: `R`.

### Visual design reference

There were two design references in this project's history. **The second
supersedes the first — use it as the source of truth:**

1. ~~A screenshot mockup (2026-06-19) with a navy/gold-then-blue palette~~ —
   superseded by #2 below. The structural lesson from it still stands (see
   below), but its exact colors/typography do not.
2. **`/Users/thuthukaninxumalo/Downloads/design_handoff_at_your_service/`**
   (2026-06-19/20) — a proprietary-format interactive HTML prototype
   (`At Your Service.dc.html`) plus `README.md` with the full design-token
   spec, covering ~28 screens across all three roles. **This is the
   authoritative spec.** Read the README's Design Tokens section and search
   the HTML for `<!-- ===== ROLE · SCREEN ===== -->` comment banners before
   building any new screen — copy exact copy, spacing, and data shapes from
   there rather than improvising. The HTML/JS itself is a reference, not
   code to lift directly (see the README's "About the Design Files").

Structural lesson that carried over from #1 and still applies: **it must
read as a mobile app, not a responsive website.** A persistent bottom
navigation bar per role, and (when running in a browser during development)
content constrained to a phone-width column rather than stretched
edge-to-edge. See `lib/core/widgets/mobile_frame.dart` and
`lib/core/widgets/role_nav_shell.dart`.

Current design tokens (from the handoff, see `lib/core/theme/`):
- **Fixed accents** (same light & dark) — `AppColors`: primary blue
  `#2E7DFF`, amber `#FFC107` (brand mark + "do the thing now" CTAs: Book
  Now, Accept — see `AppTheme.amberAction`), success green `#2ECC71`,
  danger `#FF4D67`, purple `#9B59B6` (Painting category).
- **Theme-variant surface/text tokens** — `AppTokens`
  (`lib/core/theme/app_tokens.dart`, a `ThemeExtension`), named to match the
  handoff's own `--bg/--surface/--card/--elev/--line/--tx/--mut/--chip`
  vocabulary. Look these up via `context.tokens` (see the
  `AppTokensContext` extension) rather than hardcoding colors — that's what
  makes light/dark both work from one widget tree.
- **The app ships dark-by-default** (`ThemeMode.dark` in `app.dart`); light
  theme exists (`AppTheme.light()`) but there's no in-app toggle yet.
- **Typography:** Manrope via `google_fonts` (`GoogleFonts.manropeTextTheme`
  in `AppTheme._build`). Note: `google_fonts` fetches/caches at runtime by
  default — fine for this stage, revisit (bundle as assets) before a
  no-network-on-first-launch production release.
- **Icons:** Lucide via the `lucide_icons` pub package, not Material icons,
  for any new screen work — matches the handoff exactly. Note this package
  version doesn't have every modern Lucide name; confirmed substitutions:
  `house`→`LucideIcons.home`, `paint-roller`→`LucideIcons.paintbrush2`,
  `user-round`→`LucideIcons.user`, `ellipsis`→`LucideIcons.moreHorizontal`,
  `circle-check`→`LucideIcons.checkCircle2`. Check
  `~/.pub-cache/hosted/pub.dev/lucide_icons-*/lib/lucide_icons.dart` if a
  name from the spec doesn't resolve.
- Bottom nav tabs beyond the first (Home/Jobs/Overview) are intentionally
  `ComingSoonTab` placeholders until their milestone lands — that's the
  agreed scope, not an oversight.

## Core User Roles

- Customer: browses services, books jobs, tracks bookings, reviews job details.
- Provider: applies to join, waits for approval, manages profile, accepts jobs, updates job status.
- Admin: reviews provider applications, manages service categories and services, tracks bookings and marketplace health.

## Initial Rebuild Milestones

1. Recreate the Flutter app structure cleanly.
2. Build high-quality mock/local flows before reconnecting Firebase.
3. Add role selection and role-based navigation.
4. Implement customer marketplace screens.
5. Implement provider onboarding and jobs.
6. Implement admin approval and service management.
7. Reconnect Firebase Auth and Firestore after the local flows are stable.
8. Add QA tests for role flow and marketplace booking flow.

## Important Constraints

- Keep changes scoped and readable.
- Prefer Flutter Material 3 and native Flutter widgets unless a package clearly earns its place.
- Do not add Firebase back until the local UX and navigation structure are stable.
- Avoid hardcoding future production secrets or credentials.
- Run `flutter analyze` after meaningful code changes.
- Update tests when visible flow behavior changes.

## Collaboration Notes

Codex and Claude Code may both work in this project. Before changing files:

- Read the current directory structure.
- Check `git status` if this project has been initialized as a git repo.
- Do not overwrite user or other-agent work blindly.
- If proposing design changes, preserve the app's role flow: customer, provider, admin.

## Current State

Milestones 1-4 are functionally done for all three roles' primary flows,
rebuilt against the handoff role by role:
- **Customer** (milestone 4): home → service → book → pay → track → rate,
  all built.
- **Provider** (milestone 5): jobs → job details → navigate → in progress →
  schedule → earnings → profile, all built, replacing the pre-handoff
  `ProviderHomeScreen`.
- **Admin** (milestone 6): dashboard → provider review, built, replacing
  the pre-handoff `AdminHomeScreen`.
- **Verify** — a 7-step provider KYC stepper. Not in the original milestone
  list (found in the handoff after Provider/Admin were scoped); entered
  from Provider Profile's "View verification flow".

A design-token **tightening pass** ran across `AppTheme`/`AppTokens`/
`AppColors` and all built screens partway through this work (see "Design
tightening pass" below) — triggered by feedback that the app looked "a bit
chubby" next to the handoff. It found and fixed a real, high-impact bug
(`MobileFrame` was 430px wide instead of the handoff's exact 392px), which
in turn exposed several pre-existing overflow bugs that the too-wide frame
had been masking.

**Splash/Onboarding/Auth** (the real entry flow ahead of `RoleSelectScreen`)
is now built too — see `lib/features/onboarding/` below. Firebase
reconnaissance (no SDK code yet) has also been done — see "Firebase
reconnaissance" below.

Still open: Customer's Messages/Chat/Profile/Saved Addresses
(`cust_msgs`/`cust_chat`/`cust_profile`/`cust_address`); Admin's
Bookings/Providers/More tabs beyond Dashboard — all still `ComingSoonTab`
placeholders, no spec was pulled for them yet. Then the rest of the
Firebase reconnect (adding `firebase_auth`/`cloud_firestore` and replacing
mock data with real reads/writes — `flutterfire configure` and
`firebase_core` are already done, see "Next up" at the bottom).

- `lib/core/` — theme (`AppColors` fixed accents, `AppTheme` light/dark
  builder + `AppTheme.amberAction`, `AppTokens` theme-variant surface/text
  tokens — see Visual design reference above), currency formatting, and
  shared widgets (`AppCard`, `SectionHeader`, `StatusChip`, `StatTile`,
  `MobileFrame`, `RoleNavShell`/`NavTab` (with `showBadge`), `ComingSoonTab`).
- `lib/models/` — `UserRole`, `ServiceCategory` (now carries `tint` +
  `price` + `chipBg`), `ServiceListing` (`providerName` is nullable — null
  means "verified pros" generally, not one named provider), `Booking`,
  `ProviderJob`, `AdminApplicant` (plain Dart, no backend coupling).
  `JobRequest`/`ProviderApplication` were deleted once the Provider/Admin
  rebuilds made them unused — don't recreate them without checking they're
  actually still needed first.
- `lib/features/onboarding/` — the real entry flow, now ahead of
  `RoleSelectScreen`: `SplashScreen` (`app.dart`'s `initialRoute`; amber
  house-mark logo with the handoff's `floaty` bob animation, diagonal navy
  gradient background, "Get Started" / "I already have an account") →
  `OnboardingScreen` (3-slide carousel, local `_step` state, "Skip" or
  "Next"/"Get Started" on the last slide) → `AuthScreen` (Sign In/Sign Up
  segmented toggle, local `_signIn` state; the field list swaps per mode —
  2 fields for sign in, 3 for sign up). All three transitions use
  `Navigator.pushReplacement`, not `push` — `SplashScreen`'s logo animation
  repeats forever, so leaving it `push`ed (and thus still mounted, ticking,
  underneath every later screen) would be the same
  `tester.pumpAndSettle()`-hangs-forever hazard as `TrackBookingScreen`'s
  pulsing dot (see the gotchas list below), except permanent instead of
  scoped to one screen — `pushReplacement` actually disposes it once you
  move on, which is also the correct UX (no reason "back" from the role
  chooser should walk you backwards through auth). Per the handoff's own
  click-through prototype, Auth's fields are static display (no real
  `TextField`s — the prototype's own fields have no `onClick` either) and
  every exit point (CTA, Google, Phone) goes to the same place:
  `RoleSelectScreen`, now reached at `/chooser` instead of `/`.
- `lib/features/role_select/` — `RoleSelectScreen` (the handoff's
  "chooser"), rebuilt pixel-accurate to the handoff: amber house-mark logo,
  "I need a service / Customer / ..." card hierarchy (action phrase is the
  bold title, role name is the colored tag below it — not the other way
  round), trust badge row.
- `lib/features/customer/` — `CustomerShell` (bottom nav: Home,
  Bookings\*, Messages\* with red badge dot, Profile\*) wrapping
  `CustomerHomeScreen`, rebuilt pixel-accurate to the handoff's `cust_home`:
  location pill, greeting, search bar + filter button (both tap targets,
  not yet wired to real search/filter — show a "coming soon" snackbar,
  matching the prototype where these aren't interactive either), 4-up
  category grid (Cleaning/Plumbing/Electrical/Painting, exact handoff
  data), gradient promo card (whole card is one tap target, not just the
  "Book Now" pill — matches the prototype's `onClick` placement), single
  Recommended listing card. Category tap, promo tap, and recommended-card
  tap all push `ServiceDetailsScreen`, which chains forward through the
  rest of the booking flow: `BookScheduleScreen` (date/time selection,
  local `setState`) → `ReviewPayScreen` (receives the chosen date/time via
  constructor params; payment-method selection is local `setState`) →
  `TrackBookingScreen` (booking-status timeline, live-map placeholder with
  a diagonal-stripe `CustomPainter`, pulsing "on the way" dot) →
  `RateReviewScreen` (star rating + toggleable quick-tag chips, both local
  `setState`). "Submit Review" does
  `Navigator.popUntil((route) => route.isFirst)` to drop the whole pushed
  stack and land back on the Home tab — matches the handoff's `submitReview
  → cust_home` behavior. Two shared widgets back this flow:
  `lib/core/widgets/detail_screen_header.dart` (the back-chevron + title row
  repeated on every pushed screen) and `primary_cta_button.dart` (the
  54px-tall CTA with the handoff's colored glow shadow, which
  `ElevatedButton.elevation` can't produce on its own — see
  `AppColors.heroGradient*` for the same trick applied to the hero
  gradient's ~120° angle).
- `lib/features/provider/` — `ProviderShell` (bottom nav: Jobs, Schedule,
  Earnings, Profile — all four now real screens). `ProviderJobsScreen`
  (Available/Accepted segmented toggle — visual only, matches the handoff's
  own lack of an `onClick` there) → tapping a job card pushes
  `ProviderJobDetailsScreen(job)` (payout is computed live as 90% of *that*
  job's price, not hardcoded, since the handoff's one example — R600 job →
  R540 payout — only makes sense as a 10%-fee rule) → "Accept Job" pushes
  `ProviderNavigateScreen` (reuses the customer flow's
  `DiagonalStripesPainter`, extracted to `core/widgets/` since both screens
  needed it with different stripe widths) → "Start Navigation" pushes
  `ProviderInProgressScreen` (checkable task list, local `setState`;
  "Complete Job" does `popUntil(isFirst)`, landing on whichever tab was
  active rather than force-switching to Profile like the handoff's
  `goProvProfile` — same simplification as the customer flow, to avoid
  adding tab-index-control to `RoleNavShell` for one edge case).
  `ProviderScheduleScreen`/`ProviderEarningsScreen` are static per the
  handoff (no interactive elements specified). `ProviderProfileScreen`'s
  "View verification flow" pushes `VerifyScreen` — a 7-step KYC stepper
  (`_verifyStep` local state, defaults to 4 matching the handoff's demo
  state) with a gradient progress bar and a completed/celebration state
  once all 7 steps are done.
- `lib/features/admin/` — `AdminShell` (bottom nav: Overview real;
  Bookings/Providers/More still `ComingSoonTab`, no spec pulled for those).
  `AdminDashboardScreen` (stats grid, 7-bar revenue chart, pending-approvals
  list) → tapping an applicant pushes `AdminReviewScreen(applicant)`, which
  pops `true`/`false`/`null` for approve/reject/back-without-deciding;
  Dashboard awaits the result and removes the applicant from its local
  pending list on a decision — genuinely working Approve/Reject, not the
  handoff's literal click-through-only buttons (both `onClick`s just call
  `goAdminDash` in the source with no state change), restoring the
  pre-handoff `AdminHomeScreen`'s equivalent working behavior onto the new
  visual design. Applicant details/verification-checklist content is fixed
  generic mock data reused across all applicants (the handoff's one review
  example has no per-applicant variation there either) — only the tapped
  applicant's own name/role/avatar are genuinely per-applicant.

  (\* = `ComingSoonTab` placeholder — intentional, see design reference above.)

State management is plain `StatefulWidget`/`setState` (or plain
`StatelessWidget` for screens with no interaction yet, e.g.
`CustomerHomeScreen`) — no state management package added. New pub deps:
`lucide_icons`, `google_fonts` (both justified by the handoff's explicit
icon/typography spec — see Visual design reference above).

Verified with:

```sh
/Users/thuthukaninxumalo/development/flutter/bin/flutter analyze
/Users/thuthukaninxumalo/development/flutter/bin/flutter test
```

Both pass — 31 tests total: `test/widget_test.dart` (role navigation),
`test/mobile_frame_test.dart` (frame width, see below),
`test/onboarding_flow_test.dart` (Splash/Onboarding/Auth's own internal
behavior — slide advancement, Skip, Sign In/Sign Up field swap),
`test/customer_booking_flow_test.dart`, `test/provider_flow_test.dart`,
`test/admin_flow_test.dart`, `test/verify_flow_test.dart` (one file per
role flow, each walking its full screen-to-screen chain, not just smoke
tests). Since the entry flow is now Splash → Onboarding → Auth →
`RoleSelectScreen` rather than `RoleSelectScreen` being the app's initial
route, every test file that used to pump `AtYourServiceApp` and tap a role
card directly now has to walk through the entry flow first via a shared
`_skipToChooser` helper (duplicated per file, matching this codebase's
existing per-file `_harness` convention rather than a shared test-utils
file) — see the `pushReplacement`/pump-timing gotcha below. None of this
was manually screenshotted in-browser in the sessions that built it
(computer-use/screen access was unavailable throughout) — fidelity was
instead verified by direct line-by-line comparison against the handoff's
literal HTML/CSS, not the README's paraphrased descriptions, which
occasionally drift from the literal markup (e.g. the README's "What's
included" checklist has no such heading in the actual `cust_service`
markup — the screen correctly omits it). Screenshot-verify the whole app
in-browser before calling any of this final — an earlier session did
screenshot the pre-fidelity-fix versions of
`RoleSelectScreen`/`CustomerHomeScreen` only, nothing since.

### Design tightening pass ("chubby" feedback)
User feedback that the app looked "a bit chubby" next to the handoff led to
two rounds of investigation:

**Round 1 — theme/token precision.** Colors and `AppTokens` were already
exact; the real drift was in `AppTheme`'s typography (`titleLarge`'s
letter-spacing was -0.3, handoff has zero instances of any heading using
anything less negative than -0.4; `labelLarge`/`labelMedium` had a spurious
`+0.1` letter-spacing with no basis anywhere in the source — confirmed via
a full-file grep of every literal `letter-spacing:` value, all seven of
which are negative) and in a few widgets: `AppCard`'s `InkWell` used radius
20 against `cardTheme`'s 18, and — the highest-impact one — `RoleNavShell`
used Material 3's `NavigationBar`, which always reserves layout space for
a pill-shaped selection indicator even with `indicatorColor:
Colors.transparent`. Rebuilt it as a custom flat bar matching the
handoff's literal `padding: 12/9/12/24` + 1px top border exactly.

**Round 2 — `MobileFrame` was the real culprit.** User measured the actual
prototype's DOM at exactly 392×812 and the running build at ~430px wide —
`MobileFrame._phoneWidth` was hardcoded to 430 instead of the handoff's
392. Fixed to exactly 392, verified empirically (not just trusting the
constant) with `test/mobile_frame_test.dart`, which measures the actual
rendered child width via `tester.getSize()`, not the `SizedBox`'s declared
property. **This surfaced several real, pre-existing `RenderFlex` overflow
bugs** the too-wide frame had been silently masking (`ServiceDetailsScreen`
rating row, `ReviewPayScreen` summary row, `ProviderJobsScreen` time/dist
row) — all the same unbounded-Row pattern below, fixed with
`Flexible`/`Expanded`. Also revealed that the customer-flow test harness
wasn't wrapping screens in `MobileFrame` at all, so those "isolated screen"
tests had been silently running at the full ~800px test-viewport width the
whole time — fixed by wrapping the harness in `MobileFrame`, which is what
actually caught the `ReviewPayScreen` bug. **If you add a new screen and
wrap it in a test harness, always include `MobileFrame`** — otherwise the
test proves nothing about the width the app actually renders at.

### Fidelity fixes worth knowing about
A design-fidelity pass (comparing built screens line-by-line against the
handoff's literal CSS, not just "has the right elements") found and fixed
several small drifts in the already-built `RoleSelectScreen`/
`CustomerHomeScreen` — worth knowing about since they're easy to
reintroduce by copy-pasting older patterns:
- `formatRand()` used to insert a space after `R` (`"R 600"`). The handoff
  **never** spaces it (`R600`, `R1,200`, `R24.5k`) — fixed globally, so any
  new screen using `formatRand` gets this for free.
- Colored "glow" shadows (primary buttons, hero/promo cards) need
  `spreadRadius` (often negative) to match the CSS `box-shadow`'s spread
  value, not just `blurRadius`/`offset` — easy to drop by accident.
- Per-category chip backgrounds in the handoff use *different* alpha values
  per category (0.14 vs 0.16), not one uniform tint alpha — see
  `ServiceCategory.chipBg` vs `.tint`.
- Lucide (this pub version) has no filled/solid star glyph, only outline —
  so anywhere the handoff shows a filled amber star (ratings, the Rate &
  Review stars) is an accepted, unavoidable fidelity gap, not a bug to keep
  chasing.

Gotchas hit and fixed (still apply going forward):
- A `Text` placed directly in a `Row` (without `Expanded`/`Flexible`) gets
  *unbounded* width during layout and can overflow even when the visible
  space looks plenty wide — wrap header/title text in `Expanded`/`Flexible`
  with `overflow: TextOverflow.ellipsis`. Hit this repeatedly (search bar,
  section headers, location pill) — check every new `Row` containing a
  `Text` sibling.
- Avoid `Spacer()`-based vertical centering in a plain `Column`; on short
  viewports (small phones, or the default ~600px-tall widget-test surface)
  it overflows instead of shrinking — use a scrollable `Column` with fixed
  gaps, or a `ConstrainedBox(minHeight:)` + `SingleChildScrollView` pattern
  instead (see `RoleSelectScreen`).
- When changing anything in `AppColors`/`AppTokens`, run `flutter analyze`
  immediately — every screen referencing an old field name fails loudly
  and the fix list is mechanical but easy to miss one of.
- In widget tests, a `ListView` taller than the test surface (default
  ~600px) only builds children within the viewport/cache extent — `find`
  returns *zero* matches for anything scrolled past the fold, not a
  found-but-unreachable widget. Use `tester.scrollUntilVisible(...,
  scrollable: find.byType(Scrollable))`, not `tester.ensureVisible()` —
  `ensureVisible` assumes the target is already built and just needs
  scrolling into the viewport, so it throws `Bad state: No element` on
  anything the `ListView` hasn't built yet. `scrollUntilVisible` scrolls
  and re-checks incrementally, which handles both cases. Hit this on
  several screens across every role's test file.
- `BoxDecoration` cannot combine a non-uniform `Border` (different width
  per side — e.g. a 3px colored "accent strip" on one edge, 1px elsewhere)
  with a `borderRadius`; Flutter throws at paint time, CSS just silently
  allows it. Split into a separate accent-colored strip `Container` next to
  a normally-bordered, normally-rounded card instead (see
  `ProviderScheduleScreen._ScheduleRow`'s appointment cards).
- Any `AnimationController..repeat()` (used for the handoff's `pulseDot`
  pulsing-dot effect — see `TrackBookingScreen._PulsingOpacity`) never
  settles, so `tester.pumpAndSettle()` hangs for the rest of the test once
  that screen is mounted — including screens pushed on top of it, since a
  covered-but-not-popped route keeps its `State`/tickers alive. Use
  `tester.pump()` (optionally with a fixed `Duration`) instead, for as long
  as that screen stays in the Navigator stack.
- `Navigator.push`ed routes stay mounted (default `maintainState: true`)
  even when fully covered by a later push, so `find.text('Continue')` can
  match more than one widget once you're several screens deep in a pushed
  flow — either use unique-per-screen text for assertions, or scope/`.last`
  the finder. Isolating each screen in its own test (pump just that screen
  under a plain `MaterialApp`, rather than threading through the whole
  pushed stack) sidesteps this entirely and was the approach used in
  `test/customer_booking_flow_test.dart`.
- Driving a `pushReplacement` transition in a widget test with a single
  large `tester.pump(duration)` call is not reliable even when `duration`
  comfortably exceeds the transition's length — the animation's completion
  callbacks (which actually remove the old route from the tree) don't
  always get a chance to run in one jump. Use two smaller sequential
  `pump()` calls instead (e.g. `pump(300ms)` twice rather than
  `pump(600ms)` once) — hit this building the Splash → Auth →
  `RoleSelectScreen` entry flow's test helper, where the symptom was
  `find`ers for the destination screen's content returning zero matches,
  and later, `scrollUntilVisible` throwing `Bad state: Too many elements`
  because the outgoing route was still faintly present.

Next up: the rest of the Firebase reconnect (milestone 7). Already done:
reconnaissance (Firestore collection/document schema mapped from the
current mock models, a first-draft security-rules file, and a per-screen
audit of which loading/error/empty states are needed once async calls
exist — discussed in-session, not committed as files), and the actual
`flutterfire configure` against the pre-existing Firebase project
**`at-your-service-1cb5a`** ("At your Service", under
thuthukanisbg@gmail.com — found via `firebase projects:list`; the CLIs
were installed for this: `firebase-tools` via npm into `~/.npm-global`
(the default global prefix wasn't user-writable; PATH updated in
`~/.zshrc`), `flutterfire_cli` via `dart pub global activate`, plus the
`xcodeproj` Ruby gem (`gem install --user-install`) which flutterfire's
iOS step silently requires — it fails with a raw Ruby LoadError without
it). That generated `lib/firebase_options.dart`, `firebase.json`,
`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
and the google-services Gradle wiring. (These config files are committed
deliberately: Firebase client config is app identifiers, not secrets —
access control lives in security rules.) Since then the foundation has
also landed: `firebase_core`/`firebase_auth`/`cloud_firestore` are all in
pubspec, `main.dart` calls `Firebase.initializeApp` (in `main()`, NOT in
`AtYourServiceApp` — deliberately, so widget tests that pump the app
widget directly never need a live Firebase connection), and
`firestore.rules` (the role-based draft from the recon: users/
serviceCategories/services/bookings/reviews) is written and **deployed**
to the project (`firebase deploy --only firestore:rules`; `firebase.json`
has the firestore section, `.firebaserc` pins the default project so
`--project` isn't needed). Verified: analyze/tests green and the web app
boots against the live project with initializeApp succeeding. Known
rules TODO: the provider job-claim path is a plain rule check, not a
transaction — racing providers must be handled by a Cloud Function/
transaction before real traffic. Remaining: wire `AuthScreen` to real
sign-in/sign-up, replace mock data with real reads/writes (per-screen
loading/error/empty states from the recon audit). The remaining un-built
screens across all three roles (Customer's Messages/Chat/Profile/Saved
Addresses, Admin's Bookings/Providers/More) are lower priority — they're
`ComingSoonTab` placeholders and not on any role's critical path (booking,
job-completion, or provider-review respectively).
