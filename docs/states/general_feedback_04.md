My conclusion is somewhat different from the previous rounds. I don't think we should do another round of feedback. I think we've reached the point where we're arguing about implementation contracts rather than architecture.

If I were reviewing this as a Staff Engineer, I would classify the remaining issues into two groups.

### Architecture (Must Fix)

* `AppStore.send()` contract.
* Persistence boundary definition.
* `SessionPhase` vs `SessionState`.
* Mistake queue identity and scoring rules.

### Implementation Details (Can Stop Here)

* Whether `VocabularyWordID` is `UUID` or `String`.
* Core Data schema.
* API cache replacement strategy.
* Future enum compatibility.
* Error logging strategy.
* Background refresh implementation.

The second category should not hold up the design freeze.

---

## What I Would Freeze

I would freeze the architecture as follows.

```text
                    AppStore
                        |
                send(AppAction)
                        |
            --------------------------------
            |               |               |
         AppState       UserState      VocabularyState
                                                |
                                       ErrorPresentation?
                                                |
                                            Session?
                                                |
                                    ------------------------
                                    |           |            |
                               SessionState  GameState  ExerciseState
                                                    |
                                            SessionPersistence
```

There are only four rules.

### Rule #1

```text
AppStore
    |
send(AppAction)
    |
validate transition
    |
mutate states
    |
persist if required
    |
publish changes
```

Nothing else may mutate the application state.

So this becomes our implementation contract.

```swift
store.send(.appLaunched)

------------

store.send(.topicSelected())

------------

store.send(.answerSubmitted())

------------

store.send(.pauseRequested)

------------

store.send(.resumeRequested)

------------

store.send(.quitRequested)
```

No ViewModel may do:

```swift
session.state = .completed

------------

xp += 150

------------

gameState = .gameOver
```

ever.

---

## Rule #2

Persistence Boundary

I REALLY like the AI's suggestion here.

> A saved `currentQuestion` always points to the next question to present.

I would adopt this completely.

```text
Question #5

↓

user answers

↓

checking

↓

correct

↓

+XP

↓

advance question

↓

persist snapshot

↓

Question #6


----------------------


App crashes


----------------------


restore session


----------------------


Question #6
```

Never:

```text
Question #5

↓

showing wrong answer

↓

persist

↓

restart

↓

Question #5
```

We don't care about UI recovery for the PoC.

Only question recovery matters.

This is probably the biggest simplification we've made.

---

## Rule #3

Mistake Queue

I would freeze it as:

```swift
struct MistakeQueue{

    var wordIDs:[String]

}
```

Rules:

```text
Wrong answer?

↓

already exists?

↓

YES

↓

ignore


----------------


NO

↓

add into queue


----------------


main lesson completed?

↓

NO

↓

continue


----------------


YES

↓

review round

↓

wrong again?

↓

record statistics

↓

DO NOT REQUEUE


----------------


queue empty?

↓

YES

↓

lesson completed
```

No duplicates.

No infinite loops.

No SRS.

No adaptive learning.

---

## Rule #4

Session Ownership

This is probably the last thing I would change.

Instead of:

```swift
Session{

    SessionState

    GameState

    ExerciseState

    SessionPersistence

}
```

I actually prefer:

```swift
struct Session{

    var state:SessionState

    var game:Game

    var persistence:SessionPersistence

}



struct Game{

    var state:GameState

    var exercise:ExerciseState

}
```

because:

```text
Session

↓

Game

↓

Exercise
```

makes more sense conceptually.

A session contains:

* a game
* persistence data
* lifecycle information

a game contains:

* current question lifecycle
* current exercise type

I think this is probably the cleanest ownership hierarchy we've produced.

---

## Final Architecture

```text
                    AppStore
                         |
                  send(AppAction)
                         |
        -----------------------------------------
        |                  |                     |
     AppState          UserState          VocabularyState
                                                 |
                                          ErrorPresentation?
                                                 |
                                             Session?
                                                 |
                                          SessionState
                                                 |
                                               Game
                                                 |
                                 -----------------------------
                                 |                           |
                            GameState                  ExerciseState
                                                 |
                                        SessionPersistence
```

with:

```text
Splash

↓

Home

↓

Topic Selection

↓

Game Session

↓

Score

↓

Home
```

and:

```text
Main Round

↓

Mistake Queue

↓

Review Round

↓

Completed

↓

Score Page
```

and:

```text
Cache

↓

Bundle

↓

API

↓

Error


(API is optional)
```

---

## One Last Suggestion

This is not architectural, but I would add one sentence to the document.

> ### Design Constraint
>
> The PoC intentionally prioritizes simplicity over completeness. When multiple implementation approaches are possible, preference should be given to the simpler solution unless it prevents future extensibility. Features required solely for future versions (AI-assisted learning, adaptive difficulty, social systems, cloud synchronization, monetization, and competitive gameplay) must not increase the complexity of the PoC implementation.

This sentence prevents another AI from doing things like:

* implementing spaced repetition,
* adding Redux-like middleware,
* introducing repositories and coordinators everywhere,
* persisting transient UI states,
* overengineering the mistake queue,
* making the backend mandatory.

---

## Final Recommendation

I would freeze the design now.

After four rounds of review, I don't see any remaining architectural problems. The unresolved items are all implementation-level clarifications that can be captured as short contracts in the document rather than prompting another redesign. The architecture has converged on:

* A single `AppStore` acting as the source of truth.
* Action-driven state transitions through `send(AppAction)`.
* Session-scoped lesson management (`Session` → `Game` → `Exercise`).
* Question-boundary persistence and recovery.
* A deterministic one-pass mistake review mechanism.
* Offline-first behaviour with bundled vocabulary as the guaranteed fallback.
* Clear separation between navigation state, lesson lifecycle state, question lifecycle state, and user progression.

At this point, additional review is more likely to introduce unnecessary complexity than to uncover substantive architectural issues. I would declare the architecture frozen and proceed to implementation.
