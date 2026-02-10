import XCTest
import AVFoundation
@testable import BarcodeScanner

final class BarcodeScannerServiceTests: XCTestCase {
    func testSupportedBarcodeTypes() {
        let service = BarcodeScannerService()
        let types = service.supportedBarcodeTypes()

        XCTAssertTrue(types.contains(.code128))
        XCTAssertTrue(types.contains(.code93))
        XCTAssertTrue(types.contains(.qr))
    }
}
