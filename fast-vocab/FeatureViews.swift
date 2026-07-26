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
        ZStack {
            CoastalBackground()
            VStack(spacing: 18) {
                Spacer()
                CoastalMark(size: 92)
                VStack(spacing: 6) {
                    Text("fastVocab")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.frontBeachBlue)
                    Text("Learn a little. Go a long way.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                if viewModel.isUnavailable {
                    Button("Retry", action: viewModel.retry)
                        .buttonStyle(PrimaryActionButtonStyle())
                        .frame(maxWidth: 320)
                } else {
                    ProgressView("Preparing your next lesson")
                        .tint(AppColor.frontBeachBlue)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer().frame(height: 28)
            }
            .padding(24)
        }
        .appTypography()
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
            ZStack {
                CoastalBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .center, spacing: 14) {
                            CoastalMark(size: 56)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Ready to learn?")
                                    .font(.title2.bold())
                                Text("German vocabulary, one calm step at a time")
                                    .font(.subheadline)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }

                        HStack(spacing: 0) {
                            statItem(value: "\(viewModel.xp)", label: "XP", color: AppColor.goldenSand)
                            Divider().frame(height: 46)
                            statItem(
                                value: "\(store.userState.lessonResults.count)",
                                label: "Lessons",
                                color: AppColor.conPhungJade
                            )
                        }
                        .appSurface()

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.hasRecoverableLesson ? "Continue Learning" : "Start Exploring")
                                        .font(.headline)
                                    Text(viewModel.hasRecoverableLesson
                                         ? viewModel.recoverableTopicName
                                         : "Choose a topic for your next lesson")
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                Spacer()
                                Image(systemName: viewModel.hasRecoverableLesson ? "book.pages.fill" : "sailboat.fill")
                                    .font(.title2)
                                    .foregroundStyle(AppColor.frontBeachBlue)
                                    .frame(width: 48, height: 48)
                                    .background(AppColor.frontBeachBlue.opacity(0.1), in: Circle())
                            }

                            if viewModel.hasRecoverableLesson {
                                Text(viewModel.recoverableProgress)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(AppColor.conPhungJade)
                                Button("Resume lesson", action: viewModel.resume)
                                    .buttonStyle(ProgressActionButtonStyle())
                                    .accessibilityIdentifier("home.resume")
                            } else {
                                Button(action: viewModel.start) {
                                    Label("Choose a topic", systemImage: "arrow.right")
                                }
                                .buttonStyle(PrimaryActionButtonStyle())
                                .accessibilityIdentifier("home.start")
                            }
                        }
                        .appSurface()

                        HStack(spacing: 10) {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(AppColor.marineMoss)
                            Text("Small lessons build lasting progress.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                    .frame(maxWidth: 680, alignment: .leading)
                    .padding(24)
                }
            }
            .navigationTitle("fastVocab")
            .toolbarBackground(AppColor.card, for: .navigationBar)
        }
        .appTypography()
        .accessibilityIdentifier("home.page")
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
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
            ZStack {
                CoastalBackground()
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.topics.enumerated()), id: \.element.id) { index, topic in
                            Button {
                                viewModel.select(topic)
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: topicIcon(at: index))
                                        .font(.title2)
                                        .foregroundStyle(topicColor(at: index))
                                        .frame(width: 48, height: 48)
                                        .background(topicColor(at: index).opacity(0.11), in: Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(topic.name)
                                            .font(.headline)
                                            .foregroundStyle(AppColor.textPrimary)
                                        Text("\(topic.items.filter(\.isValid).count) words")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColor.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(AppColor.frontBeachBlue)
                                }
                                .appSurface()
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("topic.\(topic.id)")
                        }
                    }
                    .frame(maxWidth: 680)
                    .padding(24)
                }
            }
            .navigationTitle("Choose a topic")
            .toolbarBackground(AppColor.card, for: .navigationBar)
        }
        .appTypography()
        .accessibilityIdentifier("topic.page")
    }

    private func topicIcon(at index: Int) -> String {
        ["house.fill", "fork.knife", "sailboat.fill", "leaf.fill"][index % 4]
    }

    private func topicColor(at index: Int) -> Color {
        [AppColor.frontBeachBlue, AppColor.coastalSunset, AppColor.conPhungJade, AppColor.marineMoss][index % 4]
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
            ZStack {
                CoastalBackground()
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        HStack {
                            Text(viewModel.phaseTitle)
                                .font(.subheadline.bold())
                                .foregroundStyle(viewModel.isMain ? AppColor.conPhungJade : AppColor.coastalSunset)
                            Spacer()
                            Text("\(viewModel.questionNumber) / \(viewModel.questionCount)")
                                .font(.caption.bold())
                                .foregroundStyle(AppColor.textSecondary)
                            if viewModel.isMain {
                                Label("\(viewModel.session?.persistence.hearts ?? 0)", systemImage: "heart.fill")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(AppColor.coastalSunset)
                                    .accessibilityIdentifier("game.hearts")
                            }
                        }
                        ProgressView(value: viewModel.progress)
                            .tint(viewModel.isMain ? AppColor.conPhungJade : AppColor.coastalSunset)
                    }
                    .padding(.horizontal, 4)

                    Spacer(minLength: 8)
                    if let item = viewModel.item, let exercise = viewModel.session?.game.exercise {
                        ExercisePrompt(exercise: exercise, item: item)
                            .frame(maxWidth: .infinity)
                            .appSurface()
                        answerInput(exercise: exercise, viewModel: viewModel)
                    }
                    Spacer(minLength: 8)

                    if let evaluation = viewModel.evaluation {
                        VStack(spacing: 12) {
                            Label(
                                evaluation.isCorrect ? "Nicely done" : "Almost — \(evaluation.expectedAnswer)",
                                systemImage: evaluation.isCorrect ? "checkmark.circle.fill" : "lightbulb.fill"
                            )
                            .font(.headline)
                            .foregroundStyle(evaluation.isCorrect ? AppColor.conPhungJade : AppColor.coastalSunset)
                            Button("Continue") {
                                answer = ""
                                viewModel.advance()
                            }
                            .buttonStyle(ProgressActionButtonStyle())
                            .accessibilityIdentifier("game.continue")
                        }
                        .frame(maxWidth: .infinity)
                        .appSurface()
                    } else if !isArticle(viewModel.session?.game.exercise) {
                        Button("Check") { viewModel.submit(answer) }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(answer.trimmed.isEmpty)
                            .opacity(answer.trimmed.isEmpty ? 0.5 : 1)
                            .accessibilityIdentifier("game.check")
                    }
                }
                .frame(maxWidth: 680)
                .padding(24)
            }
            .navigationTitle(store.currentTopic?.name ?? "Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.card, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: viewModel.requestCancel) {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel lesson")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.pause) {
                        Image(systemName: "pause.circle")
                    }
                    .disabled(!viewModel.isPresenting)
                    .accessibilityLabel("Pause lesson")
                }
            }
        }
        .appTypography()
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
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(option) { viewModel.submit(option) }
                        .buttonStyle(AnswerButtonStyle())
                        .disabled(!viewModel.isPresenting)
                        .accessibilityIdentifier("game.answer.\(option)")
                }
            }
        case .plural, .translation:
            TextField("Type your answer", text: $answer)
                .font(.title3.weight(.medium))
                .padding(.horizontal, 16)
                .frame(minHeight: 54)
                .background(AppColor.card.opacity(0.96), in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.border, lineWidth: 1)
                }
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
        VStack(spacing: 12) {
            Text(instruction)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColor.textSecondary)
            Text(prompt)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)
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
            ZStack {
                CoastalBackground()
                ScrollView {
                    VStack(spacing: 22) {
                        ZStack {
                            Circle()
                                .fill((viewModel.session?.state == .gameOver
                                       ? AppColor.coastalSunset
                                       : AppColor.goldenSand).opacity(0.2))
                                .frame(width: 108, height: 108)
                            Image(systemName: viewModel.session?.state == .gameOver ? "heart.slash.fill" : "trophy.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(viewModel.session?.state == .gameOver
                                                 ? AppColor.coastalSunset
                                                 : AppColor.goldenSand)
                        }
                        VStack(spacing: 6) {
                            Text(viewModel.title)
                                .font(.largeTitle.bold())
                            Text(viewModel.session?.state == .gameOver
                                 ? "Every mistake is a step forward."
                                 : "A little progress, beautifully done.")
                                .foregroundStyle(AppColor.textSecondary)
                        }

                        HStack(spacing: 0) {
                            scoreItem(
                                value: "+\(viewModel.statistics.earnedXP)",
                                label: "XP earned",
                                color: AppColor.goldenSand
                            )
                            Divider().frame(height: 48)
                            scoreItem(
                                value: "\(viewModel.statistics.totalCorrect)",
                                label: "Correct",
                                color: AppColor.conPhungJade
                            )
                            Divider().frame(height: 48)
                            scoreItem(
                                value: "\(viewModel.statistics.totalWrong)",
                                label: "To review",
                                color: AppColor.coastalSunset
                            )
                        }
                        .appSurface()

                        if !viewModel.mistakeRows.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Label("Keep exploring", systemImage: "leaf.fill")
                                    .font(.headline)
                                    .foregroundStyle(AppColor.coastalSunset)
                                ForEach(viewModel.mistakeRows) { mistake in
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(mistake.word).bold()
                                        Text("\(mistake.exerciseName): \(mistake.expectedAnswer)")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColor.textSecondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appSurface()
                        }

                        Button("Continue learning", action: viewModel.dismiss)
                            .buttonStyle(PrimaryActionButtonStyle())
                            .accessibilityIdentifier("score.home")
                    }
                    .frame(maxWidth: 680)
                    .padding(24)
                }
            }
        }
        .appTypography()
        .accessibilityIdentifier("score.page")
    }

    private func scoreItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}