import UIKit
import CoreML

enum ImagePreprocessor {
    private static let size = 224
    private static let mean: (r: Float32, g: Float32, b: Float32) = (0.485, 0.456, 0.406)
    private static let std:  (r: Float32, g: Float32, b: Float32) = (0.229, 0.224, 0.225)

    /// Lo que hacemos es hacerle un resize a 224×224 y normalizar para el MLMultiArray [1, 3, 224, 224].
    /// si no las imagenes se estropean, mas que nada ni se leen bien, es sensible en este aspecto por lo de la conversion
    static func prepare(_ image: UIImage) throws -> MLMultiArray {
        guard let resized = resize(image),
              let cgImage = resized.cgImage else {
            throw PreprocessingError.resizeFailed
        }

        var pixels = [UInt8](repeating: 0, count: size * size * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: &pixels,
            width: size, height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            throw PreprocessingError.contextFailed
        }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size, height: size))

        let array = try MLMultiArray(
            shape: [1, 3, NSNumber(value: size), NSNumber(value: size)],
            dataType: .float32
        )
        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(array.dataPointer))
        let hw = size * size

        for i in 0..<hw {
            let base = i * 4
            ptr[i]          = (Float32(pixels[base])     / 255.0 - mean.r) / std.r  // R
            ptr[hw + i]     = (Float32(pixels[base + 1]) / 255.0 - mean.g) / std.g  // G
            ptr[hw * 2 + i] = (Float32(pixels[base + 2]) / 255.0 - mean.b) / std.b  // B
        }

        return array
    }

    private static func resize(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

enum PreprocessingError: LocalizedError {
    case resizeFailed
    case contextFailed

    var errorDescription: String? {
        switch self {
        case .resizeFailed:  return "No se pudo redimensionar la imagen."
        case .contextFailed: return "No se pudo crear el contexto de imagen."
        }
    }
}
