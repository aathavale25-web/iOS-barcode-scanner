import SwiftUI
import AVFoundation

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var isShowingResult = false
    @Published var scannedContent: String = ""
    @Published var scannedType: String = ""
    @Published var qualityMetrics: QualityMetrics?
    @Published var permissionDenied = false

    #if DEBUG
    @Published var mockModeEnabled = true
    #else
    @Published var mockModeEnabled = false
    #endif

    private let scannerService = BarcodeScannerService()
    private let qualityService = QualityAssessmentService()
    private let permissionManager = CameraPermissionManager()

    #if DEBUG
    private let mockService = MockScannerService()
    #endif

    func checkPermissions() async {
        let status = permissionManager.checkPermission()

        switch status {
        case .notDetermined:
            let granted = await permissionManager.requestPermission()
            permissionDenied = !granted
        case .denied, .restricted:
            permissionDenied = true
        case .authorized:
            permissionDenied = false
        @unknown default:
            permissionDenied = true
        }
    }

    func handleMockScan() {
        #if DEBUG
        guard mockModeEnabled else { return }

        let mockResult = mockService.generateTestScan()

        scannedContent = mockResult.content
        scannedType = mockResult.barcodeType
        qualityMetrics = QualityMetrics(
            sharpness: mockResult.sharpness,
            contrast: mockResult.contrast,
            brightness: mockResult.brightness,
            decodeConfidence: mockResult.decodeConfidence
        )
        isShowingResult = true
        #endif
    }

    func resetScan() {
        isShowingResult = false
        scannedContent = ""
        scannedType = ""
        qualityMetrics = nil
    }

    func setupCamera() -> AVCaptureVideoPreviewLayer? {
        return scannerService.setupCamera()
    }

    func startScanning() {
        scannerService.startScanning()
    }

    func stopScanning() {
        scannerService.stopScanning()
    }
}
