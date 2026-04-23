import SwiftUI
import PhotosUI
import Observation

@Observable
@MainActor
final class AnalysisViewModel {
    var selectedItem: PhotosPickerItem?
    var selectedImage: UIImage?
    var isAnalyzing = false
    var latestResult: AnalysisResult?
    var errorMessage: String?
    var showError = false
    var navigateToResult = false

    private let historyStore: HistoryStore
    private var classifier: PlantClassifier?

    init(historyStore: HistoryStore) {
        self.historyStore = historyStore
        do {
            self.classifier = try PlantClassifier()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func loadSelectedImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        selectedImage = image
    }

    func analyze() async {
        guard let image = selectedImage, let classifier else { return }
        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let array = try ImagePreprocessor.prepare(image)
            let probs = try await Task.detached(priority: .userInitiated) {
                try classifier.predict(input: array)
            }.value

            guard let best = probs.max(by: { $0.value < $1.value }) else { return }

            let result = AnalysisResult(
                plantClass: best.key,
                confidence: best.value,
                allProbabilities: probs,
                thumbnail: image
            )
            historyStore.add(result)
            latestResult = result
            navigateToResult = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func reset() {
        selectedItem = nil
        selectedImage = nil
        latestResult = nil
        navigateToResult = false
    }
}
