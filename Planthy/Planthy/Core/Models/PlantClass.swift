import Foundation

enum PlantClass: String, CaseIterable {
    case healthy = "healthy"
    case rust    = "rust"
    case powdery = "powdery_mildew"

    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .rust:    return "Rust"
        case .powdery: return "Powdery Mildew"
        }
    }

    var recommendation: String {
        switch self {
        case .healthy:
            return "Your plant is healthy. Maintain proper watering and light conditions."
        case .rust:
            return "Rust detected. Apply copper-based fungicide and remove affected leaves."
        case .powdery:
            return "Powdery mildew detected. Improve ventilation and apply sulfur-based fungicide."
        }
    }

    var icon: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .rust:    return "exclamationmark.triangle.fill"
        case .powdery: return "xmark.circle.fill"
        }
    }

    /// Ordered list matching model output indices [0, 1, 2].
    /// Order matches PyTorch ImageFolder alphabetical class_to_idx:
    /// 0=healthy, 1=powdery_mildew, 2=rust
    static let orderedClasses: [PlantClass] = [.healthy, .powdery, .rust]
}
