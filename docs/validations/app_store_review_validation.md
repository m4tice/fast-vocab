# fastVocab App Store Review Validation Plan

Status: Release-readiness baseline  
Last reviewed: 2026-07-26  
Applies to: fastVocab iOS and iPadOS 1.0  
Bundle ID: `com.brightwater.fast-vocab`

## 1. Purpose

This document defines the goals, mandatory targets, evidence, and release gate for submitting fastVocab to Apple App Review. It supplements the product requirements; it does not change lesson behavior.

Apple's policies and App Store Connect requirements change over time. The release owner must recheck the official sources in section 12 immediately before every submission. Passing this internal gate reduces rejection risk but does not guarantee Apple approval.

## 2. Review Goals

The submitted build must demonstrate that fastVocab is:

1. **Complete:** all advertised vocabulary lessons and navigation paths work without placeholders, crashes, blocked controls, or external setup.
2. **Useful and app-like:** the native lesson, review, recovery, and progress experience provides adequate educational utility rather than acting as a content wrapper.
3. **Offline-first:** a reviewer can launch, start, complete, interrupt, and recover lessons while the optional backend is unavailable.
4. **Accurately represented:** the name, description, screenshots, age rating, privacy answers, and review notes match the submitted binary.
5. **Private and safe:** the release requests no unnecessary permissions, performs no tracking, and accurately discloses local and network data handling.
6. **Compatible:** the app works on every declared device family, orientation, and supported OS version.
7. **Legally publishable:** the developer owns or licenses the app name, icon, vocabulary, translations, screenshots, and all other shipped content.
8. **Reviewable:** App Review receives clear instructions and can access all functionality without an account, payment, backend, or special hardware.

## 3. Current Submission Baseline

This table records repository facts as of the review date. `BLOCKED` items must be resolved before uploading a release candidate.

| Area | Current state | Status |
| --- | --- | --- |
| Core functionality | Five required pages, three exercise types, review, recovery, persistence, and offline bundled vocabulary are implemented | READY FOR RELEASE TESTING |
| Automated tests | 20 Swift unit tests, primary lesson UI test, recovery UI test, and 3 backend tests passed during Phase 2 | READY; rerun on release commit |
| Backend dependency | Production API base URL is `nil`; bundled vocabulary supports the complete core experience | READY |
| Accounts and purchases | No login, account creation, IAP, subscriptions, or external purchase flow | NOT APPLICABLE |
| Tracking and ads | No ATT, IDFA, advertising, analytics, or tracking SDK found | READY; verify archive |
| Protected resources | No camera, microphone, location, contacts, photos, health, or Bluetooth access found | READY; verify archive |
| App icon | AppIcon slots exist, but no icon image file is present in `AppIcon.appiconset` | **BLOCKED** |
| Privacy policy | No in-app privacy-policy access or approved public privacy-policy URL exists in the repository | **BLOCKED** |
| Privacy manifest | No `PrivacyInfo.xcprivacy` exists | PENDING API/privacy report audit |
| Store metadata | Description, keywords, screenshots, support URL, privacy URL, category, age rating, and review notes are not recorded | **BLOCKED** |
| Release archive | Release configuration exists (`1.0`, build `1`), but an App Store archive/export has not been validated | **BLOCKED** |
| Device coverage | Target declares iPhone and iPad with multiple orientations | PENDING release matrix |
| Physical-device testing | No signed release-candidate evidence is recorded | **BLOCKED** |
| TestFlight | No external/internal release-candidate result is recorded | **BLOCKED** |

## 4. Mandatory Release Gates

Every target in this section must be `PASS`. A failure is a no-go for submission.

### GATE-01: Build, Signing, and Archive

Targets:

* The Release build compiles with the current App Store-supported Xcode and SDK at submission time.
* The archive uses bundle ID `com.brightwater.fast-vocab`, the intended Apple Developer team, automatic or verified manual signing, and an App Store distribution profile.
* `MARKETING_VERSION` matches the App Store version and `CURRENT_PROJECT_VERSION` is unique and greater than every previously uploaded build.
* Xcode's archive validation reports no errors.
* The exported archive contains no test data, test launch arguments, development server URL, debug menu, placeholder asset, or unintended entitlement.
* Upload processing in App Store Connect completes without invalid binary, missing compliance, icon, privacy, or symbol errors.

Evidence:

* archived `.xcarchive` path and creation timestamp,
* Xcode Organizer validation result,
* effective Release build settings,
* App Store Connect processed-build status.

### GATE-02: Stability and Functional Completeness

Targets:

* Zero reproducible crash, hang, data-loss, or navigation dead end in the release candidate.
* Splash reaches Home from bundled vocabulary with airplane mode enabled.
* Users can start and complete article, plural, and translation exercises.
* Three incorrect Main answers cause immediate game over and preserve score statistics.
* Review is one-pass, deduplicated, consumes no hearts, awards no XP, and never requeues an item.
* Pause, background interruption, force termination, relaunch, and Resume restore the next unresolved question boundary.
* Cancel from Main and Review discards staged lesson progress and returns Home.
* Persistent XP, lesson results, and vocabulary statistics survive relaunch.
* Corrupt or unavailable remote data cannot block use when bundled vocabulary is valid.
* All buttons, text fields, alerts, and navigation paths shown in the binary work.

Evidence:

* full unit and UI test reports from the exact release commit,
* manual offline/relaunch checklist,
* zero open severity-1 or severity-2 defects.

### GATE-03: Device, OS, and Layout Compatibility

Targets:

* Test the oldest supported OS (`iOS/iPadOS 18.2`) and the latest public OS available at submission.
* Test at minimum: compact iPhone, current standard iPhone, large iPhone, standard iPad, and large iPad.
* Validate every declared orientation: iPhone portrait and both landscapes; iPad portrait, upside-down portrait, and both landscapes.
* No clipped, overlapping, inaccessible, or off-screen controls with default text and the largest practical Dynamic Type accessibility size.
* Light and dark appearances preserve readable contrast and do not communicate correctness by color alone.
* VoiceOver exposes meaningful labels, reading order, values, and actions for lesson progress, hearts, answers, feedback, and navigation.
* Hardware keyboard input and indirect input do not trap focus or prevent lesson completion on iPad.

Evidence:

* signed device/OS/orientation matrix,
* screenshots for each representative device class,
* accessibility audit notes and unresolved-issue count of zero for blocking defects.

### GATE-04: App Icon and Visual Assets

Targets:

* Supply an original 1024 × 1024 App Store icon with no transparency and assign it to the universal AppIcon slot.
* Dark and tinted variants are either intentionally supplied or allowed to derive according to the current asset-catalog behavior; no empty required slot warning remains.
* The installed icon, App Store icon, and metadata identify the same product and do not imitate Apple or another app.
* All screenshots show the real release build in use, not only Splash, title art, mockups, or features absent from the binary.
* Screenshots contain no real personal data, unlicensed imagery, prices, competitor branding, or unsupported claims.
* Required screenshot sets for each App Store Connect device class are accepted without scaling errors.

Evidence:

* asset catalog validation,
* installed-device icon inspection,
* final screenshot inventory mapped to App Store Connect slots.

### GATE-05: Privacy, Data Use, and Security

Release data inventory:

* Core Data stores lesson progress, XP, lesson results, vocabulary statistics, recoverable session state, and optional vocabulary cache locally on device.
* The current release has no account, user-generated content, analytics, advertising, tracking, or protected-resource access.
* The optional API is disabled in the production composition. If enabled later, its server logging, IP-address handling, retention, and disclosures must be reassessed before submission.

Targets:

* Publish a valid HTTPS privacy-policy URL and add an easily accessible in-app link, for example from Home via an About/Privacy sheet without introducing an account requirement.
* The policy states what is stored locally, whether anything is transmitted, purposes, retention/deletion behavior, contact method, and how users can request assistance.
* App Store Connect App Privacy answers match the final binary, linked SDKs, backend behavior, and policy. Do not assume “Data Not Collected” until the archive and production network configuration are audited.
* Generate and review Xcode's privacy report for the release archive.
* Add `PrivacyInfo.xcprivacy` when the app or any linked SDK declares collected data, tracking domains, or required-reason APIs. Every declared reason must match actual use.
* Tracking remains disabled. If tracking is introduced, it requires a new privacy review, ATT implementation where applicable, consent flow, policy update, and App Store Connect update.
* No protected-resource usage description is included unless the corresponding feature genuinely exists; any future permission request must be specific and understandable.
* Network traffic uses HTTPS/TLS, does not bypass App Transport Security without a justified exception, and does not send lesson or device data unexpectedly.
* Local persistence fails safely and does not expose credentials, tokens, or personal information in logs. The current app should contain none of these secrets.

Evidence:

* approved privacy-policy URL and in-app navigation recording,
* signed data-flow inventory,
* App Store Connect privacy-answer export or screenshots,
* Xcode privacy report and final privacy manifest decision,
* network inspection in offline and online configurations.

### GATE-06: Metadata and Store Listing Accuracy

Targets:

* App name is unique, 30 characters or fewer, and cleared for trademark and naming conflicts.
* Subtitle, description, keywords, promotional text, and What's New text describe only functionality in the submitted binary.
* Do not call the submission a PoC, demo, beta, trial, prototype, or “Duolingo” clone. Beta builds belong in TestFlight.
* Do not claim AI, spaced repetition, adaptive learning, social features, cloud sync, backend-required content, or other excluded functionality.
* Select the most accurate primary category, expected to be Education unless the release owner documents another choice.
* Complete the age-rating questionnaire honestly. Do not use “For Kids” or “For Children” unless intentionally entering the Kids Category and satisfying all additional requirements.
* Provide working HTTPS Support URL, Privacy Policy URL, marketing URL if supplied, copyright, contact name, email, and phone.
* Choose availability territories only after verifying vocabulary-content rights and local legal obligations for each territory.
* App Store screenshots, preview, and description use the same language and capabilities as the app.

Evidence:

* approved metadata sheet,
* link-check report for all public URLs,
* age-rating and category screenshots,
* content-rights sign-off.

### GATE-07: Legal and Intellectual Property

Targets:

* The developer owns or has written permission for the app name, icon, UI artwork, vocabulary lists, translations, and marketing assets.
* German articles, plurals, and translations are reviewed for accuracy; educational claims are not misleading.
* No third-party brand, app name, screenshot, copyrighted dictionary content, or Apple endorsement is implied.
* Open-source dependencies, if introduced, have compatible licenses and required notices.
* The Support URL identifies a real, current contact method.

Evidence:

* content provenance register,
* trademark/name search record,
* dependency license inventory,
* owner sign-off.

### GATE-08: Business Model and Account Rules

Targets for version 1.0:

* The listing accurately identifies the app as free or paid according to its App Store Connect price.
* There is no hidden payment, external purchase call to action, subscription, paid content unlock, or license key.
* The app remains fully usable without login because it has no significant account-based feature.
* Account deletion and Sign in with Apple are not applicable while account creation and third-party login remain absent.
* Any future digital purchase or subscription triggers a separate StoreKit and Guideline 3 review before implementation or submission.

Evidence:

* binary and metadata purchase-flow audit,
* App Store Connect pricing screenshot.

### GATE-09: Minimum Functionality and Native Quality

Targets:

* At least two complete bundled topics remain available offline, each with enough valid items to demonstrate all three exercise types.
* The release clearly provides durable utility through lessons, answer feedback, review, progress statistics, and interruption recovery.
* The interface uses native controls and expected iOS/iPadOS behavior; it is not a web wrapper, static content catalog, or collection of links.
* No placeholder text, sample `Item` data, empty screen, unfinished menu, disabled advertised feature, or developer-only message is visible.
* Battery, CPU, storage writes, launch time, and network retries remain proportionate to a small vocabulary app.

Evidence:

* reviewer walkthrough recording,
* performance and storage sanity-check notes,
* release-content inventory.

### GATE-10: Review Access and Review Notes

Targets:

* No demo account is needed because the app has no authentication.
* Reviewers can reach every feature using bundled data with networking disabled.
* Review notes explain the offline-first behavior, where to start a lesson, how Review is triggered, how recovery is tested, and that the backend is optional/disabled.
* Notes identify any behavior that is not obvious and provide a responsive contact.
* If a backend is enabled in a future build, it must remain live throughout review and test credentials/resources must be supplied when applicable.

Suggested Notes for Review:

> fastVocab is an offline-first German vocabulary trainer and does not require an account, purchase, special hardware, or network connection. From Home, tap “Choose a topic,” select Household or Food, and complete the lesson. The lesson cycles through article, plural, and translation questions. An incorrect answer adds that vocabulary item once to a one-pass Review round. Pause returns to Home and exposes Resume; the session is recovered at the next question boundary after relaunch. Three incorrect answers during the main lesson end the lesson and show Score. The optional vocabulary API is disabled in this build; bundled vocabulary supports the full app.

Evidence:

* final Notes for Review copied from App Store Connect,
* reviewer walkthrough performed by a person who did not build the app.

### GATE-11: Export Compliance and Regulatory Answers

Targets:

* Complete App Store Connect export-compliance questions from the actual release binary.
* Determine whether the app only uses encryption provided by Apple's operating system, such as standard HTTPS through `URLSession`, and record the correct exemption answer.
* Set `ITSAppUsesNonExemptEncryption` only after that determination; do not guess or use the key to bypass compliance review.
* Confirm the app is not a medical, gambling, financial, VPN, news, or regulated-service product.
* Confirm tax, banking, agreements, and developer identity are current in App Store Connect.

Evidence:

* export-compliance decision record,
* App Store Connect agreements/status screenshot.

### GATE-12: TestFlight and Physical Device Acceptance

Targets:

* Install the exact release candidate through TestFlight, not only Xcode.
* Complete one clean-install lesson, one game-over flow, one Review flow, one pause/resume flow, and one force-quit recovery flow on physical iPhone and iPad hardware.
* Repeat the offline flow in airplane mode and confirm no backend warning blocks use.
* Upgrade from the previous public/TestFlight build when one exists and verify persisted data remains readable.
* Review crash reports, hangs, energy diagnostics, and tester feedback; zero unresolved release-blocking issue remains.

Evidence:

* TestFlight build number and tester sign-off,
* physical-device matrix,
* crash/feedback review timestamp.

## 5. Automated Validation Commands

Run from the repository root against the release commit. Substitute an installed destination when needed.

```sh
xcodebuild test \
  -project fast-vocab.xcodeproj \
  -scheme fast-vocab \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

xcodebuild test \
  -project fast-vocab.xcodeproj \
  -scheme fast-vocab \
  -destination 'platform=iOS Simulator,name=iPad (10th generation)'

xcodebuild build \
  -project fast-vocab.xcodeproj \
  -scheme fast-vocab \
  -configuration Release \
  -destination 'generic/platform=iOS'

cd backend
python3 -m pytest -q
```

Passing commands are necessary but insufficient. Archive validation, physical-device testing, metadata, privacy, legal, and App Store Connect checks remain manual gates.

## 6. Manual Release Matrix

Record `PASS`, `FAIL`, or `N/A` with device, OS, build, tester, date, and evidence link.

| Scenario | iPhone compact | iPhone standard/large | iPad standard | iPad large | Physical device |
| --- | --- | --- | --- | --- | --- |
| Clean install and first launch |  |  |  |  |  |
| Airplane-mode launch |  |  |  |  |  |
| Complete all exercise types |  |  |  |  |  |
| Wrong answer and Review |  |  |  |  |  |
| Three-heart game over |  |  |  |  |  |
| Pause and Resume |  |  |  |  |  |
| Force-quit recovery |  |  |  |  |  |
| Cancel during Main |  |  |  |  |  |
| Cancel during Review |  |  |  |  |  |
| Relaunch with persisted progress |  |  |  |  |  |
| Light and dark appearance |  |  |  |  |  |
| Largest Dynamic Type |  |  |  |  |  |
| VoiceOver lesson completion |  |  |  |  |  |
| All declared orientations |  |  |  |  |  |

## 7. App Store Connect Submission Checklist

Before selecting **Add for Review**:

- [ ] Developer Program membership, agreements, tax, banking, and contacts are active.
- [ ] App record and bundle ID match the archive.
- [ ] Version and build number match the intended release.
- [ ] Processed build is selected and has no compliance warning.
- [ ] App name, subtitle, description, keywords, category, copyright, and What's New are final.
- [ ] Required iPhone and iPad screenshots show the release binary.
- [ ] App icon is final and present in the processed build.
- [ ] Support URL and privacy-policy URL are public, HTTPS, and tested without login.
- [ ] Privacy answers match the final archive and policy.
- [ ] Age-rating answers match the content.
- [ ] Export-compliance answers are complete.
- [ ] Content-rights declaration is accurate.
- [ ] Pricing and availability are intentional.
- [ ] Review contact information is current.
- [ ] Notes for Review are specific and include the offline walkthrough.
- [ ] No demo credentials are required; this is stated in review notes.
- [ ] TestFlight release candidate passed physical-device acceptance.
- [ ] All mandatory gates have an owner, date, result, and evidence.

## 8. Rejection-Risk Register

| Risk | Why it matters | Required mitigation |
| --- | --- | --- |
| Missing App Store icon | Invalid or incomplete binary/metadata | Supply and validate original 1024 × 1024 artwork |
| No privacy-policy access | Guideline 5.1.1 requires a policy link in metadata and within the app | Publish policy and add an in-app link before submission |
| Privacy answers based only on source assumptions | Linked frameworks, server logs, or future configuration can change disclosure | Audit the final archive and production data flow |
| High minimum OS (`18.2`) | Not a rejection by itself, but sharply limits compatible customers | Confirm this is an intentional product decision and metadata matches |
| Broad iPad/orientation declaration | Every declared combination is reviewable | Complete the full iPad/orientation matrix or narrow support intentionally |
| Educational content errors | Incorrect answers undermine core utility and metadata accuracy | Native-speaker/editorial review of every shipped item |
| “PoC” presentation | Apple rejects demos/betas and incomplete products | Remove prototype language and submit a complete 1.0 product |
| Optional backend later enabled | Availability, privacy, IPv6, TLS, and review access obligations increase | Repeat privacy/network/reviewer-access gates before enabling it |
| Low perceived functionality | Simple apps may be challenged under Guideline 4.2 | Demonstrate lessons, feedback, review, recovery, and durable progress clearly |

## 9. Go/No-Go Rule

The release is **GO** only when:

* every mandatory gate is `PASS`,
* every App Store Connect checklist item is complete,
* automated tests pass on the exact release commit,
* the App Store archive validates and processes successfully,
* physical iPhone and iPad TestFlight acceptance is signed,
* there are zero unresolved crash, data-loss, privacy, legal, metadata, or reviewer-access defects,
* the release owner signs the record below.

Any `FAIL`, unowned `PENDING`, missing evidence, placeholder asset, or discrepancy between the binary and metadata makes the release **NO-GO**.

## 10. Release Sign-Off Record

| Role | Name | Result | Date | Evidence/notes |
| --- | --- | --- | --- | --- |
| Engineering |  |  |  |  |
| QA |  |  |  |  |
| Privacy |  |  |  |  |
| Content/IP |  |  |  |  |
| App Store metadata |  |  |  |  |
| Release owner |  |  |  |  |

Release version:  
Build number:  
Git commit:  
TestFlight build:  
Archive validation date:  
Submission date:

## 11. Scope-Change Triggers

Repeat the relevant gates before submission whenever a release adds or changes:

* analytics, advertising, tracking, or a third-party SDK,
* API base URL, server logging, downloaded content, or user-data transmission,
* account creation, login, cloud sync, or account deletion,
* payments, subscriptions, external purchase links, or premium content,
* permissions or protected-resource APIs,
* user-generated content, social behavior, or messaging,
* target devices, orientations, deployment target, or entitlements,
* vocabulary source, licensed content, age-rating-sensitive content, or territories.

## 12. Official Sources

Recheck these sources before submission; Apple guidance is authoritative over this document.

* App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
* App Review overview: https://developer.apple.com/distribute/app-review/
* App Store Connect Help: https://developer.apple.com/help/app-store-connect/
* App privacy details: https://developer.apple.com/app-store/app-privacy-details/
* Privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
* Required-reason APIs: https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
* Third-party SDK requirements: https://developer.apple.com/support/third-party-SDK-requirements/
* Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
* Accessibility: https://developer.apple.com/accessibility/
* Offering account deletion: https://developer.apple.com/support/offering-account-deletion-in-your-app/
* Export compliance: https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance
* App Store icon and screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

The App Review Guidelines consulted for this baseline reported a last update of June 8, 2026. The release owner must verify that date and all linked requirements again at submission time.