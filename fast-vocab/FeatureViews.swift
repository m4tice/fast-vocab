import SwiftUI

@MainActor
struct SplashViewModel {
    let store: AppStore
    var isUnavailable: Bool { store.vocabularyState == .unavailable }
    func retry() { store.send(.retryInitialization) }
}

struct SplashView: View {
    let store: AppStore

    var body: some View {
        let viewModel = SplashViewModel(store: store)
        VStack(spacing: 24) {
            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text("fastVocab")
                .font(.largeTitle.bold())
            if viewModel.isUnavailable {
                Button("Retry", action: viewModel.retry)
                    .buttonStyle(.borderedProminent)
            } else {
                ProgressView("Loading vocabulary")
            }
        }
        .padding()
        .accessibilityIdentifier("splash.page")
    }
}

@MainActor
struct HomeViewModel {
    let store: AppStore
    var xp: Int { store.userState.accumulatedXP }
    var hasRecoverableLesson: Bool { store.session != nil }
    var recoverableTopicName: String { store.currentTopic?.name ?? "Lesson" }
    var recoverableProgress: String {
        guard let persistence = store.session?.persistence else { return "" }
        let phase = persistence.phase == .main ? "Lesson" : "Review"
        let count = persistence.phase == .main
            ? persistence.mainQuestions.count
            : persistence.reviewQuestions.count
        let question = min(persistence.nextQuestionIndex + 1, max(count, 1))
        let hearts = persistence.phase == .main ? " · \(persistence.hearts) hearts" : ""
        return "\(phase) · question \(question) of \(count)\(hearts)"
    }
    func start() { store.send(.startLessonRequested) }
    func resume() { store.send(.resumeRequested) }
}

struct HomeView: View {
    let store: AppStore

    var body: some View {
        let viewModel = HomeViewModel(store: store)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("fastVocab")
                            .font(.largeTitle.bold())
                        Text("German vocabulary, one lesson at a time")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("\(viewModel.xp) XP", systemImage: "sparkles")
                            .font(.title2.bold())
                        Spacer()
                        Text("\(store.userState.lessonResults.count) lessons")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

                    if viewModel.hasRecoverableLesson {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Continue \(viewModel.recoverableTopicName)")
                                .font(.headline)
                            Text(viewModel.recoverableProgress)
                                .foregroundStyle(.secondary)
                            Button("Resume lesson", action: viewModel.resume)
                                .buttonStyle(.borderedProminent)
                                .accessibilityIdentifier("home.resume")
                        }
                    } else {
                        Button(action: viewModel.start) {
                            Label("Choose a topic", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityIdentifier("home.start")
                    }
                }
                .frame(maxWidth: 680, alignment: .leading)
                .padding(24)
            }
            .navigationTitle("Home")
        }
        .accessibilityIdentifier("home.page")
    }
}

@MainActor
struct TopicSelectionViewModel {
    let store: AppStore
    var topics: [VocabularyTopic] { store.usableTopics }
    func select(_ topic: VocabularyTopic) { store.send(.topicSelected(topic.id)) }
}

struct TopicSelectionView: View {
    let store: AppStore

    var body: some View {
        let viewModel = TopicSelectionViewModel(store: store)
        NavigationStack {
            List(viewModel.topics) { topic in
                Button {
                    viewModel.select(topic)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "character.book.closed.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .background(.blue.opacity(0.1), in: Circle())
                        VStack(alignment: .leading) {
                            Text(topic.name).font(.headline)
                            Text("\(topic.items.filter(\.isValid).count) words").foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityIdentifier("topic.\(topic.id)")
            }
            .navigationTitle("Choose a topic")
        }
        .accessibilityIdentifier("topic.page")
    }
}

@MainActor
struct GameViewModel {
    let store: AppStore
    var session: Session? { store.session }
    var item: VocabularyItem? { store.currentVocabularyItem }
    var evaluation: AnswerEvaluation? { store.lastEvaluation }
    var isPresenting: Bool { session?.game.state == .presenting }
    var isMain: Bool { session?.persistence.phase == .main }
    var phaseTitle: String { isMain ? "Lesson" : "Review" }
    var questionNumber: Int { (session?.persistence.nextQuestionIndex ?? 0) + 1 }
    var questionCount: Int {
        guard let session else { return 1 }
        return session.persistence.phase == .main
            ? session.persistence.mainQuestions.count
            : session.persistence.reviewQuestions.count
    }
    var progress: Double { Double(questionNumber) / Double(max(questionCount, 1)) }
    func submit(_ answer: String) { store.send(.answerSubmitted(answer)) }
    func advance() { store.send(.continueRequested) }
    func pause() { store.send(.pauseRequested) }
    func requestCancel() { store.send(.cancelRequested) }
}

struct GameView: View {
    let store: AppStore
    @State private var answer = ""

    var body: some View {
        let viewModel = GameViewModel(store: store)
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    HStack {
                        Text(viewModel.phaseTitle).font(.headline)
                        Spacer()
                        if viewModel.isMain {
                            Label("\(viewModel.session?.persistence.hearts ?? 0)", systemImage: "heart.fill")
                                .foregroundStyle(.red)
                                .accessibilityIdentifier("game.hearts")
                        }
                    }
                    ProgressView(value: viewModel.progress)
                    Text("Question \(viewModel.questionNumber) of \(viewModel.questionCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                if let item = viewModel.item, let exercise = viewModel.session?.game.exercise {
                    ExercisePrompt(exercise: exercise, item: item)
                    answerInput(exercise: exercise, viewModel: viewModel)
                }
                Spacer()

                if let evaluation = viewModel.evaluation {
                    VStack(spacing: 12) {
                        Label(
                            evaluation.isCorrect ? "Correct" : "Answer: \(evaluation.expectedAnswer)",
                            systemImage: evaluation.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                        )
                        .font(.headline)
                        .foregroundStyle(evaluation.isCorrect ? .green : .red)
                        Button("Continue") {
                            answer = ""
                            viewModel.advance()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("game.continue")
                    }
                } else if !isArticle(viewModel.session?.game.exercise) {
                    Button("Check") { viewModel.submit(answer) }
                        .buttonStyle(.borderedProminent)
                        .disabled(answer.trimmed.isEmpty)
                        .accessibilityIdentifier("game.check")
                }
            }
            .frame(maxWidth: 680)
            .padding(24)
            .navigationTitle(store.currentTopic?.name ?? "Lesson")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: viewModel.requestCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.pause) {
                        Image(systemName: "pause.fill")
                    }
                    .disabled(!viewModel.isPresenting)
                    .accessibilityLabel("Pause lesson")
                }
            }
        }
        .alert("Cancel lesson?", isPresented: Binding(
            get: { store.isCancelConfirmationPresented },
            set: { if !$0 { store.send(.cancelDismissed) } }
        )) {
            Button("Keep Learning", role: .cancel) { store.send(.cancelDismissed) }
            Button("Cancel Lesson", role: .destructive) { store.send(.cancelConfirmed) }
        } message: {
            Text("Your progress in this lesson will be discarded.")
        }
        .accessibilityIdentifier("game.page")
    }

    @ViewBuilder
    private func answerInput(exercise: ExerciseState, viewModel: GameViewModel) -> some View {
        switch exercise {
        case let .article(_, options):
            HStack {
                ForEach(options, id: \.self) { option in
                    Button(option) { viewModel.submit(option) }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.isPresenting)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("game.answer.\(option)")
                }
            }
        case .plural, .translation:
            TextField("Type your answer", text: $answer)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(!viewModel.isPresenting)
                .submitLabel(.done)
                .onSubmit { if !answer.trimmed.isEmpty { viewModel.submit(answer) } }
                .accessibilityIdentifier("game.answer.text")
        }
    }

    private func isArticle(_ exercise: ExerciseState?) -> Bool {
        if case .article = exercise { return true }
        return false
    }
}

struct ExercisePrompt: View {
    let exercise: ExerciseState
    let item: VocabularyItem

    var body: some View {
        VStack(spacing: 8) {
            Text(instruction).foregroundStyle(.secondary)
            Text(prompt).font(.system(.largeTitle, design: .rounded).bold())
        }
        .multilineTextAlignment(.center)
    }

    private var instruction: String {
        switch exercise {
        case .article: "Pick the article"
        case .plural: "Type the plural"
        case .translation: "Translate into English"
        }
    }

    private var prompt: String {
        switch exercise {
        case .translation: "\(item.article) \(item.word)"
        case .article, .plural: item.word
        }
    }
}

@MainActor
struct ScoreViewModel {
    struct MistakeRow: Identifiable {
        let id: String
        let word: String
        let expectedAnswer: String
        let exerciseName: String
    }

    let store: AppStore
    var session: Session? { store.session }
    var statistics: LessonStatistics { session?.persistence.statistics ?? LessonStatistics() }
    var title: String { session?.state == .gameOver ? "Game over" : "Lesson complete" }
    var mistakeRows: [MistakeRow] {
        guard let topic = store.currentTopic, let session else { return [] }
        return statistics.mistakeVocabularyIDs.compactMap { id in
            guard let item = topic.items.first(where: { $0.id == id }),
                  let question = session.persistence.mainQuestions.first(where: { $0.vocabularyID == id }) else {
                return nil
            }
            switch question.exerciseType {
            case .article:
                return MistakeRow(id: id, word: item.word, expectedAnswer: item.article, exerciseName: "Article")
            case .plural:
                return MistakeRow(id: id, word: item.word, expectedAnswer: item.plural, exerciseName: "Plural")
            case .translation:
                return MistakeRow(
                    id: id,
                    word: "\(item.article) \(item.word)",
                    expectedAnswer: item.translations.joined(separator: ", "),
                    exerciseName: "Translation"
                )
            }
        }
    }
    func dismiss() { store.send(.scoreDismissed) }
}

struct ScoreView: View {
    let store: AppStore

    var body: some View {
        let viewModel = ScoreViewModel(store: store)
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: viewModel.session?.state == .gameOver ? "heart.slash.fill" : "trophy.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(viewModel.session?.state == .gameOver ? .red : .blue)
                    Text(viewModel.title).font(.largeTitle.bold())
                    Text("+\(viewModel.statistics.earnedXP) XP")
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundStyle(.blue)

                    HStack(spacing: 28) {
                        Label("\(viewModel.statistics.totalCorrect) correct", systemImage: "checkmark")
                        Label("\(viewModel.statistics.totalWrong) wrong", systemImage: "xmark")
                    }

                    if !viewModel.mistakeRows.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mistakes").font(.headline)
                            ForEach(viewModel.mistakeRows) { mistake in
                                VStack(alignment: .leading) {
                                    Text(mistake.word).bold()
                                    Text("\(mistake.exerciseName): \(mistake.expectedAnswer)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button("Home", action: viewModel.dismiss)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("score.home")
                }
                .frame(maxWidth: 680)
                .padding(24)
            }
        }
        .accessibilityIdentifier("score.page")
    }
}