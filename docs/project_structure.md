# fastVocab PoC Project Structure

Status: Frozen for PoC implementation  
Authority: `docs/requirements/req_poc_final.md` v1.4

## 1. Repository Layout

```text
fast-vocab/
|- fast-vocab.xcodeproj/
|- fast-vocab/
|  |- App/
|  |  |- FastVocabApp.swift
|  |  |- AppStore.swift
|  |  |- AppAction.swift
|  |  |- AppState.swift
|  |  `- AppDependencies.swift
|  |- Domain/
|  |  |- VocabularyModels.swift
|  |  |- SessionModels.swift
|  |  |- GameModels.swift
|  |  |- UserProgressModels.swift
|  |  `- LessonEngine.swift
|  |- Features/
|  |  |- Splash/
|  |  |  |- SplashView.swift
|  |  |  `- SplashViewModel.swift
|  |  |- Home/
|  |  |  |- HomeView.swift
|  |  |  `- HomeViewModel.swift
|  |  |- TopicSelection/
|  |  |  |- TopicSelectionView.swift
|  |  |  `- TopicSelectionViewModel.swift
|  |  |- Game/
|  |  |  |- GameView.swift
|  |  |  |- GameViewModel.swift
|  |  |  |- ArticleExerciseView.swift
|  |  |  |- TextExerciseView.swift
|  |  |  `- AnswerFeedbackView.swift
|  |  `- Score/
|  |     |- ScoreView.swift
|  |     `- ScoreViewModel.swift
|  |- Persistence/
|  |  |- FastVocab.xcdatamodeld/
|  |  |- PersistenceController.swift
|  |  |- SessionRepository.swift
|  |  |- UserProgressRepository.swift
|  |  |- VocabularyCacheRepository.swift
|  |  `- CoreDataMappers.swift
|  |- Services/
|  |  |- VocabularyLoader.swift
|  |  |- BundleVocabularySource.swift
|  |  |- APIVocabularySource.swift
|  |  `- APIClient.swift
|  |- Resources/
|  |  `- vocabulary.json
|  `- Assets.xcassets/
|- fast-vocabTests/
|  |- AppStoreTests.swift
|  |- LessonEngineTests.swift
|  |- ExerciseValidationTests.swift
|  |- ReviewQueueTests.swift
|  |- VocabularyLoaderTests.swift
|  |- PersistenceTests.swift
|  `- TestFixtures.swift
|- fast-vocabUITests/
|  |- PrimaryLessonFlowUITests.swift
|  `- RecoveryFlowUITests.swift
|- backend/
|  |- app/
|  |  |- __init__.py
|  |  |- main.py
|  |  |- models.py
|  |  `- vocabulary.json
|  |- tests/
|  |  `- test_api.py
|  `- requirements.txt
`- docs/
   |- requirements/
   |- demands/
   |- states/
   |- architecture.md
   |- design.md
   |- state_model.md
   |- project_structure.md
   |- implementation_plan.md
   `- assumptions.md
```

## 2. Ownership by Directory

### App

Owns composition, navigation state, dependency injection, `AppStore`, and the action entry point. No feature may bypass this layer to mutate domain state.

### Domain

Contains plain Swift models and deterministic lesson behavior. It imports Foundation only where practical and does not import SwiftUI or Core Data.

### Features

Contains exactly the five required pages and small view models. Exercise subviews are components of Game, not additional pages.

### Persistence

Contains Core Data setup, managed model, repositories, and mapping between managed records and domain values. Core Data types do not escape repositories.

### Services

Contains vocabulary source orchestration and optional networking. Source implementations conform to small protocols used by the loader.

### Resources

Contains curated bundled vocabulary that guarantees offline startup and lessons with all three exercise types.

### Backend

Contains an independent optional FastAPI process with health and read-only vocabulary endpoints. The iOS target has no build or runtime dependency on this directory.

## 3. Target Membership

* Production Swift files and bundled JSON belong to the `fast-vocab` target.
* Unit test files belong only to `fast-vocabTests` and use `@testable import fast_vocab` according to the generated module name.
* UI test files belong only to `fast-vocabUITests`.
* Documentation and backend files belong to no Xcode target.

The project currently uses Xcode file-system-synchronized groups, so files added under the synchronized target directories should be discovered automatically. Target membership and resource copying must still be verified in Xcode build output.

## 4. Existing Scaffold Migration

The generated `ContentView.swift`, `Item.swift`, and SwiftData container are placeholders. Phase 2 replaces them with the app root, `AppStore`, and Core Data stack. No migration of placeholder `Item` data is required because it is not product data.

## 5. Naming Rules

* Domain types use product terms from the requirement specification.
* Protocols describe a capability, such as `SessionRepository`.
* Concrete Core Data implementations may use a `CoreData` prefix when disambiguation is needed.
* Views end in `View`; page adapters end in `ViewModel`.
* Test file names match the behavior or production type under test.

## 6. Dependency Direction

```text
Features -> App -> Domain
App -> Services -> Domain
App -> Persistence -> Domain
Persistence -> Core Data
Services -> URLSession / Bundle
```

Domain never depends on Features, SwiftUI, Core Data, or FastAPI. Persistence and services never navigate or mutate `AppStore` directly; they return values or throw errors.
