# fastVocab PoC Implementation Plan

Status: Frozen for PoC implementation  
Authority: `docs/requirements/req_poc_final.md` v1.4

## 1. Delivery Strategy

Implementation proceeds in narrow, executable slices. Each slice ends with focused tests before the next slice begins. The bundled offline path is completed before the optional backend path.

## 2. Phase 1: Design Documents

Deliver and freeze:

* `architecture.md`
* `design.md`
* `state_model.md`
* `project_structure.md`
* `implementation_plan.md`
* `assumptions.md`

Exit criteria:

* all documents derive from `req_poc_final.md`,
* state ownership and mutation contracts agree across documents,
* no out-of-scope feature appears in the design,
* implementation assumptions are explicit.

## 3. Phase 2A: Domain and Store Foundation

1. Remove the generated SwiftData sample model and container.
2. Add domain vocabulary, lesson, exercise, session, and progress models.
3. Implement deterministic exercise assignment and answer validation.
4. Implement lesson transitions, hearts, XP, unique mistakes, and one-pass review.
5. Add `AppState`, `AppAction`, and `AppStore` with injected test dependencies.

Validation:

* compile the app target,
* run exercise validation and lesson engine unit tests,
* run store transition tests for start, answer, review, completion, game over, pause, resume, and cancel.

## 4. Phase 2B: Core Data Persistence

1. Define records for recoverable session, user summary, lesson results, vocabulary statistics, and optional vocabulary cache.
2. Implement the Core Data container with production and in-memory configurations.
3. Implement explicit domain mappers and repositories.
4. Persist session snapshots only at question boundaries.
5. Atomically commit terminal lesson progress and remove recoverable state.

Validation:

* repository round-trip tests,
* cancellation deletion test,
* interrupted lesson restoration test,
* terminal transaction idempotency test,
* app target compile.

## 5. Phase 2C: Vocabulary Loading

1. Add versioned bundled JSON with at least one valid topic and at least three items.
2. Implement JSON decoding and content validation.
3. Implement cache source, bundle source, API source, and ordered loader.
4. Connect initialization success and blocking no-data error to `AppStore`.

Validation:

* Cache wins when usable.
* Bundle is used when cache is absent or invalid.
* API is attempted only when local sources are unavailable.
* Total failure prevents lesson creation and permits retry.
* Offline launch succeeds from bundled content.

## 6. Phase 2D: SwiftUI Pages

1. Implement root switching for Splash, Home, Topic Selection, Game, and Score.
2. Implement small read-only page view models that dispatch actions.
3. Implement article, plural, and translation controls.
4. Implement progress, hearts, feedback, pause, resume, cancel confirmation, review labeling, and score details.
5. Verify light, dark, Dynamic Type, VoiceOver labels, compact and large iPhones, and iPads in supported orientations.

Validation:

* app target compile after each page,
* SwiftUI previews with deterministic fixtures where useful,
* primary navigation UI test,
* manual visual checks in light and dark appearance on representative iPhone and iPad simulators.

## 7. Phase 2E: Optional FastAPI Backend

1. Add FastAPI application and typed response models.
2. Add health, topic list, and topic vocabulary endpoints.
3. Serve curated JSON matching the client schema.
4. Configure the client API base URL without making it required.

Validation:

* backend endpoint tests,
* client decode test against backend fixtures,
* launch and complete a lesson with the backend stopped.

## 8. Phase 3: Test Completion

Complete the required matrix:

| Area | Required coverage |
| --- | --- |
| AppStore | valid and invalid navigation/state transitions |
| Exercises | article, plural, translation normalization and validation |
| Scoring | main XP only, all wrong occurrences, unique mistakes |
| Hearts | exactly three main mistakes cause immediate game over |
| Review | first-mistake order, deduplication, one pass, no requeue |
| Pause/resume | snapshot and continuation at same question boundary |
| Recovery | progress, phase, hearts, statistics, mistakes, queue |
| Vocabulary | Cache, Bundle, API, Error priority |
| Persistence | user progress and session round trips across launches |
| UI | Splash to Home to Topic to Game to Score to Home |
| Cancellation | main and review cancellation discard active progress |

Run the full unit and UI suites on an available iOS simulator. Run backend tests separately.

## 9. Phase 4: Final Documentation

Create:

* `implementation_report.md`
* `testing_report.md`
* `design_decisions.md`

The reports record implemented behavior, deviations or blockers, commands and environments used for testing, test results, assumptions applied, and PoC trade-offs. They do not redefine requirements.

## 10. Traceability

| Requirement group | Primary implementation area | Primary validation |
| --- | --- | --- |
| APP | AppStore and five feature pages | store and UI tests |
| VOCAB | VocabularyLoader and sources | source-priority tests |
| LESSON | LessonEngine and Session | domain/store tests |
| USER | UserProgress and repository | scoring/persistence tests |
| PERSISTENCE | SessionRepository and Core Data | recovery tests |
| BACKEND | API source and FastAPI | endpoint/offline tests |
| UI | SwiftUI Features | UI tests and appearance checks |

## 11. Completion Gate

The PoC is complete only when every acceptance criterion in `req_poc_final.md` has an implementation and passing evidence, or a documented environment blocker. Optional backend failure must never block the core completion gate.
