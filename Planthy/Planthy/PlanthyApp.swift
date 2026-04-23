import SwiftUI

@main
struct PlanthyApp: App {
    @State private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            ContentRoot()
                .environment(historyStore)
        }
    }
}

private struct ContentRoot: View {
    @Environment(HistoryStore.self) private var historyStore

    var body: some View {
        TabView {
            AnalysisView(historyStore: historyStore)
                .tabItem {
                    Label("Analizar", systemImage: "leaf.fill")
                }

            HistoryView()
                .tabItem {
                    Label("Recientes", systemImage: "clock")
                }
        }
    }
}
