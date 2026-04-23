import UIKit

struct AnalysisResult: Identifiable {
    let id: UUID
    let plantClass: PlantClass
    let confidence: Float
    let allProbabilities: [PlantClass: Float]
    let date: Date
    let thumbnail: UIImage

    static let lowConfidenceThreshold: Float = 0.60

    var isLowConfidence: Bool {
        confidence < Self.lowConfidenceThreshold
    }

    init(
        id: UUID = UUID(),
        plantClass: PlantClass,
        confidence: Float,
        allProbabilities: [PlantClass: Float],
        date: Date = Date(),
        thumbnail: UIImage
    ) {
        self.id = id
        self.plantClass = plantClass
        self.confidence = confidence
        self.allProbabilities = allProbabilities
        self.date = date
        self.thumbnail = thumbnail
    }
}
