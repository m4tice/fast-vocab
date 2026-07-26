//
//  ContentView.swift
//  fast-vocab
//
//  Created by Nguyen Duc Tuan on 26/7/26.
//

import SwiftUI

struct ContentView: View {
    @Bindable var store: AppStore

    var body: some View {
        Group {
            switch store.appState {
            case .splash:
                SplashView(store: store)
            case .home:
                HomeView(store: store)
            case .topicSelection:
                TopicSelectionView(store: store)
            case .game:
                GameView(store: store)
            case .score:
                ScoreView(store: store)
            }
        }
        .tint(.blue)
        .alert(item: Binding(
            get: { store.errorPresentation },
            set: { _ in store.send(.dismissError) }
        )) { error in
            if let recovery = error.recovery {
                Alert(
                    title: Text(store.appState == .splash ? "Unable to Start" : "Unable to Save"),
                    message: Text(error.message),
                    primaryButton: .default(Text("Retry")) {
                        switch recovery {
                        case .retryInitialization: store.send(.retryInitialization)
                        case .retryTerminalCommit: store.send(.retryTerminalCommit)
                        }
                    },
                    secondaryButton: .cancel { store.send(.dismissError) }
                )
            } else {
                Alert(title: Text("Something Went Wrong"), message: Text(error.message))
            }
        }
        .task {
            guard store.vocabularyState == .idle else { return }
            store.send(.appLaunched)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            store.send(.appMovedToBackground)
        }
    }
}
