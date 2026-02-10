import XCTest
@testable import BarcodeScanner

final class MockScannerServiceTests: XCTestCase {
    func testGenerateTestScan_ReturnsValidBarcodeTypes() {
        let service = MockScannerService()
        let scan = service.generateTestScan()

        let validTypes = ["Code 128", "Code 93", "QR Code"]
        XCTAssertTrue(validTypes.contains(scan.barcodeType))
    }

    func testGenerateTestScan_ReturnsValidQualityRating() {
        let service = MockScannerService()
        let scan = service.generateTestScan()

        let validRatings = ["Excellent", "Good", "Fair", "Poor"]
        XCTAssertTrue(validRatings.contains(scan.qualityRating))
    }

    func testGenerateTestScan_ScoresInValidRange() {
        let service = MockScannerService()
        let scan = service.generateTestScan()

        XCTAssertGreaterThanOrEqual(scan.qualityScore, 0.0)
        XCTAssertLessThanOrEqual(scan.qualityScore, 1.0)
        XCTAssertGreaterThanOrEqual(scan.sharpness, 0.0)
        XCTAssertLessThanOrEqual(scan.sharpness, 1.0)
    }
}
