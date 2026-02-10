import XCTest
import SwiftData
@testable import BarcodeScanner

final class ScanRecordTests: XCTestCase {
    func testScanRecordCreation() {
        let record = ScanRecord(
            barcodeType: "Code 128",
            content: "123456789",
            qualityRating: "Excellent",
            qualityScore: 0.95,
            sharpness: 0.9,
            contrast: 0.85,
            brightness: 0.7,
            decodeConfidence: 0.98
        )

        XCTAssertEqual(record.barcodeType, "Code 128")
        XCTAssertEqual(record.content, "123456789")
        XCTAssertEqual(record.qualityRating, "Excellent")
        XCTAssertEqual(record.qualityScore, 0.95, accuracy: 0.01)
    }
}
