At this point, I don't really disagree with the AI anymore. What's interesting is that our discussion has shifted from "designing an app" to "designing an architecture". I think there's one final architectural improvement I would make, and then I would stop. Otherwise we'll enter architecture paralysis.

## I Would Reject One Thing

I don't like this anymore:

```swift
class AppStore{

    var appState: AppState

    var userState: UserState

    var sessionState: SessionState

    ...

}
```

because we're slowly reinventing Redux/TCA without its most important component.

We're missing this:

```swift
send()
```

I very much agree with this feedback:

```swift
enum AppAction{

    case appLaunched

    case topicSelected(String)

    case answerSubmitted(Answer)

    case pauseRequested

    case resumeRequested

    case quitRequested

    ....

}


func send(_ action: AppAction)
```

I would go even further.

```swift
@Observable

final class AppStore{

    private(set) var appState:AppState

    private(set) var userState:UserState

    private(set) var vocabularyState:VocabularyState

    private(set) var session:Session?

    private(set) var errorPresentation:ErrorPresentation?



    func send(_ action:AppAction){

        ....
    }

}
```

Notice something disappeared.

```swift
SessionState

GameState

ExerciseState
```

I don't think they belong directly under AppStore.

Instead I prefer:

```swift
struct Session{

    var sessionState:SessionState

    var gameState:GameState

    var exerciseState:ExerciseState

    var persistence:SessionPersistence

}
```

which gives us:

```text
                AppStore
                    |
       --------------------------------
       |               |              |
    AppState        UserState      Vocabulary
                                      |
                                  Session?
                                      |
                              ----------------
                              |              |
                        SessionState      Persistence
                              |
                          GameState
                              |
                        ExerciseState


                             |
                       ErrorPresentation
```

This ownership makes much more sense to me.

There is no reason for:

```swift
Home Page
```

to know about:

```swift
GameState
```

or

```swift
ExerciseState
```

they should only exist if:

```swift
session != nil
```

---

## I Would Simplify Recovery

I think we're overengineering this.

For PoC:

```swift
enum SessionPhase{

    case main

    case mistakeReview

}
```

that's enough.

I don't think we need:

```swift
answer submitted

showing answer

selected answer

etc...
```

to be persisted.

If the application dies here:

```text
Question #7

Katze

DER

DIE

DAS
```

I don't really care if we restart from:

```text
Question #7
```

instead of:

```text
Katze selected

↓

showing wrong answer

↓

continue button
```

The user loses 2 seconds.

So I would explicitly state:

> The PoC guarantees lesson recovery at the question boundary only. Intermediate UI states are intentionally not persisted.

Which greatly simplifies:

```swift
struct SessionPersistence{

    var sessionID:String

    var topicID:String

    var phase:SessionPhase

    var questionIDs:[String]

    var reviewQueue:[String]

    var currentQuestion:Int

    var hearts:Int

    var correct:Int

    var wrong:Int

    var xp:Int

    var status:SessionState

    var timestamp:Date

}
```

I think this is enough.

---

## Mistake Review Rules

I would make them deterministic.

```text
Question wrong?

↓

add into review queue

↓

main lesson finished?

↓

NO

↓

continue

----------------------

YES

↓

review queue empty?

↓

NO

↓

start review round

↓

question wrong again?

↓

record statistics

↓

DO NOT REQUEUE

↓

next question

↓

review queue finished

↓

lesson completed
```

Rules:

```text
Only once.

No duplicates.

No infinite loops.

No adaptive learning.

No SRS.
```

Extremely simple.

---

## Backend Design

I actually disagree with the feedback here.

This:

```text
Cache

↓

Bundle

↓

API

↓

Error
```

is NOT wrong.

Because I intentionally made the API useless for the PoC.

I don't think:

```text
FastAPI
```

should be a startup dependency at all.

I would change the document to say:

> The FastAPI backend exists solely to validate the future client-server architecture and is not required for application startup during the PoC.

Meaning:

```text
Startup


        Cache?
       /     \
     YES      NO
     |         |
    USE      Bundle?
             /   \
           YES    NO
            |      |
           USE    API
                    |
                 Success?
                  /  \
                YES   NO
                 |     |
               USE    Error
```

and after startup:

```text
               Home
                 |
          Background Task
                 |
              API?
               |
            Success?
             /   \
           YES    NO
           |      |
      Update Cache Ignore
```

So:

```text
API unavailable

↓

zero impact

↓

PoC still works
```

which I quite like.

---

## Final Change

This is probably my favourite suggestion from all three reviews.

Instead of:

```swift
var appState

var sessionState

var gameState

....

```

we should move towards:

```swift
store.send()
```

everything.

For example:

```swift
store.send(

    .topicSelected("Food")

)

------------

store.send(

    .answerSubmitted(answer)

)

------------

store.send(

    .pauseRequested

)

------------

store.send(

    .resumeRequested

)

------------

store.send(

    .quitRequested

)
```

and only:

```swift
AppStore
```

may mutate:

```swift
UserState

Session

Vocabulary

AppState

etc...
```

No ViewModel should ever do:

```swift
sessionState = .completed

gameState = .gameOver

xp += 150
```

directly.

Everything goes through:

```swift
send()
```

which automatically gives us:

```text
atomic updates

+

legal transitions

+

recovery

+

persistence

+

validation

+
future cloud sync
```

## My Final Recommendation

After four rounds of architectural review, I would stop here and freeze the design.

The architecture I would hand to another AI is:

1. `AppStore` is the single source of truth.
2. All mutations happen through `send(AppAction)`.
3. `Session` is its own aggregate containing `SessionState`, `GameState`, `ExerciseState`, and `SessionPersistence`.
4. `GameState` models question lifecycle; `ExerciseState` models question type.
5. Lesson recovery is supported only at question boundaries.
6. Mistake review is deterministic: one review round, no duplicates, no requeueing.
7. Vocabulary loading follows `Cache → Bundle → API → Error`, and the API is intentionally non-critical for the PoC.
8. Intermediate UI states are not persisted.
9. `AppStore` coordinates all state domains and enforces legal transitions.

At this stage, I would consider the architecture sufficiently specified for autonomous implementation. Further refinement is likely to yield diminishing returns and increase complexity without materially improving the PoC. The remaining decisions are implementation details rather than architectural gaps.
