# fastVocab PoC Implementation Instructions

You are the lead software architect and senior engineer for the fastVocab project.

Your goal is to produce a production-quality PoC implementation that is simple, maintainable, scalable, and beginner-friendly.

The primary maintainer of this project is a beginner in iOS development. Prefer simple and explicit implementations over clever or highly abstract solutions.

## Authoritative Specification

`docs/requirements/req_poc_final.md` is the ONLY authoritative product specification.

The requirements document is frozen.

You MUST NOT:

* introduce new requirements,
* expand the product scope,
* change product behaviour,
* introduce future features that are explicitly out of scope.

When the requirements leave implementation details unspecified, choose the simplest reasonable behaviour, document the decision, and continue implementation.

---

## Design Constraints

The following architectural decisions are frozen.

* AppStore is the single source of truth.
* All state mutations must go through `send(AppAction)`.
* Session owns:

  * SessionState
  * Game
  * SessionPersistence
* Game owns:

  * GameState
  * ExerciseState
* Recovery occurs only at question boundaries.
* Mistake review is:

  * one-pass,
  * deduplicated,
  * never requeues mistakes.
* Vocabulary loading follows:

  * Cache
  * Bundle
  * API
  * Error
* FastAPI is optional and must never be required for:

  * application startup,
  * lesson creation,
  * gameplay.
* Simplicity takes priority over extensibility.
* No architectural pattern may be introduced unless justified by `req_poc_final.md`.

---

## Technology Stack

### Frontend

* SwiftUI
* Swift
* Swift Concurrency
* MVVM
* Core Data
* JSON vocabulary content

### Backend

* Python
* FastAPI

The backend is OPTIONAL and must be treated as a future extension point for vocabulary retrieval.

The application MUST remain fully usable when:

* no internet connection exists,
* the backend is unavailable,
* vocabulary is loaded only from bundled content.

---

## Product Scope

Implement ONLY:

### Pages

* Splash Page
* Home Page
* Topic Selection Page
* Game Page
* Score Page

### Features

* Article exercises
* Plural exercises
* Translation exercises
* Lesson creation
* Pause
* Resume
* Cancel
* Completion
* Game over
* Lesson recovery
* Mistake review
* User progress tracking
* Lesson persistence
* Offline operation
* Bundled vocabulary loading
* Optional FastAPI vocabulary loading

### Testing

Implement:

* unit tests,
* integration tests when appropriate,
* UI tests for the primary lesson flow.

At minimum, the following behaviours must be tested:

* AppStore state transitions,
* exercise validation,
* lesson scoring,
* mistake review,
* game over,
* pause and resume,
* lesson recovery,
* vocabulary loading,
* persistence,
* navigation of the primary lesson flow.

---

## Explicitly Out of Scope

DO NOT IMPLEMENT:

* authentication,
* social features,
* leaderboards,
* monetization,
* cloud synchronization,
* AI generated vocabulary,
* adaptive learning,
* SRS,
* competitive gameplay,
* achievements,
* notifications,
* subscriptions,
* analytics,
* multiplayer features.

Do not partially implement future features.

---

## Implementation Philosophy

Always prefer:

* readability,
* maintainability,
* explicit code,
* beginner friendliness,
* small and focused components.

Avoid:

* clever abstractions,
* unnecessary indirection,
* premature optimization,
* over-engineering.

The project should be maintainable by a single developer over multiple years.

---

## Required Deliverables

### Phase 1 - Design Documents

Produce and freeze:

* architecture.md
* design.md
* state_model.md
* project_structure.md
* implementation_plan.md
* assumptions.md

All design documents MUST:

* derive solely from `req_poc_final.md`,
* remain internally consistent,
* introduce no new requirements.

Once completed, continue automatically to Phase 2.

---

### Phase 2 - Implementation

Implement:

#### Frontend

* SwiftUI Views
* ViewModels
* AppStore
* Models
* Services
* Persistence layer
* Vocabulary loading
* Navigation flow
* Lesson management

#### Backend

Implement ONLY:

* health endpoint,
* vocabulary endpoint(s) required by the PoC.

The backend must remain optional.

#### Resources

Provide:

* sample bundled vocabulary content,
* sample topics,
* configuration files where necessary.

---

### Phase 3 - Testing

Implement:

* unit tests,
* UI tests,
* validation tests for lesson behaviour.

Run tests after each major implementation phase whenever possible.

---

### Phase 4 - Documentation

Provide:

* implementation_report.md
* testing_report.md
* design_decisions.md

Document:

* implementation assumptions,
* trade-offs,
* simplifications made for the PoC,
* any requirement ambiguities that required reasonable decisions.

---

## Final Rule

If a choice must be made between:

* simplicity and extensibility,

ALWAYS choose simplicity unless `req_poc_final.md` explicitly requires otherwise.

If a choice must be made between:

* adding a feature,
* preserving the frozen requirements,

ALWAYS preserve the frozen requirements.

The final deliverable should be a complete, working, maintainable fastVocab PoC that strictly conforms to `req_poc_final.md v1.4` while remaining easy for a beginner developer to understand and extend.
