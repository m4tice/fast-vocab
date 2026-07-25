I think we're still missing one state. If we want this to evolve into Duolingo-like behaviour later, I would separate the navigation state from the game state. The Game Page itself is actually a state machine.

The complete PoC would look like this:

```text
Application State Machine

                    APP START
                        |
                        |
                     Splash
                        |
                 Initialization
                        |
                 Load User State
                        |
                 Load Vocabulary
                        |
                   Success?
                    /    \
                  No      Yes
                  |        |
                Error     Home
                           |
                      Select Topic
                           |
                         Topic
                           |
                     Press START
                           |
                    Create Session
                           |
                          Game
                           |
                     Finish Lesson?
                     /           \
                   No             Yes
                   |               |
               Continue           Score
                   |               |
                   |            Update XP
                   |            Save Progress
                   |               |
                   -----------------
                           |
                         Home
```

The Game Page itself should have its own state machine.

```mermaid
stateDiagram-v2

    [*] --> Loading

    Loading --> GenerateQuestion

    GenerateQuestion --> Article
    GenerateQuestion --> Plural
    GenerateQuestion --> Translation

    Article --> Checking
    Plural --> Checking
    Translation --> Checking

    Checking --> Correct
    Checking --> Wrong

    Correct --> UpdateXP
    UpdateXP --> NextQuestion

    Wrong --> RemoveHeart

    RemoveHeart --> NextQuestion : Hearts > 0
    RemoveHeart --> GameOver : Hearts == 0

    NextQuestion --> GenerateQuestion : Questions Remaining
    NextQuestion --> Completed : No Questions Remaining

    Completed --> [*]

    GameOver --> [*]
```

The User State should also be independent.

```mermaid
stateDiagram-v2

    [*] --> NewUser

    NewUser --> ActiveUser

    ActiveUser --> GainXP
    ActiveUser --> CompleteTopic
    ActiveUser --> UpdateStatistics

    GainXP --> LevelUp
    GainXP --> ActiveUser

    LevelUp --> ActiveUser

    CompleteTopic --> ActiveUser

    UpdateStatistics --> ActiveUser

    ActiveUser --> SaveProgress

    SaveProgress --> ActiveUser
```

For the whole application, I would model it as follows:

```mermaid
stateDiagram-v2

    [*] --> Splash

    Splash --> Initialization

    Initialization --> Home

    Home --> TopicSelection
    Home --> ResumeLesson

    TopicSelection --> GameSession
    ResumeLesson --> GameSession


    state GameSession{

        [*] --> Loading

        Loading --> GenerateQuestion

        GenerateQuestion --> Article
        GenerateQuestion --> Plural
        GenerateQuestion --> Translation

        Article --> Checking
        Plural --> Checking
        Translation --> Checking

        Checking --> Correct
        Checking --> Wrong

        Correct --> UpdateXP
        UpdateXP --> NextQuestion

        Wrong --> RemoveHeart

        RemoveHeart --> NextQuestion : Hearts > 0
        RemoveHeart --> GameOver : Hearts == 0

        NextQuestion --> GenerateQuestion : Remaining Questions
        NextQuestion --> Completed : Lesson Finished

    }


    GameSession --> ScorePage : Completed
    GameSession --> ScorePage : GameOver

    ScorePage --> SaveProgress

    SaveProgress --> Home

    Home --> [*]
```

### Proposed Models

| State Machine   | Responsibility                 |
| --------------- | ------------------------------ |
| AppState        | Navigation between pages       |
| GameState       | Lesson lifecycle               |
| UserState       | XP, level and statistics       |
| SessionState    | Current lesson progress        |
| ExerciseState   | Current question state         |
| VocabularyState | Vocabulary loading and caching |

I would add one more state that wasn't present in the previous document:

```swift
enum SessionState{

    case preparing
    case active
    case paused
    case completed
    case gameOver
    case saving
}
```

This might look unnecessary for the PoC, but it solves two future problems immediately:

* Resume unfinished lessons.
* Synchronization with cloud storage later.
* Daily challenges.
* Multiplayer challenges.
* Session recovery after application termination.

So my recommendation is to have **five independent state machines** instead of one giant one:

1. AppState (navigation).
2. GameState (exercise flow).
3. SessionState (lesson lifecycle).
4. UserState (user progression).
5. VocabularyState (content loading and caching).

Keeping them independent will make the SwiftUI implementation considerably cleaner and aligns well with MVVM and future feature additions without requiring the entire state model to be redesigned.
