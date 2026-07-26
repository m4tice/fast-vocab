import Foundation

struct VocabularyCatalog: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let topics: [VocabularyTopic]

    var usableTopics: [VocabularyTopic] {
        topics.filter(\.isUsable)
    }
}

struct VocabularyTopic: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let sourceLanguageCode: String
    let targetLanguageCode: String
    let items: [VocabularyItem]

    var isUsable: Bool {
        items.filter(\.isValid).count >= 3
    }
}

struct VocabularyItem: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let word: String
    let article: String
    let plural: String
    let translations: [String]

    var isValid: Bool {
        !id.trimmed.isEmpty &&
            !word.trimmed.isEmpty &&
            !article.trimmed.isEmpty &&
            !plural.trimmed.isEmpty &&
            translations.contains { !$0.trimmed.isEmpty }
    }
}

enum ExerciseType: String, Codable, CaseIterable, Equatable, Sendable {
    case article
    case plural
    case translation
}

struct LessonQuestion: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let vocabularyID: String
    let exerciseType: ExerciseType
}

enum SessionPhase: String, Codable, Equatable, Sendable {
    case main
    case review
}

enum SessionState: String, Codable, Equatable, Sendable {
    case preparing
    case active
    case paused
    case completed
    case gameOver
}

enum GameState: String, Codable, Equatable, Sendable {
    case presenting
    case checking
    case showingCorrect
    case showingWrong
    case advancing
}

enum ExerciseState: Codable, Equatable, Sendable {
    case article(question: LessonQuestion, options: [String])
    case plural(question: LessonQuestion)
    case translation(question: LessonQuestion)

    var question: LessonQuestion {
        switch self {
        case let .article(question, _), let .plural(question), let .translation(question):
            question
        }
    }
}

struct Game: Codable, Equatable, Sendable {
    var state: GameState
    var exercise: ExerciseState
}

struct LessonStatistics: Codable, Equatable, Sendable {
    var mainCorrect = 0
    var mainWrong = 0
    var reviewCorrect = 0
    var reviewWrong = 0
    var earnedXP = 0
    var mistakeVocabularyIDs: [String] = []

    var totalCorrect: Int { mainCorrect + reviewCorrect }
    var totalWrong: Int { mainWrong + reviewWrong }

    mutating func recordMistake(vocabularyID: String) {
        guard !mistakeVocabularyIDs.contains(vocabularyID) else { return }
        mistakeVocabularyIDs.append(vocabularyID)
    }
}

struct SessionPersistence: Codable, Equatable, Sendable {
    let sessionID: String
    let topicID: String
    var state: SessionState
    var phase: SessionPhase
    let mainQuestions: [LessonQuestion]
    var reviewQuestions: [LessonQuestion]
    var nextQuestionIndex: Int
    var hearts: Int
    var statistics: LessonStatistics
    var vocabularyStatistics: [String: VocabularyLearningStatistics]
    let createdAt: Date
    var updatedAt: Date
}

struct Session: Codable, Equatable, Sendable {
    var state: SessionState
    var game: Game
    var persistence: SessionPersistence
}

struct VocabularyLearningStatistics: Codable, Equatable, Sendable {
    let vocabularyID: String
    var correctAnswers = 0
    var wrongAnswers = 0
}

struct AnswerEvaluation: Equatable, Sendable {
    let isCorrect: Bool
    let expectedAnswer: String
    let isTerminal: Bool
}

struct LessonResult: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let topicID: String
    let status: SessionState
    let statistics: LessonStatistics
    let completedAt: Date
}

struct UserProgress: Codable, Equatable, Sendable {
    var accumulatedXP = 0
    var lessonResults: [LessonResult] = []
    var vocabularyStatistics: [String: VocabularyLearningStatistics] = [:]
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}