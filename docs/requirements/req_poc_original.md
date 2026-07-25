# fastVocab

## Proof of Concept (PoC) Technical Design Document

> Version: 1.0
> Status: Approved for PoC Implementation
> Client: iOS (SwiftUI)
> Backend: Python (FastAPI)
> Architecture: MVVM + Local First Design

---

# 1. Project Overview

fastVocab is a Duolingo-inspired vocabulary learning application focusing on grammatical articles and plural forms.

The initial target language is German. The architecture must remain language-agnostic to support future languages without requiring changes to the exercise engine.

Examples:

* German

  * der Hund
  * die Katze
  * das Buch

Future possibilities:

* French

  * le
  * la
* Spanish

  * el
  * la
* Italian

  * il
  * lo
  * la

The PoC intentionally removes complex infrastructure requirements to validate the core learning experience before introducing social features, AI capabilities or monetization.

---

# 2. Scope

## Included

### Learning

* Article exercises
* Plural exercises
* Mixed exercises
* Topic based learning

### Gamification

* XP system
* Hearts system (3 lives)
* Accuracy score
* Mistake review

### Persistence

* Local progress saving
* Local XP saving
* Local topic completion tracking

### Content

* JSON vocabulary packs
* German language only
* Curated vocabulary

### Technical

* SwiftUI
* MVVM architecture
* FastAPI backend
* Core Data local storage
* Async networking

---

## Excluded

### AI

* AI generated vocabulary
* AI assisted exercises
* Adaptive AI difficulty

### Social

* Authentication
* Friends
* Leaderboards
* Challenges
* Sharing

### Monetization

* Subscription
* In-App Purchases
* Advertisements

### Infrastructure

* Cloud synchronization
* Multi-device synchronization
* Database requirements

---

# 3. Design Philosophy

The application follows four principles.

### Principle 1

The exercise engine must remain language independent.

Adding a language should only require:

* JSON content
* Language rule configuration

No business logic modification should be necessary.

### Principle 2

The client owns the learning logic.

Examples:

* XP calculations
* Hearts
* Exercise generation
* Progress tracking
* Score calculation

The backend should only provide vocabulary content.

### Principle 3

Offline first design.

The application should continue functioning if:

* internet is unavailable
* backend is unavailable

Vocabulary packs should be cached locally.

### Principle 4

Keep the PoC intentionally small.

The objective is validating whether:

* article exercises are enjoyable
* plural exercises are enjoyable
* gamification improves retention

Everything else is considered secondary.

---

# 4. High Level Architecture

```text
                    fastVocab

                      SwiftUI
                         |
                        MVVM
                         |
              -------------------------
              |            |            |
            Topic        Game         Score
            Module      Module        Module
                           |
                     Exercise Engine
                           |
                -------------------------
                |            |            |
              Article      Plural       Mixed
                           |
                     State Manager
                           |
                  -------------------
                  |                 |
             Local Storage       API Layer
                  |                 |
               Core Data         FastAPI
                                    |
                              Vocabulary API
                                    |
                             JSON Vocabulary
```

---

# 5. Application Pages

Only five pages are required.

```text
1. Splash Page
2. Home Page
3. Topic Page
4. Game Page
5. Score Page
```

No additional pages should exist during the PoC.

---

# 6. Navigation Flow

```text
               Splash
                  |
                  |
                Home
                  |
             Topic Page
                  |
                 Start
                  |
               Game
                  |
           ------------------
           |                |
        Quit            Finished
           |                |
         Home             Score
                             |
                        Continue
                             |
                           Home
```

---

# 7. Page Design

## Splash Page

Responsibilities:

* initialize application
* load cached vocabulary
* initialize user progress

Displays:

```text
--------------------------

        fastVocab

       Loading...

--------------------------
```

---

## Home Page

Displays:

```text
--------------------------------

          fastVocab

        XP : 350

       Level : 5

--------------------------------

      Continue Learning

--------------------------------

          German A1

            15/50

--------------------------------

          Statistics

        Accuracy : 87%

       Learned : 153

--------------------------------
```

Responsibilities:

* display user progress
* display XP
* display statistics
* navigate to topics

---

## Topic Page

Displays:

```text
----------------------------

          German A1

----------------------------

      Food (15 words)

           START

----------------------------

     Animals (20 words)

           START

----------------------------

      Travel (Locked)

----------------------------

            HOME

----------------------------
```

Responsibilities:

* topic selection
* difficulty selection
* lesson initialization

---

## Game Page

Three exercise types are supported.

### Article

```text
-----------------------

         Apfel

         DER

         DIE

         DAS

-----------------------

      Hearts ♥♥♥

        XP : 150

-----------------------
```

---

### Plural

```text
-----------------------

         Hund

       Plural?

       _______

        CHECK

-----------------------

       Hearts ♥♥

-----------------------
```

---

### Mixed

The exercise engine decides:

```text
50%
Article

30%
Plural

20%
Translation Recall
```

Responsibilities:

* question rendering
* answer validation
* XP calculation
* hearts calculation
* progression management

---

## Score Page

Displays:

```text
--------------------------

          GREAT!

         +150 XP

--------------------------

       Correct : 18

        Wrong : 2

      Accuracy : 90%

--------------------------

      Mistakes Review

       Katze
     -> die Katze

       Hund
     -> Hunde

--------------------------

         Continue

--------------------------
```

Responsibilities:

* calculate score
* review mistakes
* update user progress

---

# 8. State Management

## Application State

```swift
enum AppState{

    case splash
    case home
    case topic
    case game
    case score

}
```

---

## Game State

```swift
enum GameState{

    case loading

    case article

    case plural

    case mixed

    case checking

    case correct

    case wrong

    case nextQuestion

    case completed

    case gameOver

}
```

---

## User State

```swift
struct UserState{

    var xp:Int

    var level:Int

    var hearts:Int

    var accuracy:Double

    var completedTopics:[Topic]

}
```

---

## Exercise State

```swift
struct ExerciseState{

    var currentWord:Word

    var answer:String

    var isCorrect:Bool

    var remainingWords:Int

    var mistakes:Int

}
```

---

# 9. State Transition Model

```text
            Start

              |
          Splash State
              |
             Home
              |
            Topic
              |
             Game
              |
       --------------------
       |                  |
    Wrong              Correct
       |                  |
    Lose Heart          Gain XP
       |                  |
       --------------------
                  |
             Next Question
                  |
            More Questions?
                 / \
               Yes  No
               /     \
            Continue  Score
                         |
                       Home
```

---

# 10. Vocabulary JSON Format

```json
{
    "language":"German",

    "topic":"Food",

    "difficulty":"A1",

    "words":[

        {

            "word":"Apfel",

            "article":"der",

            "plural":"Apfel",

            "translation":"Apple",

            "difficulty":1

        },

        {

            "word":"Katze",

            "article":"die",

            "plural":"Katzen",

            "translation":"Cat",

            "difficulty":1

        }

    ]
}
```

---

# 11. Language Configuration

Future language packs should support:

```json
{
    "language":"German",

    "articles":[

        "der",
        "die",
        "das"

    ]
}
```

Examples:

```text
German
--------
der
die
das

French
--------
le
la

Spanish
---------
el
la

Italian
---------
il
lo
la
```

The exercise engine must dynamically render the available choices.

---

# 12. Backend Design

FastAPI responsibilities:

```text
           FastAPI

              |
        ----------------
        |              |
      Topics          Deck
        |              |
    /topics        /deck/{id}
                      |
                  Vocabulary
                     JSON
```

Endpoints:

```text
GET /topics

GET /deck/{id}

GET /languages

GET /health
```

No database is required during the PoC.

JSON files act as the content source.

---

# 13. Core Data Responsibilities

Store locally:

```text
User XP

User Level

Completed Topics

Accuracy

Mistakes

Cached Vocabulary

Game Progress

Current Session
```

Cloud synchronization is intentionally excluded.

---

# 14. XP System

Initial implementation:

```text
Correct Answer

+10 XP

-----------------

Perfect Lesson

+50 XP

-----------------

Topic Completion

+100 XP
```

Values may change later.

---

# 15. Hearts System

```text
Maximum Hearts

3

-----------------

Wrong Answer

-1 Heart

-----------------

No Hearts

Game Over

-----------------

Finish Lesson

Reset Hearts
```

Future regeneration mechanics are excluded.

---

# 16. Future Extensions

The architecture intentionally allows:

```text
Version 2

- Authentication
- Leaderboards
- Friends
- Challenges
- Daily Streak
- Achievements
- Monetization

----------------------

Version 3

- AI generated content
- AI assisted exercises
- Adaptive difficulty
- Voice pronunciation
- Speech recognition

----------------------

Version 4

- Multi-language support
- Cloud synchronization
- Competitive learning
```

No architectural changes should be necessary to support these additions.

---

# 17. Implementation Requirements

The implementing AI must follow the following requirements.

### Required

* SwiftUI
* MVVM
* FastAPI
* Core Data
* Async/Await
* Local first design

### Forbidden

* Authentication
* Databases
* Social features
* AI integrations
* Third-party dependencies unless justified

### Constraints

* Only five pages are allowed.
* The exercise engine must remain language independent.
* Vocabulary must be JSON driven.
* Business logic must remain on the client.
* Backend is content serving only.
* The application must support offline usage after vocabulary caching.

---

# 18. Final PoC Definition

The objective of the PoC is not building a complete language learning platform.

The objective is validating the following assumptions:

1. Article exercises are engaging.
2. Plural exercises are effective.
3. Simple gamification improves retention.
4. JSON driven vocabulary packs are sufficiently extensible.
5. A language independent exercise engine is achievable.
6. The selected architecture is suitable for future expansion.

Success is defined by validating the learning loop rather than implementing production-scale infrastructure.

> PoC Scope Summary
>
> * German language only
> * Five application pages
> * Article exercises
> * Plural exercises
> * Mixed exercises
> * XP system
> * Hearts system
> * Local persistence
> * JSON vocabulary packs
> * SwiftUI + MVVM
> * FastAPI backend
> * Offline-capable client design
>
> Everything else is intentionally deferred.
