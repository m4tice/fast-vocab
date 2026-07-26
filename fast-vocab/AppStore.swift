import Foundation
import Observation

enum AppState: Equatable {
    case splash
    case home
    case topicSelection
    case game
    case score
}

enum VocabularyState: Equatable {
    case idle
    case loading(VocabularySource)
    case loaded(VocabularyCatalog, VocabularySource)
    case unavailable
}

struct ErrorPresentation: Identifiable, Equatable {
    enum Recovery: Equatable {
        case retryInitialization
        case retryTerminalCommit
    }

    let id = UUID()
    let message: String
    let recovery: Recovery?
}

enum AppAction {
    case appLaunched
    case retryInitialization
    case initializationCompleted(UserProgress, LoadedVocabulary, SessionPersistence?)
    case initializationFailed
    case startLessonRequested
    case topicSelected(String)
    case answerSubmitted(String)
    case continueRequested
    case pauseRequested
    case resumeRequested
    case cancelRequested
    case cancelConfirmed
    case cancelDismissed
    case scoreDismissed
    case appMovedToBackground
    case retryTerminalCommit
    case dismissError
}

@MainActor
struct AppDependencies {
    let persistence: any PersistenceRepository
    let vocabularyLoader: VocabularyLoader
    var lessonEngine = LessonEngine()
}

@MainActor
@Observable
final class AppStore {
    private(set) var appState: AppState = .splash
    private(set) var userState = UserProgress()
    private(set) var vocabularyState: VocabularyState = .idle
    private(set) var session: Session?
    private(set) var errorPresentation: ErrorPresentation?
    private(set) var lastEvaluation: AnswerEvaluation?
    private(set) var isCancelConfirmationPresented = false

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func send(_ action: AppAction) {
        switch action {
        case .appLaunched, .retryInitialization:
            beginInitialization()
        case let .initializationCompleted(progress, loaded, snapshot):
            finishInitialization(progress: progress, loaded: loaded, snapshot: snapshot)
        case .initializationFailed:
            vocabularyState = .unavailable
            errorPresentation = ErrorPresentation(
                message: "Vocabulary is unavailable. Check the bundled data or try again.",
                recovery: .retryInitialization
            )
        case .startLessonRequested:
            guard appState == .home, session == nil, !usableTopics.isEmpty else { return }
            appState = .topicSelection
        case let .topicSelected(id):
            startLesson(topicID: id)
        case let .answerSubmitted(answer):
            submit(answer: answer)
        case .continueRequested:
            continueLesson()
        case .pauseRequested:
            pauseLesson()
        case .resumeRequested:
            resumeLesson()
        case .cancelRequested:
            guard appState == .game, session != nil else { return }
            isCancelConfirmationPresented = true
        case .cancelConfirmed:
            cancelLesson()
        case .cancelDismissed:
            isCancelConfirmationPresented = false
        case .scoreDismissed:
            guard appState == .score else { return }
            session = nil
            lastEvaluation = nil
            appState = .home
        case .appMovedToBackground:
            saveCurrentBoundaryIfPossible()
        case .retryTerminalCommit:
            guard let session, session.state == .completed || session.state == .gameOver else { return }
            errorPresentation = nil
            finishTerminalSession(session)
        case .dismissError:
            errorPresentation = nil
        }
    }

    var usableTopics: [VocabularyTopic] {
        guard case let .loaded(catalog, _) = vocabularyState else { return [] }
        return catalog.usableTopics
    }

    var currentTopic: VocabularyTopic? {
        guard let topicID = session?.persistence.topicID else { return nil }
        return usableTopics.first { $0.id == topicID }
    }

    var currentVocabularyItem: VocabularyItem? {
        guard let vocabularyID = session?.game.exercise.question.vocabularyID else { return nil }
        return currentTopic?.items.first { $0.id == vocabularyID }
    }

    private func beginInitialization() {
        appState = .splash
        vocabularyState = .loading(.cache)
        errorPresentation = nil
        Task { @MainActor in
            do {
                let progress = (try? dependencies.persistence.loadUserProgress()) ?? UserProgress()
                let snapshot: SessionPersistence?
                do {
                    snapshot = try dependencies.persistence.loadSession()
                } catch {
                    snapshot = nil
                    try? dependencies.persistence.deleteSession()
                }
                let loaded = try await dependencies.vocabularyLoader.load()
                if loaded.source == .api {
                    try? dependencies.persistence.saveCachedVocabulary(loaded.catalog)
                }
                send(.initializationCompleted(progress, loaded, snapshot))
            } catch {
                send(.initializationFailed)
            }
        }
    }

    private func finishInitialization(
        progress: UserProgress,
        loaded: LoadedVocabulary,
        snapshot: SessionPersistence?
    ) {
        userState = progress
        vocabularyState = .loaded(loaded.catalog, loaded.source)
        session = nil

        if let snapshot,
           let topic = loaded.catalog.usableTopics.first(where: { $0.id == snapshot.topicID }),
           let restored = try? dependencies.lessonEngine.restoreSession(from: snapshot, topic: topic) {
            session = restored
        } else if snapshot != nil {
            try? dependencies.persistence.deleteSession()
            errorPresentation = ErrorPresentation(
                message: "The interrupted lesson could not be restored and was discarded.",
                recovery: nil
            )
        }
        appState = .home
    }

    private func startLesson(topicID: String) {
        guard appState == .topicSelection,
              session == nil,
              let topic = usableTopics.first(where: { $0.id == topicID }) else { return }
        do {
            let created = try dependencies.lessonEngine.createSession(topic: topic)
            try dependencies.persistence.saveSession(created.persistence)
            session = created
            appState = .game
        } catch {
            presentPersistenceError()
        }
    }

    private func submit(answer: String) {
        guard appState == .game, var activeSession = session, let topic = currentTopic else { return }
        do {
            let evaluation = try dependencies.lessonEngine.submit(answer: answer, to: &activeSession, topic: topic)
            session = activeSession
            lastEvaluation = evaluation
            if evaluation.isTerminal {
                finishTerminalSession(activeSession)
            }
        } catch {
            errorPresentation = ErrorPresentation(message: "The answer could not be checked.", recovery: nil)
        }
    }

    private func continueLesson() {
        guard appState == .game, var activeSession = session, let topic = currentTopic else { return }
        do {
            try dependencies.lessonEngine.advance(&activeSession, topic: topic)
            session = activeSession
            lastEvaluation = nil
            if activeSession.state == .completed {
                finishTerminalSession(activeSession)
            } else {
                try dependencies.persistence.saveSession(activeSession.persistence)
            }
        } catch {
            presentPersistenceError()
        }
    }

    private func pauseLesson() {
        guard appState == .game, var activeSession = session, activeSession.game.state == .presenting else { return }
        activeSession.state = .paused
        activeSession.persistence.state = .paused
        do {
            try dependencies.persistence.saveSession(activeSession.persistence)
            session = activeSession
            appState = .home
        } catch {
            presentPersistenceError()
        }
    }

    private func resumeLesson() {
        guard appState == .home, var pausedSession = session,
              pausedSession.state == .paused || pausedSession.state == .active,
              let topic = currentTopic else { return }
        pausedSession.state = .active
        pausedSession.persistence.state = .active
        do {
            let restored = try dependencies.lessonEngine.restoreSession(from: pausedSession.persistence, topic: topic)
            try dependencies.persistence.saveSession(restored.persistence)
            session = restored
            appState = .game
        } catch {
            presentPersistenceError()
        }
    }

    private func cancelLesson() {
        guard session != nil else { return }
        do {
            try dependencies.persistence.deleteSession()
            session = nil
            lastEvaluation = nil
            isCancelConfirmationPresented = false
            appState = .home
        } catch {
            presentPersistenceError()
        }
    }

    private func finishTerminalSession(_ terminalSession: Session) {
        do {
            userState = try dependencies.persistence.commitTerminalSession(
                terminalSession.persistence,
                completedAt: Date()
            )
            session = terminalSession
            appState = .score
        } catch {
            errorPresentation = ErrorPresentation(
                message: "Progress could not be saved. Retry to finish the lesson.",
                recovery: .retryTerminalCommit
            )
        }
    }

    private func saveCurrentBoundaryIfPossible() {
        guard let session, session.game.state == .presenting,
              session.state == .active || session.state == .paused else { return }
        do {
            try dependencies.persistence.saveSession(session.persistence)
        } catch {
            presentPersistenceError()
        }
    }

    private func presentPersistenceError() {
        errorPresentation = ErrorPresentation(message: "Progress could not be saved. Please try again.", recovery: nil)
    }
}