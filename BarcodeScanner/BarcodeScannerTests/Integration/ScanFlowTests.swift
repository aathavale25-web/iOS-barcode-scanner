import XCTest
import SwiftData
@testable import BarcodeScanner

final class ScanFlowTests: XCTestCase {
    func testMockScanCreatesRecord() async {
        // Setup in-memory model container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: ScanRecord.self, configurations: config)
        let context = container.mainContext

        // Create a record
        let record = ScanRecord(
            barcodeType: "QR Code",
            content: "https://test.com",
            qualityRating: "Excellent",
            qualityScore: 0.95,
            sharpness: 0.9,
            contrast: 0.85,
            brightness: 0.7,
            decodeConfidence: 0.98
        )

        context.insert(record)
        try! context.save()

        // Verify it was saved
        let descriptor = FetchDescriptor<ScanRecord>()
        let records = try! context.fetch(descriptor)

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.content, "https://test.com")
    }

    func testQualityMetricsRatingLogic() {
        // Test Excellent rating
        let excellentMetrics = QualityMetrics(
            sharpness: 0.95,
            contrast: 0.9,
            brightness: 0.7,
            decodeConfidence: 0.98
        )
        XCTAssertEqual(excellentMetrics.rating, "Excellent")
        XCTAssertGreaterThan(excellentMetrics.overallScore, 0.85)

        // Test Good rating
        let goodMetrics = QualityMetrics(
            sharpness: 0.75,
            contrast: 0.7,
            brightness: 0.6,
            decodeConfidence: 0.85
        )
        XCTAssertEqual(goodMetrics.rating, "Good")

        // Test Fair rating
        let fairMetrics = QualityMetrics(
            sharpness: 0.55,
            contrast: 0.5,
            brightness: 0.4,
            decodeConfidence: 0.70
        )
        XCTAssertEqual(fairMetrics.rating, "Fair")

        // Test Poor rating
        let poorMetrics = QualityMetrics(
            sharpness: 0.3,
            contrast: 0.2,
            brightness: 0.1,
            decodeConfidence: 0.4
        )
        XCTAssertEqual(poorMetrics.rating, "Poor")
    }

    func testMockScannerServiceGeneratesValidData() {
        #if DEBUG
        let service = MockScannerService()

        // Generate multiple test scans
        for _ in 0..<10 {
            let scan = service.generateTestScan()

            // Verify barcode type
            let validTypes = ["Code 128", "Code 93", "QR Code"]
            XCTAssertTrue(validTypes.contains(scan.barcodeType))

            // Verify quality rating
            let validRatings = ["Excellent", "Good", "Fair", "Poor"]
            XCTAssertTrue(validRatings.contains(scan.qualityRating))

            // Verify scores in valid range
            XCTAssertGreaterThanOrEqual(scan.qualityScore, 0.0)
            XCTAssertLessThanOrEqual(scan.qualityScore, 1.0)
            XCTAssertGreaterThanOrEqual(scan.sharpness, 0.0)
            XCTAssertLessThanOrEqual(scan.sharpness, 1.0)
            XCTAssertGreaterThanOrEqual(scan.contrast, 0.0)
            XCTAssertLessThanOrEqual(scan.contrast, 1.0)
            XCTAssertGreaterThanOrEqual(scan.brightness, 0.0)
            XCTAssertLessThanOrEqual(scan.brightness, 1.0)
            XCTAssertGreaterThanOrEqual(scan.decodeConfidence, 0.0)
            XCTAssertLessThanOrEqual(scan.decodeConfidence, 1.0)

            // Verify content is not empty
            XCTAssertFalse(scan.content.isEmpty)
        }
        #endif
    }
}
