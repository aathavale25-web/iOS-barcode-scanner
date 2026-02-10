import XCTest
import Vision
@testable import BarcodeScanner

final class QualityAssessmentServiceTests: XCTestCase {
    func testAnalyzeImage_ReturnsMetrics() async {
        let service = QualityAssessmentService()

        // Create a simple test image (white square)
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }

        let metrics = await service.analyzeImage(image, decodeConfidence: 0.95)

        XCTAssertNotNil(metrics)
        XCTAssertGreaterThanOrEqual(metrics.sharpness, 0.0)
        XCTAssertLessThanOrEqual(metrics.sharpness, 1.0)
    }
}
