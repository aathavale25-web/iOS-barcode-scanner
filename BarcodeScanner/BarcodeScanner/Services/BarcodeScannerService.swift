import AVFoundation
import UIKit
import Combine

struct ScannedBarcode {
    let type: AVMetadataObject.ObjectType
    let content: String
    let image: UIImage?
    let confidence: Double
    let bounds: CGRect? // Position in the camera preview
    let id: String // Unique identifier

    init(type: AVMetadataObject.ObjectType, content: String, image: UIImage?, confidence: Double, bounds: CGRect? = nil) {
        self.type = type
        self.content = content
        self.image = image
        self.confidence = confidence
        self.bounds = bounds
        self.id = UUID().uuidString
    }
}

class BarcodeScannerService: NSObject, ObservableObject {
    @Published var scannedBarcode: ScannedBarcode?
    @Published var scannedBarcodes: [ScannedBarcode] = [] // For multi-scan mode
    @Published var error: String?

    var multiScanMode: Bool = false

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func supportedBarcodeTypes() -> [AVMetadataObject.ObjectType] {
        return [
            .code128,
            .code93,
            .qr,
            .upce,      // UPC-E
            .ean8,      // EAN-8
            .ean13      // EAN-13 (includes UPC-A)
        ]
    }

    func setupCamera() -> AVCaptureVideoPreviewLayer? {
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video) else {
            error = "No camera available"
            return nil
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                error = "Could not add camera input"
                return nil
            }

            let output = AVCaptureMetadataOutput()

            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = supportedBarcodeTypes()
            } else {
                error = "Could not add metadata output"
                return nil
            }

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill

            self.captureSession = session
            self.previewLayer = preview

            return preview

        } catch {
            self.error = "Camera setup failed: \(error.localizedDescription)"
            return nil
        }
    }

    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
}

extension BarcodeScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if multiScanMode {
            // Multi-scan mode: process all detected barcodes
            let barcodes = metadataObjects.compactMap { object -> ScannedBarcode? in
                guard let readableObject = object as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue else {
                    return nil
                }

                // Convert bounds to preview layer coordinates
                let bounds = previewLayer?.transformedMetadataObject(for: readableObject)?.bounds

                let placeholderImage = UIImage(systemName: "barcode")

                return ScannedBarcode(
                    type: readableObject.type,
                    content: stringValue,
                    image: placeholderImage,
                    confidence: 0.95,
                    bounds: bounds
                )
            }

            DispatchQueue.main.async {
                self.scannedBarcodes = barcodes
            }
        } else {
            // Single-scan mode: process only first barcode
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let stringValue = metadataObject.stringValue else {
                return
            }

            let placeholderImage = UIImage(systemName: "barcode")

            let barcode = ScannedBarcode(
                type: metadataObject.type,
                content: stringValue,
                image: placeholderImage,
                confidence: 0.95
            )

            DispatchQueue.main.async {
                self.scannedBarcode = barcode
            }
        }
    }
}
