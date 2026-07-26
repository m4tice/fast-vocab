import Foundation

enum LessonEngineError: Error, Equatable {
    case unusableTopic
    case questionNotFound
    case invalidTransition
}

struct LessonEngine {
    static let startingHearts = 3
    static let experiencePerCorrectMainAnswer = 10

    func createSession(
        topic: VocabularyTopic,
        sessionID: String = UUID().uuidString,
        now: Date = Date()
    ) throws -> Session {
        let items = topic.items.filter(\.isValid)
        guard items.count >= 3 else { throw LessonEngineError.unusableTopic }

        let questions = items.enumerated().map { index, item in
            LessonQuestion(
                id: "\(sessionID)-main-\(index)",
                vocabularyID: item.id,
                exerciseType: ExerciseType.allCases[index % ExerciseType.allCases.count]
            )
        }
        let persistence = SessionPersistence(
            sessionID: sessionID,
            topicID: topic.id,
            state: .active,
            phase: .main,
            mainQuestions: questions,
            reviewQuestions: [],
            nextQuestionIndex: 0,
            hearts: Self.startingHearts,
            statistics: LessonStatistics(),
            vocabularyStatistics: [:],
            createdAt: now,
            updatedAt: now
        )
        return Session(
            state: .active,
            game: Game(
                state: .presenting,
                exercise: try makeExercise(question: questions[0], topic: topic)
            ),
            persistence: persistence
        )
    }

    func restoreSession(from snapshot: SessionPersistence, topic: VocabularyTopic) throws -> Session {
        guard snapshot.state == .active || snapshot.state == .paused else {
            throw LessonEngineError.invalidTransition
        }
        let questions = snapshot.phase == .main ? snapshot.mainQuestions : snapshot.reviewQuestions
        guard questions.indices.contains(snapshot.nextQuestionIndex) else {
            throw LessonEngineError.questionNotFound
        }
        let question = questions[snapshot.nextQuestionIndex]
        return Session(
            state: snapshot.state,
            game: Game(state: .presenting, exercise: try makeExercise(question: question, topic: topic)),
            persistence: snapshot
        )
    }

    func submit(answer: String, to session: inout Session, topic: VocabularyTopic) throws -> AnswerEvaluation {
        guard session.state == .active, session.game.state == .presenting else {
            throw LessonEngineError.invalidTransition
        }
        let question = session.game.exercise.question
        guard let item = topic.items.first(where: { $0.id == question.vocabularyID }) else {
            throw LessonEngineError.questionNotFound
        }

        session.game.state = .checking
        let expectedAnswers = acceptedAnswers(for: question.exerciseType, item: item)
        let isCorrect = expectedAnswers.contains(normalize(answer))
        let expectedAnswer = displayAnswer(for: question.exerciseType, item: item)
        recordAttempt(isCorrect: isCorrect, question: question, in: &session)

        if session.persistence.phase == .main && !isCorrect && session.persistence.hearts == 0 {
            session.state = .gameOver
            session.persistence.state = .gameOver
            session.persistence.updatedAt = Date()
            return AnswerEvaluation(isCorrect: false, expectedAnswer: expectedAnswer, isTerminal: true)
        }

        session.game.state = isCorrect ? .showingCorrect : .showingWrong
        return AnswerEvaluation(isCorrect: isCorrect, expectedAnswer: expectedAnswer, isTerminal: false)
    }

    func advance(_ session: inout Session, topic: VocabularyTopic, now: Date = Date()) throws {
        guard session.state == .active,
              session.game.state == .showingCorrect || session.game.state == .showingWrong else {
            throw LessonEngineError.invalidTransition
        }

        session.game.state = .advancing
        session.persistence.nextQuestionIndex += 1
        var questions = currentQuestions(for: session.persistence)

        if session.persistence.nextQuestionIndex >= questions.count {
            if session.persistence.phase == .main && !session.persistence.reviewQuestions.isEmpty {
                session.persistence.phase = .review
                session.persistence.nextQuestionIndex = 0
                questions = session.persistence.reviewQuestions
            } else {
                session.state = .completed
                session.persistence.state = .completed
                session.persistence.updatedAt = now
                return
            }
        }

        let question = questions[session.persistence.nextQuestionIndex]
        session.game.exercise = try makeExercise(question: question, topic: topic)
        session.game.state = .presenting
        session.persistence.updatedAt = now
    }

    private func recordAttempt(isCorrect: Bool, question: LessonQuestion, in session: inout Session) {
        var vocabularyStatistics = session.persistence.vocabularyStatistics[question.vocabularyID]
            ?? VocabularyLearningStatistics(vocabularyID: question.vocabularyID)

        switch (session.persistence.phase, isCorrect) {
        case (.main, true):
            session.persistence.statistics.mainCorrect += 1
            session.persistence.statistics.earnedXP += Self.experiencePerCorrectMainAnswer
            vocabularyStatistics.correctAnswers += 1
        case (.main, false):
            session.persistence.statistics.mainWrong += 1
            session.persistence.hearts -= 1
            vocabularyStatistics.wrongAnswers += 1
            session.persistence.statistics.recordMistake(vocabularyID: question.vocabularyID)
            if !session.persistence.reviewQuestions.contains(where: { $0.vocabularyID == question.vocabularyID }) {
                session.persistence.reviewQuestions.append(question)
            }
        case (.review, true):
            session.persistence.statistics.reviewCorrect += 1
            vocabularyStatistics.correctAnswers += 1
        case (.review, false):
            session.persistence.statistics.reviewWrong += 1
            vocabularyStatistics.wrongAnswers += 1
            session.persistence.statistics.recordMistake(vocabularyID: question.vocabularyID)
        }
        session.persistence.vocabularyStatistics[question.vocabularyID] = vocabularyStatistics
    }

    private func makeExercise(question: LessonQuestion, topic: VocabularyTopic) throws -> ExerciseState {
        guard topic.items.contains(where: { $0.id == question.vocabularyID }) else {
            throw LessonEngineError.questionNotFound
        }
        switch question.exerciseType {
        case .article:
            let options = Array(Set(topic.items.filter(\.isValid).map(\.article))).sorted()
            return .article(question: question, options: options)
        case .plural:
            return .plural(question: question)
        case .translation:
            return .translation(question: question)
        }
    }

    private func acceptedAnswers(for type: ExerciseType, item: VocabularyItem) -> Set<String> {
        switch type {
        case .article: return [normalize(item.article)]
        case .plural: return [normalize(item.plural)]
        case .translation: return Set(item.translations.map(normalize))
        }
    }

    private func displayAnswer(for type: ExerciseType, item: VocabularyItem) -> String {
        switch type {
        case .article: item.article
        case .plural: item.plural
        case .translation: item.translations.first ?? ""
        }
    }

    private func currentQuestions(for persistence: SessionPersistence) -> [LessonQuestion] {
        persistence.phase == .main ? persistence.mainQuestions : persistence.reviewQuestions
    }

    private func normalize(_ value: String) -> String {
        value.trimmed.precomposedStringWithCanonicalMapping.lowercased()
    }
}