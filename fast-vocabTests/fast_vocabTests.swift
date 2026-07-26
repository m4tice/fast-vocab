//
//  fast_vocabTests.swift
//  fast-vocabTests
//
//  Created by Nguyen Duc Tuan on 26/7/26.
//

import Foundation
import Testing
@testable import fast_vocab

struct fast_vocabTests {

    @Test func topicRequiresThreeValidItems() {
        let validItems = (1...3).map { index in
            VocabularyItem(
                id: "word-\(index)",
                word: "Wort \(index)",
                article: "das",
                plural: "Worte \(index)",
                translations: ["word \(index)"]
            )
        }
        let topic = VocabularyTopic(
            id: "basics",
            name: "Basics",
            sourceLanguageCode: "de",
            targetLanguageCode: "en",
            items: validItems
        )

        #expect(topic.isUsable)
        #expect(!VocabularyTopic(
            id: "small",
            name: "Small",
            sourceLanguageCode: "de",
            targetLanguageCode: "en",
            items: Array(validItems.prefix(2))
        ).isUsable)
    }

    @Test func mistakeIdentifiersAreDeduplicatedInFirstOccurrenceOrder() {
        var statistics = LessonStatistics()

        statistics.recordMistake(vocabularyID: "table")
        statistics.recordMistake(vocabularyID: "chair")
        statistics.recordMistake(vocabularyID: "table")

        #expect(statistics.mistakeVocabularyIDs == ["table", "chair"])
    }

    @Test func lessonUsesAllExerciseTypesAndAwardsMainXP() throws {
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "session")

        #expect(session.persistence.mainQuestions.map(\.exerciseType) == [.article, .plural, .translation])
        #expect(session.persistence.hearts == 3)

        let result = try engine.submit(answer: " DER ", to: &session, topic: topic)

        #expect(result.isCorrect)
        #expect(session.persistence.statistics.earnedXP == 10)
        #expect(session.persistence.statistics.mainCorrect == 1)
    }

    @Test func textAnswersNormalizeUnicodeCaseAndWhitespace() throws {
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "normalization")

        _ = try engine.submit(answer: "der", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        let decomposedPlural = "STU\u{308}HLE"
        let plural = try engine.submit(answer: "  \(decomposedPlural)  ", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        let translation = try engine.submit(answer: " LAMP ", to: &session, topic: topic)

        #expect(plural.isCorrect)
        #expect(translation.isCorrect)
    }

    @Test func thirdWrongMainAnswerEndsLessonWithoutReview() throws {
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "session")

        for attempt in 0..<3 {
            let result = try engine.submit(answer: "wrong", to: &session, topic: topic)
            if attempt < 2 {
                #expect(!result.isTerminal)
                try engine.advance(&session, topic: topic)
            } else {
                #expect(result.isTerminal)
            }
        }

        #expect(session.state == .gameOver)
        #expect(session.persistence.hearts == 0)
        #expect(session.persistence.statistics.mainWrong == 3)
        #expect(session.persistence.statistics.mistakeVocabularyIDs.count == 3)
    }

    @Test func reviewIsOnePassAndDoesNotConsumeHeartsOrAwardXP() throws {
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "session")

        _ = try engine.submit(answer: "wrong", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        _ = try engine.submit(answer: "Stühle", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        _ = try engine.submit(answer: "lamp", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)

        #expect(session.persistence.phase == .review)
        #expect(session.persistence.reviewQuestions.count == 1)
        #expect(session.persistence.hearts == 2)
        #expect(session.persistence.statistics.earnedXP == 20)

        _ = try engine.submit(answer: "still wrong", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)

        #expect(session.state == .completed)
        #expect(session.persistence.reviewQuestions.count == 1)
        #expect(session.persistence.hearts == 2)
        #expect(session.persistence.statistics.reviewWrong == 1)
        #expect(session.persistence.statistics.earnedXP == 20)
    }

    @MainActor
    @Test func persistenceRoundTripsSessionAndCache() throws {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let topic = TestFixtures.topic()
        let session = try LessonEngine().createSession(topic: topic, sessionID: "recoverable")
        let catalog = VocabularyCatalog(schemaVersion: 1, topics: [topic])

        try repository.saveSession(session.persistence)
        try repository.saveCachedVocabulary(catalog)

        #expect(try repository.loadSession() == session.persistence)
        #expect(try repository.loadCachedVocabulary() == catalog)

        try repository.deleteSession()
        #expect(try repository.loadSession() == nil)
    }

    @MainActor
    @Test func terminalCommitMergesProgressOnceAndRemovesSession() throws {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "complete-once")

        for answer in ["der", "Stühle", "lamp"] {
            _ = try engine.submit(answer: answer, to: &session, topic: topic)
            try engine.advance(&session, topic: topic)
        }
        try repository.saveSession(session.persistence)

        let first = try repository.commitTerminalSession(session.persistence, completedAt: Date())
        let second = try repository.commitTerminalSession(session.persistence, completedAt: Date())

        #expect(first.accumulatedXP == 30)
        #expect(second.accumulatedXP == 30)
        #expect(second.lessonResults.count == 1)
        #expect(second.vocabularyStatistics["table"]?.correctAnswers == 1)
        #expect(second.vocabularyStatistics["chair"]?.correctAnswers == 1)
        #expect(try repository.loadSession() == nil)
    }

    @Test func vocabularyLoaderUsesCacheBeforeOtherSources() async throws {
        let cache = TestVocabularySource(catalog: VocabularyCatalog(schemaVersion: 1, topics: [TestFixtures.topic()]))
        let bundle = TestVocabularySource(catalog: VocabularyCatalog(schemaVersion: 1, topics: [TestFixtures.topic(id: "bundle")]))
        let loader = VocabularyLoader(cache: cache, bundle: bundle, api: EmptyVocabularySource())

        let loaded = try await loader.load()

        #expect(loaded.source == .cache)
        #expect(loaded.catalog.usableTopics.first?.id == "household")
    }

    @Test func vocabularyLoaderFallsBackToBundleWhenCacheIsInvalid() async throws {
        let invalid = VocabularyCatalog(schemaVersion: 1, topics: [])
        let bundle = VocabularyCatalog(schemaVersion: 1, topics: [TestFixtures.topic(id: "bundle")])
        let loader = VocabularyLoader(
            cache: TestVocabularySource(catalog: invalid),
            bundle: TestVocabularySource(catalog: bundle),
            api: EmptyVocabularySource()
        )

        let loaded = try await loader.load()

        #expect(loaded.source == .bundle)
        #expect(loaded.catalog.usableTopics.first?.id == "bundle")
    }

    @Test func vocabularyLoaderReportsErrorWhenEverySourceFails() async {
        let loader = VocabularyLoader(
            cache: EmptyVocabularySource(),
            bundle: EmptyVocabularySource(),
            api: EmptyVocabularySource()
        )

        await #expect(throws: VocabularyLoadingError.unavailable) {
            try await loader.load()
        }
    }

    @Test func vocabularyLoaderUsesAPIAfterLocalSourcesFail() async throws {
        let apiCatalog = VocabularyCatalog(schemaVersion: 1, topics: [TestFixtures.topic(id: "api")])
        let loader = VocabularyLoader(
            cache: EmptyVocabularySource(),
            bundle: TestThrowingVocabularySource(),
            api: TestVocabularySource(catalog: apiCatalog)
        )

        let loaded = try await loader.load()

        #expect(loaded.source == .api)
        #expect(loaded.catalog.usableTopics.first?.id == "api")
    }

    @Test func clientDecodesBackendVocabularyFixture() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let fixtureURL = repositoryRoot.appending(path: "backend/app/vocabulary.json")

        let catalog = try JSONDecoder().decode(VocabularyCatalog.self, from: Data(contentsOf: fixtureURL))

        #expect(catalog.schemaVersion == 1)
        #expect(catalog.usableTopics.count == 2)
    }

    @MainActor
    @Test func appStoreStartsPausesResumesAndCancelsOneLesson() throws {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let store = TestFixtures.store(repository: repository)
        TestFixtures.initialize(store)

        store.send(.startLessonRequested)
        #expect(store.appState == .topicSelection)
        store.send(.topicSelected("household"))
        #expect(store.appState == .game)
        #expect(store.session?.persistence.hearts == 3)

        store.send(.pauseRequested)
        #expect(store.appState == .home)
        #expect(store.session?.state == .paused)
        store.send(.resumeRequested)
        #expect(store.appState == .game)
        #expect(store.session?.state == .active)

        store.send(.cancelRequested)
        #expect(store.isCancelConfirmationPresented)
        store.send(.cancelConfirmed)
        #expect(store.appState == .home)
        #expect(store.session == nil)
        #expect(try repository.loadSession() == nil)
    }

    @MainActor
    @Test func appStoreCompletesLessonAndCommitsProgress() {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let store = TestFixtures.store(repository: repository)
        TestFixtures.initialize(store)
        store.send(.startLessonRequested)
        store.send(.topicSelected("household"))

        for answer in ["der", "Stühle", "lamp"] {
            store.send(.answerSubmitted(answer))
            store.send(.continueRequested)
        }

        #expect(store.appState == .score)
        #expect(store.userState.accumulatedXP == 30)
        #expect(store.userState.lessonResults.count == 1)
        store.send(.scoreDismissed)
        #expect(store.appState == .home)
        #expect(store.session == nil)
    }

    @MainActor
    @Test func invalidStoreActionsDoNotCreateIllegalState() {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let store = TestFixtures.store(repository: repository)
        TestFixtures.initialize(store)

        store.send(.answerSubmitted("der"))
        store.send(.pauseRequested)
        store.send(.scoreDismissed)

        #expect(store.appState == .home)
        #expect(store.session == nil)
        #expect(store.userState.accumulatedXP == 0)
    }

    @MainActor
    @Test func cancellationDuringReviewDiscardsStagedProgress() throws {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let store = TestFixtures.store(repository: repository)
        TestFixtures.initialize(store)
        store.send(.startLessonRequested)
        store.send(.topicSelected("household"))

        for answer in ["wrong", "Stühle", "lamp"] {
            store.send(.answerSubmitted(answer))
            store.send(.continueRequested)
        }
        #expect(store.session?.persistence.phase == .review)

        store.send(.cancelRequested)
        store.send(.cancelConfirmed)

        #expect(store.appState == .home)
        #expect(store.userState.accumulatedXP == 0)
        #expect(store.userState.lessonResults.isEmpty)
        #expect(try repository.loadSession() == nil)
    }

    @MainActor
    @Test func appStoreRestoresAtPersistedQuestionBoundary() throws {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "restore")
        _ = try engine.submit(answer: "der", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        try repository.saveSession(session.persistence)
        let store = TestFixtures.store(repository: repository)

        TestFixtures.initialize(store, snapshot: session.persistence)

        #expect(store.appState == .home)
        #expect(store.session?.persistence.nextQuestionIndex == 1)
        #expect(store.session?.game.state == .presenting)
        #expect(store.session?.game.exercise.question.vocabularyID == "chair")
    }

    @MainActor
    @Test func recoveryRestoresReviewHeartsStatisticsMistakesAndQueue() throws {
        let repository = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let topic = TestFixtures.topic()
        let engine = LessonEngine()
        var session = try engine.createSession(topic: topic, sessionID: "review-recovery")
        _ = try engine.submit(answer: "wrong", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        _ = try engine.submit(answer: "Stühle", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        _ = try engine.submit(answer: "lamp", to: &session, topic: topic)
        try engine.advance(&session, topic: topic)
        try repository.saveSession(session.persistence)
        let store = TestFixtures.store(repository: repository)

        TestFixtures.initialize(store, snapshot: session.persistence)

        #expect(store.session?.persistence.phase == .review)
        #expect(store.session?.persistence.hearts == 2)
        #expect(store.session?.persistence.statistics.mainWrong == 1)
        #expect(store.session?.persistence.statistics.mistakeVocabularyIDs == ["table"])
        #expect(store.session?.persistence.reviewQuestions.map(\.vocabularyID) == ["table"])
        #expect(store.session?.game.exercise.question.vocabularyID == "table")
    }

    @MainActor
    @Test func failedTerminalCommitCanBeRetried() {
        let backing = CoreDataRepository(controller: PersistenceController(inMemory: true))
        let persistence = FlakyTerminalRepository(backing: backing)
        let store = TestFixtures.store(repository: persistence)
        TestFixtures.initialize(store)
        store.send(.startLessonRequested)
        store.send(.topicSelected("household"))

        for answer in ["der", "Stühle", "lamp"] {
            store.send(.answerSubmitted(answer))
            store.send(.continueRequested)
        }

        #expect(store.appState == .game)
        #expect(store.errorPresentation?.recovery == .retryTerminalCommit)
        store.send(.retryTerminalCommit)
        #expect(store.appState == .score)
        #expect(store.userState.accumulatedXP == 30)
    }

}

struct TestVocabularySource: VocabularyCatalogSource {
    let catalog: VocabularyCatalog?

    func loadCatalog() async throws -> VocabularyCatalog? { catalog }
}

struct TestThrowingVocabularySource: VocabularyCatalogSource {
    func loadCatalog() async throws -> VocabularyCatalog? {
        throw VocabularyLoadingError.invalidResponse
    }
}

@MainActor
final class FlakyTerminalRepository: PersistenceRepository {
    private let backing: CoreDataRepository
    private var shouldFailCommit = true

    init(backing: CoreDataRepository) {
        self.backing = backing
    }

    func loadSession() throws -> SessionPersistence? { try backing.loadSession() }
    func saveSession(_ snapshot: SessionPersistence) throws { try backing.saveSession(snapshot) }
    func deleteSession() throws { try backing.deleteSession() }
    func loadUserProgress() throws -> UserProgress { try backing.loadUserProgress() }
    func loadCachedVocabulary() throws -> VocabularyCatalog? { try backing.loadCachedVocabulary() }
    func saveCachedVocabulary(_ catalog: VocabularyCatalog) throws { try backing.saveCachedVocabulary(catalog) }

    func commitTerminalSession(_ snapshot: SessionPersistence, completedAt: Date) throws -> UserProgress {
        if shouldFailCommit {
            shouldFailCommit = false
            throw PersistenceError.saveFailed
        }
        return try backing.commitTerminalSession(snapshot, completedAt: completedAt)
    }
}

enum TestFixtures {
    static func topic(id: String = "household") -> VocabularyTopic {
        VocabularyTopic(
            id: id,
            name: "Household",
            sourceLanguageCode: "de",
            targetLanguageCode: "en",
            items: [
                VocabularyItem(id: "table", word: "Tisch", article: "der", plural: "Tische", translations: ["table"]),
                VocabularyItem(id: "chair", word: "Stuhl", article: "der", plural: "Stühle", translations: ["chair"]),
                VocabularyItem(id: "lamp", word: "Lampe", article: "die", plural: "Lampen", translations: ["lamp"]),
            ]
        )
    }

    @MainActor
    static func store(repository: any PersistenceRepository) -> AppStore {
        AppStore(dependencies: AppDependencies(
            persistence: repository,
            vocabularyLoader: VocabularyLoader(
                cache: EmptyVocabularySource(),
                bundle: EmptyVocabularySource(),
                api: EmptyVocabularySource()
            )
        ))
    }

    @MainActor
    static func initialize(_ store: AppStore, snapshot: SessionPersistence? = nil) {
        let catalog = VocabularyCatalog(schemaVersion: 1, topics: [topic()])
        store.send(.initializationCompleted(
            UserProgress(),
            LoadedVocabulary(catalog: catalog, source: .bundle),
            snapshot
        ))
    }
}
