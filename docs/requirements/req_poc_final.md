# fastVocab

## PoC Requirement Specification (req_poc.md v1.4)

### 1. Project Overview

fastVocab is an offline-first vocabulary learning application that provides interactive vocabulary lessons through multiple exercise types.

The objectives of this PoC are to validate:

* the vocabulary learning experience,
* the lesson lifecycle,
* lesson recovery mechanisms,
* user progress tracking,
* offline usability,
* and optional backend integration.

This document is the authoritative specification for the PoC product behavior. All derived documents shall conform to the requirements defined herein and shall not modify or expand the product requirements unless this document is formally revised.

This document specifies:

* what the product shall do,
* what behavior is expected from the product,
* and what is intentionally out of scope.

This document does not define:

* architectural decisions,
* implementation decisions,
* technology choices,
* design patterns,
* user interface designs.

---

### 2. PoC Scope

The PoC shall support:

* vocabulary learning lessons,
* article exercises,
* plural exercises,
* translation exercises,
* lesson pause and resume,
* lesson cancellation,
* lesson recovery,
* lesson statistics,
* user progress tracking,
* offline usage,
* bundled vocabularies,
* cached vocabularies,
* optional backend-provided vocabularies.

The PoC shall provide the following application pages:

* Splash Page,
* Home Page,
* Topic Selection Page,
* Game Page,
* Score Page.

---

### 3. PoC Constraints

#### CONSTRAINT-001

Only one active lesson shall exist at any time.

#### CONSTRAINT-002

Only one review round shall be supported for each lesson.

#### CONSTRAINT-003

The application shall support offline usage and remain usable without internet access.

#### CONSTRAINT-004

The application shall remain usable when backend services are unavailable.

#### CONSTRAINT-005

Each lesson shall contain at least three vocabulary items.

#### CONSTRAINT-006

The PoC shall NOT support:

* authentication,
* social features,
* leaderboards,
* monetization,
* competitive gameplay,
* adaptive learning,
* spaced repetition systems,
* cloud synchronization,
* AI-generated vocabulary contents,
* AI-generated questions.

#### CONSTRAINT-007

The review round is intended solely as a lesson-scoped validation mechanism and shall not provide adaptive learning or spaced repetition functionality.

---

### 4. Application Requirements

#### APP-001

The application shall launch successfully when usable vocabulary data is available.

#### APP-002

The application shall provide navigation between all supported application pages.

#### APP-003

The Splash Page shall perform application initialization activities before transitioning to the Home Page.

#### APP-004

The Splash Page shall transition automatically when initialization completes successfully.

#### APP-005

When usable vocabulary data is unavailable, the application shall provide an appropriate error presentation and prevent lesson creation until usable vocabulary data becomes available.

#### APP-006

The application shall support:

* starting lessons,
* completing lessons,
* recovering interrupted lessons.

#### APP-007

The application shall provide sufficient information for users to:

* understand lesson progress,
* review lesson results,
* resume recoverable lessons when available.

---

### 5. Vocabulary Requirements

#### VOCAB-001

The application shall support vocabulary contents obtained from:

* cached vocabularies,
* bundled vocabularies,
* backend-provided vocabularies.

#### VOCAB-002

Vocabulary loading shall prioritize:

1. cached vocabularies,
2. bundled vocabularies,
3. backend-provided vocabularies.

#### VOCAB-003

Backend-provided vocabularies are optional for the PoC and shall not be required to start or complete lessons.

#### VOCAB-004

Backend failures shall not prevent:

* launching the application when usable vocabulary data is available,
* starting lessons,
* completing lessons,
* recovering interrupted lessons.

#### VOCAB-005

Topic selection shall determine which vocabulary set is used to create a lesson.

---

### 6. Lesson Requirements

#### LESSON-001

A lesson shall support:

* starting,
* pausing,
* resuming,
* cancellation,
* completion,
* interruption recovery,
* game over conditions.

#### LESSON-002

The application shall generate one exercise for each vocabulary item presented during a lesson.

#### LESSON-003

The application shall support the following exercise types:

* article exercises,
* plural exercises,
* translation exercises.

#### LESSON-004

All supported exercise types shall be presented during lessons.

#### LESSON-005

The application shall:

* present vocabulary questions,
* validate user answers,
* provide answer feedback,
* advance lesson progress after questions are resolved.

#### LESSON-006

Questions answered incorrectly shall be recorded as lesson mistakes.

#### LESSON-007

Vocabulary items answered incorrectly shall:

* be added to the review queue,
* appear only once within the review queue for a lesson,
* be presented once during the review round.

#### LESSON-008

Vocabulary items answered incorrectly during the review round:

* shall be recorded within lesson statistics,
* shall not be added back into the review queue.

#### LESSON-009

The review round shall complete when all vocabulary items within the review queue have been presented once.

#### LESSON-010

A lesson shall be considered completed only when:

* the main lesson has been completed, and
* the review round has been completed.

#### LESSON-011

A lesson shall begin the main lesson phase with three hearts.

#### LESSON-012

Each incorrect answer provided during the main lesson phase shall consume one remaining heart.

#### LESSON-013

Remaining hearts shall apply only during the main lesson phase.

#### LESSON-014

Game over conditions shall apply only during the main lesson phase.

#### LESSON-015

A lesson shall enter the game over state when no remaining hearts are available during the main lesson phase.

#### LESSON-016

When a lesson enters the game over state:

* the lesson shall terminate immediately,
* the review round shall not be presented,
* lesson statistics shall remain available,
* users shall be navigated to the Score Page.

#### LESSON-017

The review round:

* shall not consume hearts,
* shall not enter the game over state.

#### LESSON-018

Cancelling an active lesson during either the main lesson phase or the review round shall:

* terminate the active lesson,
* discard its active lesson progress,
* navigate users to the Home Page.

---

### 7. User Progress Requirements

#### USER-001

The application shall maintain user learning statistics.

#### USER-002

User information shall include:

* accumulated experience points,
* lesson statistics,
* vocabulary learning statistics.

#### USER-003

User progress shall persist across application launches.

#### USER-004

Wrong answer counts shall include all incorrect answer occurrences recorded during both the main lesson and the review round.

#### USER-005

Recorded mistakes shall represent unique vocabulary items answered incorrectly during a lesson and shall be maintained independently from aggregated wrong answer counts.

#### USER-006

Experience points shall be awarded only for correct answers provided during the main lesson phase.

#### USER-007

Correct answers provided during the review round shall not award experience points.

---

### 8. Persistence Requirements

#### PERSISTENCE-001

The application shall support:

* lesson persistence,
* lesson recovery,
* user progress persistence.

#### PERSISTENCE-002

Lesson recovery shall occur only at question boundaries.

#### PERSISTENCE-003

The application shall recover:

* lesson progress,
* remaining hearts when applicable,
* lesson statistics,
* recorded mistakes,
* review queue information.

#### PERSISTENCE-004

The application shall not recover:

* transient user interface states,
* temporary selections,
* animations,
* other temporary presentation states.

#### PERSISTENCE-005

Recovery information shall remain sufficient for users to continue interrupted lessons without restarting the entire lesson.

---

### 9. Backend Requirements

#### BACKEND-001

Backend integration is optional for the PoC.

#### BACKEND-002

The application shall remain usable when backend services are unavailable.

#### BACKEND-003

Backend-provided vocabularies shall be treated as supplemental content and shall not be required for the core vocabulary learning experience of the PoC.

---

### 10. UI Requirements

#### UI-001

The application shall support:

* light appearance,
* dark appearance,
* responsive layouts appropriate for supported device sizes.

#### UI-002

The Home Page shall provide sufficient information for users to:

* start lessons,
* resume recoverable lessons when available.

#### UI-003

The Topic Selection Page shall provide users with the ability to select the vocabulary topic used to create a lesson.

#### UI-004

The Game Page shall provide sufficient information for users to understand:

* the current question,
* lesson progress,
* available answer inputs.

During the main lesson phase, the Game Page shall additionally provide sufficient information regarding remaining hearts.

#### UI-005

The Score Page shall provide sufficient information for users to review:

* earned experience points,
* lesson statistics,
* recorded mistakes,
* lesson completion status.

---

### 11. Acceptance Criteria

The PoC shall be considered complete when:

* Users can start, pause, resume, cancel, and complete vocabulary lessons.
* Each lesson contains at least three vocabulary items.
* Lessons begin the main lesson phase with three hearts.
* Each incorrect answer during the main lesson phase consumes one remaining heart.
* Users can answer article, plural, and translation exercises.
* All supported exercise types are presented during lessons.
* Users can recover interrupted lessons.
* Users can complete the review round for incorrectly answered vocabulary items.
* Vocabulary items are presented only once within the review queue.
* Remaining hearts are applied only during the main lesson phase.
* Game over conditions apply only during the main lesson phase.
* Lessons terminate immediately when no remaining hearts are available during the main lesson phase.
* Review rounds do not consume hearts and cannot enter the game over state.
* Experience points are awarded only for correct answers provided during the main lesson phase.
* Correct answers provided during the review round do not award experience points.
* Wrong answer counts include all incorrect answer occurrences during a lesson.
* Recorded mistakes represent unique vocabulary items answered incorrectly during a lesson.
* Lesson statistics remain available following lesson completion or game over.
* User progress persists across application launches.
* The application remains usable without internet access.
* The application remains usable when backend services are unavailable.
* Supported application pages are available and navigable.
* Only one active lesson exists at any time.
* The product behavior remains consistent regardless of the chosen implementation technology.
