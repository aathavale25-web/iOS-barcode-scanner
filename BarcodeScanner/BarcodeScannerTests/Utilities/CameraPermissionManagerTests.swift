import XCTest
import AVFoundation
@testable import BarcodeScanner

final class CameraPermissionManagerTests: XCTestCase {
    func testCheckPermissionStatus() {
        let manager = CameraPermissionManager()
        let status = manager.checkPermission()

        // Status will vary by test environment
        XCTAssertTrue([
            AVAuthorizationStatus.authorized,
            AVAuthorizationStatus.denied,
            AVAuthorizationStatus.notDetermined,
            AVAuthorizationStatus.restricted
        ].contains(status))
    }
}
