import Foundation
import SwiftData

@Model
final class ScanRecord {
    var id: UUID
    var timestamp: Date
    var barcodeType: String
    var content: String
    var qualityRating: String
    var qualityScore: Double

    var sharpness: Double
    var contrast: Double
    var brightness: Double
    var decodeConfidence: Double

    init(
        barcodeType: String,
        content: String,
        qualityRating: String,
        qualityScore: Double,
        sharpness: Double,
        contrast: Double,
        brightness: Double,
        decodeConfidence: Double
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.barcodeType = barcodeType
        self.content = content
        self.qualityRating = qualityRating
        self.qualityScore = qualityScore
        self.sharpness = sharpness
        self.contrast = contrast
        self.brightness = brightness
        self.decodeConfidence = decodeConfidence
    }
}
