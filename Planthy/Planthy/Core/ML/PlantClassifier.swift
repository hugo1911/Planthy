import CoreML

struct PlantClassifier: @unchecked Sendable {
    private static let inputName  = "input"
    private static let outputName = "var_105"

    private let model: MLModel

    nonisolated init() throws {
        guard let url = Bundle.main.url(forResource: "PlantModel", withExtension: "mlmodelc") else {
            throw ClassifierError.modelNotFound
        }
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        self.model = try MLModel(contentsOf: url, configuration: config)
    }

    /// Corremos la inferencia por cada plantclass ya que es lo que se plantea jajajaja ese juego de palabras.
    /// La entrada debe de ser Float32 MLMultiArray con caracteristicas [1, 3, 224, 224], es muy importante porque es muy sensible el portear de onnx a coreml entonces debe de respetarse eso
    nonisolated func predict(input: MLMultiArray) throws -> [PlantClass: Float] {
        let features = try MLDictionaryFeatureProvider(
            dictionary: [Self.inputName: MLFeatureValue(multiArray: input)]
        )
        let output = try model.prediction(from: features)

        guard let rawOutput = output.featureValue(for: Self.outputName)?.multiArrayValue else {
            throw ClassifierError.unexpectedOutput
        }

        let count = rawOutput.count
        let logits = (0..<count).map { Float(truncating: rawOutput[$0]) }
        let probs = softmax(logits)

        let classes = PlantClass.orderedClasses
        guard probs.count == classes.count else {
            throw ClassifierError.classMismatch(expected: classes.count, got: probs.count)
        }

        return Dictionary(uniqueKeysWithValues: zip(classes, probs))
    }

    private func softmax(_ logits: [Float]) -> [Float] {
        let maxVal = logits.max() ?? 0
        let exps = logits.map { exp($0 - maxVal) }
        let sum = exps.reduce(0, +)
        return exps.map { $0 / sum }
    }
}

enum ClassifierError: LocalizedError {
    case modelNotFound
    case unexpectedOutput
    case classMismatch(expected: Int, got: Int)

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Modelo no encontrado en el bundle de la app."
        case .unexpectedOutput:
            return "El modelo devolvió una salida inesperada."
        case .classMismatch(let e, let g):
            return "El modelo tiene \(g) clases, se esperaban \(e)."
        }
    }
}
