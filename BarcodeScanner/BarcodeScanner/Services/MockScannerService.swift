import Foundation

#if DEBUG
struct MockScanResult {
    let barcodeType: String
    let content: String
    let qualityRating: String
    let qualityScore: Double
    let sharpness: Double
    let contrast: Double
    let brightness: Double
    let decodeConfidence: Double
}

class MockScannerService {
    private let barcodeTypes = ["Code 128", "Code 93", "QR Code"]
    private let qualityRatings = ["Excellent", "Good", "Fair", "Poor"]

    func generateTestScan() -> MockScanResult {
        let barcodeType = barcodeTypes.randomElement()!
        let qualityRating = qualityRatings.randomElement()!

        // Generate scores based on quality rating
        let (qualityScore, sharpness, contrast, brightness, decodeConfidence) = generateScores(for: qualityRating)

        // Generate realistic barcode content
        let content = generateContent(for: barcodeType)

        return MockScanResult(
            barcodeType: barcodeType,
            content: content,
            qualityRating: qualityRating,
            qualityScore: qualityScore,
            sharpness: sharpness,
            contrast: contrast,
            brightness: brightness,
            decodeConfidence: decodeConfidence
        )
    }

    private func generateScores(for rating: String) -> (Double, Double, Double, Double, Double) {
        switch rating {
        case "Excellent":
            return (
                Double.random(in: 0.90...1.0),
                Double.random(in: 0.85...1.0),
                Double.random(in: 0.85...1.0),
                Double.random(in: 0.6...0.8),
                Double.random(in: 0.95...1.0)
            )
        case "Good":
            return (
                Double.random(in: 0.70...0.89),
                Double.random(in: 0.65...0.84),
                Double.random(in: 0.65...0.84),
                Double.random(in: 0.5...0.7),
                Double.random(in: 0.80...0.94)
            )
        case "Fair":
            return (
                Double.random(in: 0.50...0.69),
                Double.random(in: 0.45...0.64),
                Double.random(in: 0.45...0.64),
                Double.random(in: 0.3...0.6),
                Double.random(in: 0.65...0.79)
            )
        default: // Poor
            return (
                Double.random(in: 0.0...0.49),
                Double.random(in: 0.0...0.44),
                Double.random(in: 0.0...0.44),
                Double.random(in: 0.0...0.5),
                Double.random(in: 0.0...0.64)
            )
        }
    }

    private func generateContent(for type: String) -> String {
        switch type {
        case "Code 128":
            return "CODE128-\(Int.random(in: 100000...999999))"
        case "Code 93":
            return "CODE93-\(Int.random(in: 10000...99999))"
        case "QR Code":
            return "https://example.com/item/\(UUID().uuidString.prefix(8))"
        default:
            return "UNKNOWN"
        }
    }
}
#endif
