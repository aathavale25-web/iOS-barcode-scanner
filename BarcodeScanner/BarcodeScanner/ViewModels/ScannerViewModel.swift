import SwiftUI
import AVFoundation
import Combine

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var isShowingResult = false
    @Published var scannedContent: String = ""
    @Published var scannedType: String = ""
    @Published var qualityMetrics: QualityMetrics?
    @Published var permissionDenied = false

    // Set to false to use real camera, true for mock mode
    @Published var mockModeEnabled = false

    private let scannerService = BarcodeScannerService()
    private let qualityService = QualityAssessmentService()
    private let permissionManager = CameraPermissionManager()
    private var cancellables = Set<AnyCancellable>()

    #if DEBUG
    private let mockService = MockScannerService()
    #endif

    init() {
        // Subscribe to barcode scans from the scanner service
        scannerService.$scannedBarcode
            .compactMap { $0 } // Filter out nil values
            .sink { [weak self] scannedBarcode in
                Task { @MainActor in
                    await self?.processScan(scannedBarcode)
                }
            }
            .store(in: &cancellables)
    }

    private func processScan(_ scannedBarcode: ScannedBarcode) async {
        // Stop scanning temporarily to prevent multiple scans
        scannerService.stopScanning()

        // Get barcode type name
        scannedType = getBarcodeTypeName(scannedBarcode.type)
        scannedContent = scannedBarcode.content

        // Analyze quality if we have an image
        if let image = scannedBarcode.image {
            qualityMetrics = await qualityService.analyzeImage(image, decodeConfidence: scannedBarcode.confidence)
        } else {
            // No image, use decode confidence only
            qualityMetrics = QualityMetrics(
                sharpness: 0.7,
                contrast: 0.7,
                brightness: 0.7,
                decodeConfidence: scannedBarcode.confidence
            )
        }

        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Show result
        isShowingResult = true
    }

    private func getBarcodeTypeName(_ type: AVMetadataObject.ObjectType) -> String {
        switch type {
        case .code128: return "Code 128"
        case .code93: return "Code 93"
        case .qr: return "QR Code"
        case .upce: return "UPC-E"
        case .ean8: return "EAN-8"
        case .ean13: return "EAN-13 / UPC-A"
        default: return "Unknown"
        }
    }

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

        // Restart scanning
        if !mockModeEnabled {
            scannerService.startScanning()
        }
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
