Build the fastVocab PoC in this workspace.

Use docs/requirements/req_poc_final.md as the authoritative product specification.
Use the frozen architecture:
- AppStore is the single source of truth.
- All mutations go through send(AppAction).
- Session owns SessionState, Game, and SessionPersistence.
- Game owns GameState and ExerciseState.
- Recovery occurs only at question boundaries.
- Mistake review is one-pass, deduplicated, and never requeues mistakes.
- Vocabulary loading follows Cache -> Bundle -> API -> Error.
- FastAPI is optional and must never be required for startup or gameplay.

Tech stack:
- SwiftUI iOS client
- Swift and Swift Concurrency
- Core Data for persistence
- Python FastAPI backend
- JSON vocabulary content

Implement the complete PoC:
- Splash
- Home
- Topic Selection
- Game
- Score
- Article, plural, and translation exercises
- Pause, resume, cancel, completion, game over, and recovery
- User progress and lesson persistence
- Offline operation with bundled vocabulary
- Optional FastAPI vocabulary loading
- Unit tests for the state reducer, exercise validation, scoring, mistake review, and recovery
- UI tests for the main lesson flow

Do not implement authentication, social features, leaderboards, monetization, cloud synchronization, AI, adaptive learning, SRS, or competitive gameplay.

When the requirements leave an implementation detail unspecified, choose the simplest reasonable behavior, document the choice, and continue. Do not expand the product scope.
Work in phases, run tests after each phase, and report any assumptions.