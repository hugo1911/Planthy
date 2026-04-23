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

    ///Las descripciones fueron hechas por ia ya que no sabemos tanto del cuidado de plantas pero es un plus jajaj
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

    ///Buscamos que nos devuelva un numero dentro del arreglo para indicarnos que estado tiene y despues no confundirnos ya que son valores previamente asignados, lo podemos ver como un diccionario si es mas facil
    static let orderedClasses: [PlantClass] = [.healthy, .powdery, .rust]
}
