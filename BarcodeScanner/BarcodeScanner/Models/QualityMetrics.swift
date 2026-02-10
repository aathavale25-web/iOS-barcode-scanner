import Foundation

struct QualityMetrics {
    let sharpness: Double
    let contrast: Double
    let brightness: Double
    let decodeConfidence: Double

    var overallScore: Double {
        // Weighted average: decode confidence is most important
        return (decodeConfidence * 0.4) + (sharpness * 0.3) + (contrast * 0.2) + (brightness * 0.1)
    }

    var rating: String {
        switch overallScore {
        case 0.85...1.0:
            return "Excellent"
        case 0.70..<0.85:
            return "Good"
        case 0.50..<0.70:
            return "Fair"
        default:
            return "Poor"
        }
    }

    var feedback: String {
        if rating == "Excellent" {
            return "Perfect scan! Barcode is clear and readable."
        } else if rating == "Good" {
            return "Good scan! Barcode successfully decoded."
        } else if rating == "Fair" {
            if sharpness < 0.6 {
                return "Fair - try holding the camera steadier for sharper images."
            } else if brightness < 0.4 || brightness > 0.8 {
                return "Fair - try adjusting the lighting conditions."
            } else {
                return "Fair - barcode decoded but quality could be improved."
            }
        } else {
            if decodeConfidence < 0.5 {
                return "Poor - unable to decode reliably. Try again."
            } else if sharpness < 0.4 {
                return "Poor - image is too blurry. Hold camera steady."
            } else {
                return "Poor - improve lighting and try again."
            }
        }
    }

    var badgeColor: String {
        switch rating {
        case "Excellent": return "green"
        case "Good": return "blue"
        case "Fair": return "orange"
        default: return "red"
        }
    }
}
