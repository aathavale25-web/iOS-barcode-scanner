import XCTest
@testable import BarcodeScanner

final class QualityMetricsTests: XCTestCase {
    func testQualityMetricsCalculation() {
        let metrics = QualityMetrics(
            sharpness: 0.9,
            contrast: 0.85,
            brightness: 0.7,
            decodeConfidence: 0.95
        )

        XCTAssertEqual(metrics.sharpness, 0.9, accuracy: 0.01)
        XCTAssertEqual(metrics.overallScore, 0.875, accuracy: 0.01)
    }

    func testQualityRating_Excellent() {
        let metrics = QualityMetrics(
            sharpness: 0.95,
            contrast: 0.9,
            brightness: 0.7,
            decodeConfidence: 0.98
        )

        XCTAssertEqual(metrics.rating, "Excellent")
    }

    func testQualityRating_Good() {
        let metrics = QualityMetrics(
            sharpness: 0.75,
            contrast: 0.7,
            brightness: 0.6,
            decodeConfidence: 0.85
        )

        XCTAssertEqual(metrics.rating, "Good")
    }

    func testQualityRating_Fair() {
        let metrics = QualityMetrics(
            sharpness: 0.55,
            contrast: 0.5,
            brightness: 0.4,
            decodeConfidence: 0.70
        )

        XCTAssertEqual(metrics.rating, "Fair")
    }

    func testQualityRating_Poor() {
        let metrics = QualityMetrics(
            sharpness: 0.3,
            contrast: 0.2,
            brightness: 0.1,
            decodeConfidence: 0.4
        )

        XCTAssertEqual(metrics.rating, "Poor")
    }
}
