# fastVocab Xcode Build and Validation Runbook

Status: Active development guide  
Applies to: fastVocab iOS and iPadOS project  
Project: `fast-vocab.xcodeproj`  
Scheme: `fast-vocab`

## 1. Purpose

This guide explains how to rebuild and validate fastVocab after a change, either in Xcode or headlessly from Terminal. It is intended for everyday development checks and release-candidate preparation.

The commands use a repository-local DerivedData directory under `.build/`. That path is ignored by Git and gives build, app, test-result, log, and screenshot artifacts predictable locations.

Run all commands from the repository root:

```sh
cd /path/to/fast-vocab
```

## 2. Project Baseline

The current project contains:

| Item | Value |
| --- | --- |
| Xcode project | `fast-vocab.xcodeproj` |
| Shared scheme | `fast-vocab` |
| App target | `fast-vocab` |
| Unit-test target | `fast-vocabTests` |
| UI-test target | `fast-vocabUITests` |
| Build configurations | `Debug`, `Release` |
| App bundle ID | `com.brightwater.fast-vocab` |
| Minimum deployment target | iOS/iPadOS 18.2 |
| Reference toolchain | Xcode 16.2 (`16C5032a`) |

Confirm that the project still exposes the expected scheme and targets:

```sh
xcodebuild -list -project fast-vocab.xcodeproj
```

## 3. Environment Check

Check the active Xcode installation:

```sh
xcodebuild -version
xcode-select -p
```

Expected developer directory for a standard installation:

```text
/Applications/Xcode.app/Contents/Developer
```

If command-line tools point somewhere else, select Xcode:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

This command requires an administrator password and should be run manually. Do not put the password in a script or chat.

Accept a new Xcode license and install first-launch components from Xcode itself if `xcodebuild` reports that they are missing.

List available simulators before using a destination name:

```sh
xcrun simctl list devices available
```

The examples below use `iPhone 16 Pro` and `iPad Air 11-inch (M2)`. Substitute names installed on the current machine.

## 4. Recommended Validation Cadence

Use the smallest check that can disprove the change first.

### After a small visual change

1. Build the app for one simulator.
2. Run the primary lesson UI test if controls, labels, layout, or navigation changed.
3. Launch and screenshot the affected screen.
4. Run the full suite before merging.

### After domain, persistence, or store logic changes

1. Run unit tests.
2. Run the primary and recovery UI tests.
3. Run the full suite.
4. Perform a Release build.

### Before a release candidate

1. Perform a clean full test.
2. Test representative iPhone and iPad destinations.
3. Perform a generic-device Release build.
4. Run backend tests.
5. Install the final build through TestFlight on physical devices.
6. Complete the separate App Store review validation plan.

An incremental build is normally correct after a source edit. Use a clean rebuild when generated output may be stale, build settings changed, files were added or removed, or an incremental-only failure is suspected.

## 5. Common Headless Setup

Use these variables in the current terminal session:

```sh
export PROJECT="$PWD/fast-vocab.xcodeproj"
export SCHEME="fast-vocab"
export DERIVED_DATA="$PWD/.build/XcodeDerivedData"
export VALIDATION_OUTPUT="$PWD/.build/validation"
mkdir -p "$VALIDATION_OUTPUT"
```

The variables last until that terminal session closes. Re-run the block in a new terminal.

## 6. Fast Headless Build

Build the Debug app for an iPhone simulator without opening Xcode:

```sh
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO
```

A successful command ends with:

```text
** BUILD SUCCEEDED **
```

For a destination-independent simulator compile:

```sh
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO
```

The generic build proves simulator compilation but does not prove that the interface fits a specific screen.

## 7. Clean Rebuild

Ask Xcode to clean the selected scheme, then rebuild:

```sh
xcodebuild clean \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA"

xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO
```

If Xcode's clean action does not resolve a suspected stale cache, remove only this project's local DerivedData and rebuild:

```sh
rm -rf "$DERIVED_DATA"
```

Do not remove the project, source directories, or arbitrary paths. `DERIVED_DATA` must point to `$PWD/.build/XcodeDerivedData` before running that command.

## 8. Unit Tests

Run only the Swift unit-test target:

```sh
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:fast-vocabTests
```

This is the quickest executable check for lesson rules, persistence, vocabulary loading, and `AppStore` behavior.

## 9. UI Tests

Run the primary lesson flow only:

```sh
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:fast-vocabUITests/fast_vocabUITests/testPrimaryLessonFlow
```

Run interrupted-session recovery only:

```sh
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:fast-vocabUITests/RecoveryFlowUITests/testRecoverableLessonResumesAtQuestionBoundary
```

The primary test traverses article, plural, translation, Score, and Home. The recovery test starts with deterministic persisted state and verifies Resume at a question boundary.

UI tests launch with in-memory persistence. They do not alter normal development data.

## 10. Full Test Suite

Run all unit and UI tests:

```sh
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA"
```

A successful run ends with:

```text
** TEST SUCCEEDED **
```

Run the same suite on iPad when shared layout, navigation, orientation support, or adaptive presentation changes:

```sh
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M2)' \
  -derivedDataPath "$DERIVED_DATA"
```

## 11. Build Once, Test Repeatedly

For repeated test runs without recompiling test bundles each time:

```sh
xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA"
```

Then run the compiled tests:

```sh
xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA"
```

Re-run `build-for-testing` after source, resource, build-setting, or test changes. `test-without-building` is only valid while the compiled test products match the source being evaluated.

## 12. Save Test Results and Logs

Create a timestamped `.xcresult` bundle and terminal log:

```sh
export RUN_ID="$(date +%Y%m%d-%H%M%S)"

set -o pipefail
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$VALIDATION_OUTPUT/test-$RUN_ID.xcresult" \
  2>&1 | tee "$VALIDATION_OUTPUT/test-$RUN_ID.log"
```

`set -o pipefail` ensures the pipeline fails when `xcodebuild` fails, even though output is also sent through `tee`.

Open a result bundle in Xcode:

```sh
open "$VALIDATION_OUTPUT/test-$RUN_ID.xcresult"
```

Print a machine-readable summary with Xcode's result tool:

```sh
xcrun xcresulttool get test-results summary \
  --path "$VALIDATION_OUTPUT/test-$RUN_ID.xcresult"
```

## 13. Headless Simulator Launch

Build to the local DerivedData path first. Then resolve an available simulator identifier by name:

```sh
export DEVICE_NAME="iPhone 16 Pro"
export DEVICE_ID="$(xcrun simctl list devices available | awk -F '[()]' -v name="$DEVICE_NAME" '$0 ~ name " \\(" { print $2; exit }')"
test -n "$DEVICE_ID" && printf 'Using %s\n' "$DEVICE_ID"
```

Boot it without opening Simulator.app:

```sh
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
```

Build an installable simulator app for that exact destination:

```sh
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA"
```

Install and launch:

```sh
export APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/fast-vocab.app"
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
xcrun simctl launch --terminate-running-process \
  "$DEVICE_ID" \
  com.brightwater.fast-vocab
```

For a deterministic clean UI-test-style launch with in-memory persistence:

```sh
xcrun simctl launch --terminate-running-process \
  "$DEVICE_ID" \
  com.brightwater.fast-vocab \
  --ui-testing
```

For the seeded recovery state:

```sh
xcrun simctl launch --terminate-running-process \
  "$DEVICE_ID" \
  com.brightwater.fast-vocab \
  --ui-testing-recovery
```

These launch arguments are development/test hooks. Normal users never receive them from an App Store launch.

## 14. Headless Screenshots

Create a screenshot directory and capture the current simulator display:

```sh
mkdir -p "$VALIDATION_OUTPUT/screenshots"
xcrun simctl io "$DEVICE_ID" screenshot \
  "$VALIDATION_OUTPUT/screenshots/home-iphone.png"
```

Open the image:

```sh
open "$VALIDATION_OUTPUT/screenshots/home-iphone.png"
```

Repeat on iPad by changing `DEVICE_NAME`, resolving `DEVICE_ID` again, rebuilding for that destination if necessary, installing, launching, and capturing.

Use screenshots to inspect issues that tests do not detect:

* clipping or overlap,
* unintended background colors,
* weak text contrast,
* oversized empty space,
* inconsistent semantic colors,
* controls moving between answer states,
* compact and regular-width layout differences.

## 15. Clean-Install and Relaunch Checks

Uninstall the app to remove its simulator container:

```sh
xcrun simctl terminate "$DEVICE_ID" com.brightwater.fast-vocab 2>/dev/null || true
xcrun simctl uninstall "$DEVICE_ID" com.brightwater.fast-vocab 2>/dev/null || true
xcrun simctl install "$DEVICE_ID" "$APP_PATH"
xcrun simctl launch "$DEVICE_ID" com.brightwater.fast-vocab
```

Use a clean install to validate first launch. Do not use it when validating persistence across an upgrade or relaunch, because uninstalling intentionally deletes local app data.

To test an ordinary relaunch while retaining data:

```sh
xcrun simctl terminate "$DEVICE_ID" com.brightwater.fast-vocab
xcrun simctl launch "$DEVICE_ID" com.brightwater.fast-vocab
```

## 16. Appearance Validation

Switch the simulator to dark appearance:

```sh
xcrun simctl ui "$DEVICE_ID" appearance dark
```

Return to light appearance:

```sh
xcrun simctl ui "$DEVICE_ID" appearance light
```

Capture screenshots in each appearance. Also validate Dynamic Type and VoiceOver manually because the current automated suite does not assert visual clipping, reading order, or spoken labels at every accessibility size.

## 17. Release Build

Compile the Release configuration for a generic physical iOS device:

```sh
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA"
```

This validates Release compilation and signing configuration. It does not create or validate an App Store archive.

If local signing is unavailable and the goal is compile-only validation, use:

```sh
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO
```

For App Store submission, create and validate an archive through Xcode Organizer or an approved CI signing environment. A successful unsigned build is not evidence that distribution certificates, provisioning, entitlements, privacy metadata, or App Store processing are valid.

## 18. Backend Validation

The backend is optional for app startup and gameplay, but validate it when backend code or shared vocabulary fixtures change.

Create a local environment once:

```sh
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r backend/requirements.txt
```

Run backend tests from the repository root:

```sh
source .venv/bin/activate
python3 -m pytest -q backend/tests
```

The `.venv` directory and Python caches are ignored by Git.

## 19. Xcode GUI Workflow

For non-headless validation:

1. Open `fast-vocab.xcodeproj` in Xcode.
2. Select the `fast-vocab` scheme.
3. Select an installed iPhone or iPad simulator.
4. Use **Product > Build** (`Command-B`) for an incremental build.
5. Use **Product > Test** (`Command-U`) for all tests in the scheme.
6. Use the Test navigator to run one target, suite, or test method.
7. Use **Product > Clean Build Folder** (`Shift-Command-K`) only when a clean rebuild is warranted.
8. Run the app (`Command-R`) and inspect the changed screen manually.
9. Review failures and attachments in the Report navigator.

The GUI and Terminal use the same project and scheme. A test passing in one mode should pass in the other when the destination, configuration, launch arguments, and build products are equivalent.

## 20. Troubleshooting

### Destination cannot be found

Symptom:

```text
Unable to find a destination matching the provided destination specifier
```

Action:

```sh
xcrun simctl list devices available
```

Use an installed device name or its identifier. Ensure the requested runtime is installed in Xcode Settings > Platforms.

### Simulator is unavailable or stuck

Shut down the selected simulator and boot it again:

```sh
xcrun simctl shutdown "$DEVICE_ID" 2>/dev/null || true
xcrun simctl boot "$DEVICE_ID"
xcrun simctl bootstatus "$DEVICE_ID" -b
```

Do not erase all simulators as a routine fix; that destroys simulator data and is rarely necessary.

### DerivedData permission error

Prefer the repository-local path used in this guide:

```sh
-derivedDataPath "$PWD/.build/XcodeDerivedData"
```

This avoids reliance on a user-library DerivedData location. Confirm that the workspace is writable.

### Signing failure during simulator build

Use a simulator destination and, for compile-only validation, add:

```sh
CODE_SIGNING_ALLOWED=NO
```

Do not disable signing for a physical-device run or distribution archive.

### Result bundle already exists

`-resultBundlePath` must point to a new path. Generate a new `RUN_ID` or remove only the obsolete result bundle under `.build/validation`.

### UI test cannot find an element

Check:

* the expected screen was reached,
* the accessibility identifier is unchanged,
* a modal alert or keyboard is not covering the control,
* the correct deterministic launch argument is used,
* the control is visible at the selected size and orientation.

Review the `.xcresult` screenshots and accessibility hierarchy before increasing timeouts. A longer timeout does not fix a missing or inaccessible control.

### Build passes but the screen looks wrong

A successful compile cannot validate layout quality. Install the built app, navigate to the changed state, capture iPhone and iPad screenshots, and compare backgrounds, spacing, contrast, truncation, and hit targets manually.

## 21. Copy-Paste Daily Check

This sequence is a practical default after a frontend change:

```sh
export PROJECT="$PWD/fast-vocab.xcodeproj"
export SCHEME="fast-vocab"
export DERIVED_DATA="$PWD/.build/XcodeDerivedData"

xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:fast-vocabUITests/fast_vocabUITests/testPrimaryLessonFlow

git diff --check
```

Before merging, replace the focused UI-test command with the full test-suite command from section 10.

## 22. Passing Criteria

A normal change is ready for review when:

* the relevant focused test passes,
* the complete suite passes before merge,
* the app builds for both declared device families when layout is affected,
* the changed screen has been inspected at representative sizes,
* no new Xcode warnings or diagnostics are attributable to the change,
* `git diff --check` reports no whitespace errors,
* generated `.build/` artifacts are not staged in Git.

For App Store release criteria, use `docs/validations/app_store_review_validation.md` in addition to this development runbook.