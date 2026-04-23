import Observation

@Observable
final class HistoryStore {
    private(set) var results: [AnalysisResult] = []

    func add(_ result: AnalysisResult) {
        results.insert(result, at: 0)
    }

    func clear() {
        results.removeAll()
    }
}
