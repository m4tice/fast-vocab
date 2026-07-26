//
//  fast_vocabApp.swift
//  fast-vocab
//
//  Created by Nguyen Duc Tuan on 26/7/26.
//

import SwiftUI

@main
struct fast_vocabApp: App {
    @State private var store: AppStore

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let isUITesting = arguments.contains("--ui-testing") || arguments.contains("--ui-testing-recovery")
        let persistence = CoreDataRepository(controller: PersistenceController(inMemory: isUITesting))
        if arguments.contains("--ui-testing-recovery"),
           let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let catalog = try? JSONDecoder().decode(VocabularyCatalog.self, from: data),
           let topic = catalog.usableTopics.first,
           var seededSession = try? LessonEngine().createSession(topic: topic, sessionID: "ui-recovery") {
            seededSession.state = .paused
            seededSession.persistence.state = .paused
            try? persistence.saveSession(seededSession.persistence)
        }
        let loader = VocabularyLoader(
            cache: CachedVocabularySource(repository: persistence),
            bundle: BundleVocabularySource(),
            api: APIVocabularySource(baseURL: nil)
        )
        _store = State(initialValue: AppStore(dependencies: AppDependencies(
            persistence: persistence,
            vocabularyLoader: loader
        )))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
