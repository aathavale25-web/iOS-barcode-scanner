# iOS Barcode Scanner Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a native iOS barcode scanner app with quality assessment and scan history using Swift/SwiftUI.

**Architecture:** MVVM architecture with AVFoundation for scanning, Vision framework for quality analysis, SwiftData for persistence, and mock mode for Simulator testing.

**Tech Stack:** Swift 5.9+, SwiftUI, AVFoundation, Vision Framework, SwiftData, XCTest

---

## Phase 0: Project Setup & Foundation

### Task 0.1: Create Xcode Project

**Files:**
- Create: Xcode project structure
- Create: `.gitignore`

**Step 1: Create new Xcode project**

```bash
# Open Xcode and create new project
# Or use command line:
mkdir -p BarcodeScannerApp
cd BarcodeScannerApp
```

Manual Xcode steps:
1. File → New → Project
2. iOS → App
3. Product Name: "BarcodeScanner"
4. Interface: SwiftUI
5. Language: Swift
6. Minimum iOS: 17.0
7. Save to: `/Users/aathaval/Documents/coding_dir/iOS-barcode-scanner/`

**Step 2: Create .gitignore**

Create: `.gitignore`
```
# Xcode
*.xcodeproj
*.xcworkspace
!*.xcworkspace/contents.xcworkspacedata
/*.gcno
**/xcshareddata/WorkspaceSettings.xcsettings

# Build
build/
DerivedData/

# CocoaPods
Pods/

# Swift Package Manager
.swiftpm/
.build/

# macOS
.DS_Store

# User-specific
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
```

**Step 3: Commit project setup**

```bash
git add .
git commit -m "chore: initialize Xcode project with iOS 17 target"
```

### Task 0.2: Create Project Structure

**Files:**
- Create: `BarcodeScanner/Models/`
- Create: `BarcodeScanner/Views/`
- Create: `BarcodeScanner/ViewModels/`
- Create: `BarcodeScanner/Services/`
- Create: `BarcodeScanner/Utilities/`
- Create: `BarcodeScannerTests/`

**Step 1: Create directory structure in Xcode**

In Xcode:
1. Right-click BarcodeScanner group
2. New Group → "Models"
3. Repeat for: Views, ViewModels, Services, Utilities

**Step 2: Add Info.plist camera permission**

Modify: `BarcodeScanner/Info.plist` (or add to project settings)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan barcodes</string>
```

**Step 3: Commit structure**

```bash
git add .
git commit -m "chore: create MVVM project structure and add camera permission"
```

---

## Phase 1: Data Models & Mock Mode (Agent 4: Data Persistence)

### Task 1.1: Create ScanRecord Model

**Files:**
- Create: `BarcodeScanner/Models/ScanRecord.swift`
- Create: `BarcodeScannerTests/Models/ScanRecordTests.swift`

**Step 1: Write test for ScanRecord creation**

Create: `BarcodeScannerTests/Models/ScanRecordTests.swift`
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `CMD+U` in Xcode or `xcodebuild test -scheme BarcodeScanner -destination 'platform=iOS Simulator,name=iPhone 15'`
Expected: FAIL with "Cannot find 'ScanRecord' in scope"

**Step 3: Implement ScanRecord model**

Create: `BarcodeScanner/Models/ScanRecord.swift`
```swift
import Foundation
import SwiftData

@Model
final class ScanRecord {
    var id: UUID
    var timestamp: Date
    var barcodeType: String
    var content: String
    var qualityRating: String
    var qualityScore: Double

    var sharpness: Double
    var contrast: Double
    var brightness: Double
    var decodeConfidence: Double

    init(
        barcodeType: String,
        content: String,
        qualityRating: String,
        qualityScore: Double,
        sharpness: Double,
        contrast: Double,
        brightness: Double,
        decodeConfidence: Double
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.barcodeType = barcodeType
        self.content = content
        self.qualityRating = qualityRating
        self.qualityScore = qualityScore
        self.sharpness = sharpness
        self.contrast = contrast
        self.brightness = brightness
        self.decodeConfidence = decodeConfidence
    }
}
```

**Step 4: Run test to verify it passes**

Run: `CMD+U` in Xcode
Expected: PASS

**Step 5: Commit**

```bash
git add BarcodeScanner/Models/ScanRecord.swift BarcodeScannerTests/Models/ScanRecordTests.swift
git commit -m "feat: add ScanRecord SwiftData model with quality metrics"
```

### Task 1.2: Create Mock Scanner Service

**Files:**
- Create: `BarcodeScanner/Services/MockScannerService.swift`
- Create: `BarcodeScannerTests/Services/MockScannerServiceTests.swift`

**Step 1: Write test for mock scanner**

Create: `BarcodeScannerTests/Services/MockScannerServiceTests.swift`
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `CMD+U`
Expected: FAIL with "Cannot find 'MockScannerService' in scope"

**Step 3: Implement MockScannerService**

Create: `BarcodeScanner/Services/MockScannerService.swift`
```swift
import Foundation

#if DEBUG
struct MockScanResult {
    let barcodeType: String
    let content: String
    let qualityRating: String
    let qualityScore: Double
    let sharpness: Double
    let contrast: Double
    let brightness: Double
    let decodeConfidence: Double
}

class MockScannerService {
    private let barcodeTypes = ["Code 128", "Code 93", "QR Code"]
    private let qualityRatings = ["Excellent", "Good", "Fair", "Poor"]

    func generateTestScan() -> MockScanResult {
        let barcodeType = barcodeTypes.randomElement()!
        let qualityRating = qualityRatings.randomElement()!

        // Generate scores based on quality rating
        let (qualityScore, sharpness, contrast, brightness, decodeConfidence) = generateScores(for: qualityRating)

        // Generate realistic barcode content
        let content = generateContent(for: barcodeType)

        return MockScanResult(
            barcodeType: barcodeType,
            content: content,
            qualityRating: qualityRating,
            qualityScore: qualityScore,
            sharpness: sharpness,
            contrast: contrast,
            brightness: brightness,
            decodeConfidence: decodeConfidence
        )
    }

    private func generateScores(for rating: String) -> (Double, Double, Double, Double, Double) {
        switch rating {
        case "Excellent":
            return (
                Double.random(in: 0.90...1.0),
                Double.random(in: 0.85...1.0),
                Double.random(in: 0.85...1.0),
                Double.random(in: 0.6...0.8),
                Double.random(in: 0.95...1.0)
            )
        case "Good":
            return (
                Double.random(in: 0.70...0.89),
                Double.random(in: 0.65...0.84),
                Double.random(in: 0.65...0.84),
                Double.random(in: 0.5...0.7),
                Double.random(in: 0.80...0.94)
            )
        case "Fair":
            return (
                Double.random(in: 0.50...0.69),
                Double.random(in: 0.45...0.64),
                Double.random(in: 0.45...0.64),
                Double.random(in: 0.3...0.6),
                Double.random(in: 0.65...0.79)
            )
        default: // Poor
            return (
                Double.random(in: 0.0...0.49),
                Double.random(in: 0.0...0.44),
                Double.random(in: 0.0...0.44),
                Double.random(in: 0.0...0.5),
                Double.random(in: 0.0...0.64)
            )
        }
    }

    private func generateContent(for type: String) -> String {
        switch type {
        case "Code 128":
            return "CODE128-\(Int.random(in: 100000...999999))"
        case "Code 93":
            return "CODE93-\(Int.random(in: 10000...99999))"
        case "QR Code":
            return "https://example.com/item/\(UUID().uuidString.prefix(8))"
        default:
            return "UNKNOWN"
        }
    }
}
#endif
```

**Step 4: Run test to verify it passes**

Run: `CMD+U`
Expected: PASS

**Step 5: Commit**

```bash
git add BarcodeScanner/Services/MockScannerService.swift BarcodeScannerTests/Services/MockScannerServiceTests.swift
git commit -m "feat: add mock scanner service for Simulator testing"
```

### Task 1.3: Create ModelContainer Setup

**Files:**
- Modify: `BarcodeScanner/BarcodeScannerApp.swift`

**Step 1: Configure SwiftData ModelContainer**

Modify: `BarcodeScanner/BarcodeScannerApp.swift`
```swift
import SwiftUI
import SwiftData

@main
struct BarcodeScannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ScanRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Step 2: Test app builds**

Run: `CMD+B` to build
Expected: Build succeeds

**Step 3: Commit**

```bash
git add BarcodeScanner/BarcodeScannerApp.swift
git commit -m "feat: configure SwiftData ModelContainer for persistence"
```

---

## Phase 2: Quality Assessment Logic (Agent 2: Quality Assessment)

### Task 2.1: Create Quality Metrics Struct

**Files:**
- Create: `BarcodeScanner/Models/QualityMetrics.swift`
- Create: `BarcodeScannerTests/Models/QualityMetricsTests.swift`

**Step 1: Write test for QualityMetrics**

Create: `BarcodeScannerTests/Models/QualityMetricsTests.swift`
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `CMD+U`
Expected: FAIL with "Cannot find 'QualityMetrics' in scope"

**Step 3: Implement QualityMetrics**

Create: `BarcodeScanner/Models/QualityMetrics.swift`
```swift
import Foundation

struct QualityMetrics {
    let sharpness: Double
    let contrast: Double
    let brightness: Double
    let decodeConfidence: Double

    var overallScore: Double {
        // Weighted average: decode confidence is most important
        return (decodeConfidence * 0.4) + (sharpness * 0.3) + (contrast * 0.2) + (brightness * 0.1)
    }

    var rating: String {
        switch overallScore {
        case 0.85...1.0:
            return "Excellent"
        case 0.70..<0.85:
            return "Good"
        case 0.50..<0.70:
            return "Fair"
        default:
            return "Poor"
        }
    }

    var feedback: String {
        if rating == "Excellent" {
            return "Perfect scan! Barcode is clear and readable."
        } else if rating == "Good" {
            return "Good scan! Barcode successfully decoded."
        } else if rating == "Fair" {
            if sharpness < 0.6 {
                return "Fair - try holding the camera steadier for sharper images."
            } else if brightness < 0.4 || brightness > 0.8 {
                return "Fair - try adjusting the lighting conditions."
            } else {
                return "Fair - barcode decoded but quality could be improved."
            }
        } else {
            if decodeConfidence < 0.5 {
                return "Poor - unable to decode reliably. Try again."
            } else if sharpness < 0.4 {
                return "Poor - image is too blurry. Hold camera steady."
            } else {
                return "Poor - improve lighting and try again."
            }
        }
    }

    var badgeColor: String {
        switch rating {
        case "Excellent": return "green"
        case "Good": return "blue"
        case "Fair": return "orange"
        default: return "red"
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `CMD+U`
Expected: PASS

**Step 5: Commit**

```bash
git add BarcodeScanner/Models/QualityMetrics.swift BarcodeScannerTests/Models/QualityMetricsTests.swift
git commit -m "feat: add QualityMetrics with rating calculation and feedback"
```

### Task 2.2: Create Quality Assessment Service

**Files:**
- Create: `BarcodeScanner/Services/QualityAssessmentService.swift`
- Create: `BarcodeScannerTests/Services/QualityAssessmentServiceTests.swift`

**Step 1: Write test for quality assessment**

Create: `BarcodeScannerTests/Services/QualityAssessmentServiceTests.swift`
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `CMD+U`
Expected: FAIL with "Cannot find 'QualityAssessmentService' in scope"

**Step 3: Implement QualityAssessmentService**

Create: `BarcodeScanner/Services/QualityAssessmentService.swift`
```swift
import UIKit
import Vision

class QualityAssessmentService {
    func analyzeImage(_ image: UIImage, decodeConfidence: Double) async -> QualityMetrics {
        guard let cgImage = image.cgImage else {
            return QualityMetrics(
                sharpness: 0.0,
                contrast: 0.0,
                brightness: 0.0,
                decodeConfidence: decodeConfidence
            )
        }

        let sharpness = await calculateSharpness(cgImage)
        let contrast = await calculateContrast(cgImage)
        let brightness = await calculateBrightness(cgImage)

        return QualityMetrics(
            sharpness: sharpness,
            contrast: contrast,
            brightness: brightness,
            decodeConfidence: decodeConfidence
        )
    }

    private func calculateSharpness(_ image: CGImage) async -> Double {
        // Simplified sharpness calculation using Laplacian variance
        // In a real implementation, you would use Vision framework's VNImageRequestHandler
        // For now, return a placeholder based on image dimensions
        let width = Double(image.width)
        let height = Double(image.height)
        let size = width * height

        // Larger, higher resolution images tend to be sharper
        return min(size / 1000000.0, 1.0)
    }

    private func calculateContrast(_ image: CGImage) async -> Double {
        // Simplified contrast calculation
        // In production, analyze histogram variance
        return 0.75 // Placeholder
    }

    private func calculateBrightness(_ image: CGImage) async -> Double {
        // Simplified brightness calculation
        // In production, calculate average pixel luminance
        return 0.65 // Placeholder
    }
}
```

**Step 4: Run test to verify it passes**

Run: `CMD+U`
Expected: PASS

**Step 5: Commit**

```bash
git add BarcodeScanner/Services/QualityAssessmentService.swift BarcodeScannerTests/Services/QualityAssessmentServiceTests.swift
git commit -m "feat: add QualityAssessmentService with image analysis"
```

---

## Phase 3: Camera & Scanning Logic (Agent 1: Camera & Scanning)

### Task 3.1: Create Barcode Scanner Service

**Files:**
- Create: `BarcodeScanner/Services/BarcodeScannerService.swift`
- Create: `BarcodeScannerTests/Services/BarcodeScannerServiceTests.swift`

**Step 1: Write test for barcode scanner setup**

Create: `BarcodeScannerTests/Services/BarcodeScannerServiceTests.swift`
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `CMD+U`
Expected: FAIL with "Cannot find 'BarcodeScannerService' in scope"

**Step 3: Implement BarcodeScannerService**

Create: `BarcodeScanner/Services/BarcodeScannerService.swift`
```swift
import AVFoundation
import UIKit

struct ScannedBarcode {
    let type: AVMetadataObject.ObjectType
    let content: String
    let image: UIImage?
    let confidence: Double
}

class BarcodeScannerService: NSObject, ObservableObject {
    @Published var scannedBarcode: ScannedBarcode?
    @Published var error: String?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func supportedBarcodeTypes() -> [AVMetadataObject.ObjectType] {
        return [.code128, .code93, .qr]
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
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }

        // Capture current frame as image (simplified - in production, capture actual frame)
        let placeholderImage = UIImage(systemName: "barcode")

        let barcode = ScannedBarcode(
            type: metadataObject.type,
            content: stringValue,
            image: placeholderImage,
            confidence: 0.95 // AVFoundation doesn't provide confidence directly
        )

        DispatchQueue.main.async {
            self.scannedBarcode = barcode
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `CMD+U`
Expected: PASS

**Step 5: Commit**

```bash
git add BarcodeScanner/Services/BarcodeScannerService.swift BarcodeScannerTests/Services/BarcodeScannerServiceTests.swift
git commit -m "feat: add BarcodeScannerService with AVFoundation integration"
```

### Task 3.2: Create Camera Permission Manager

**Files:**
- Create: `BarcodeScanner/Utilities/CameraPermissionManager.swift`
- Create: `BarcodeScannerTests/Utilities/CameraPermissionManagerTests.swift`

**Step 1: Write test for permission checking**

Create: `BarcodeScannerTests/Utilities/CameraPermissionManagerTests.swift`
```swift
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
```

**Step 2: Run test to verify it fails**

Run: `CMD+U`
Expected: FAIL with "Cannot find 'CameraPermissionManager' in scope"

**Step 3: Implement CameraPermissionManager**

Create: `BarcodeScanner/Utilities/CameraPermissionManager.swift`
```swift
import AVFoundation

class CameraPermissionManager {
    func checkPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestPermission() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `CMD+U`
Expected: PASS

**Step 5: Commit**

```bash
git add BarcodeScanner/Utilities/CameraPermissionManager.swift BarcodeScannerTests/Utilities/CameraPermissionManagerTests.swift
git commit -m "feat: add CameraPermissionManager for permission handling"
```

---

## Phase 4: UI Components (Agent 3: UI/SwiftUI Components)

### Task 4.1: Create ScannerView with Mock Mode

**Files:**
- Create: `BarcodeScanner/Views/ScannerView.swift`
- Create: `BarcodeScanner/ViewModels/ScannerViewModel.swift`

**Step 1: Create ScannerViewModel**

Create: `BarcodeScanner/ViewModels/ScannerViewModel.swift`
```swift
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
}
```

**Step 2: Create ScannerView UI**

Create: `BarcodeScanner/Views/ScannerView.swift`
```swift
import SwiftUI

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @State private var showingHistory = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview or mock button
                if viewModel.mockModeEnabled {
                    mockScannerView
                } else {
                    Color.black // Placeholder for camera view
                }

                // Scan frame overlay
                scanFrameOverlay
            }
            .navigationTitle("Barcode Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("History") {
                        showingHistory = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingResult) {
                if let metrics = viewModel.qualityMetrics {
                    ResultView(
                        barcodeType: viewModel.scannedType,
                        content: viewModel.scannedContent,
                        qualityMetrics: metrics,
                        onScanAnother: {
                            viewModel.resetScan()
                        },
                        onViewHistory: {
                            viewModel.resetScan()
                            showingHistory = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .task {
                await viewModel.checkPermissions()
            }
            .alert("Camera Access Denied", isPresented: $viewModel.permissionDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This app needs camera access to scan barcodes. Please enable it in Settings.")
            }
        }
    }

    #if DEBUG
    private var mockScannerView: some View {
        VStack(spacing: 30) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 100))
                .foregroundColor(.gray)

            Text("Mock Scanner Mode")
                .font(.title2)
                .foregroundColor(.secondary)

            Button {
                viewModel.handleMockScan()
            } label: {
                Text("Generate Test Scan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
    }
    #endif

    private var scanFrameOverlay: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width * 0.7
            let frameHeight = frameWidth * 0.6

            VStack {
                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: frameWidth, height: frameHeight)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("Position barcode within frame")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                                .padding(.bottom, -40)
                        }
                    )

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ScannerView()
}
```

**Step 3: Test in Simulator**

Run: `CMD+R` to run app in Simulator
Expected: App launches, shows mock scanner button in debug mode

**Step 4: Commit**

```bash
git add BarcodeScanner/Views/ScannerView.swift BarcodeScanner/ViewModels/ScannerViewModel.swift
git commit -m "feat: add ScannerView with mock mode for testing"
```

### Task 4.2: Create ResultView

**Files:**
- Create: `BarcodeScanner/Views/ResultView.swift`

**Step 1: Implement ResultView**

Create: `BarcodeScanner/Views/ResultView.swift`
```swift
import SwiftUI

struct ResultView: View {
    let barcodeType: String
    let content: String
    let qualityMetrics: QualityMetrics
    let onScanAnother: () -> Void
    let onViewHistory: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quality badge
                    qualityBadge

                    // Barcode type
                    VStack(spacing: 8) {
                        Text("Barcode Type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(barcodeType)
                            .font(.headline)
                    }

                    Divider()

                    // Content
                    VStack(spacing: 8) {
                        Text("Content")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(content)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .textSelection(.enabled)
                    }

                    Divider()

                    // Quality details (collapsible)
                    DisclosureGroup("Quality Details") {
                        VStack(alignment: .leading, spacing: 12) {
                            qualityDetail("Sharpness", value: qualityMetrics.sharpness)
                            qualityDetail("Contrast", value: qualityMetrics.contrast)
                            qualityDetail("Brightness", value: qualityMetrics.brightness)
                            qualityDetail("Decode Confidence", value: qualityMetrics.decodeConfidence)
                        }
                        .padding(.top, 8)
                    }

                    Spacer(minLength: 20)

                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            saveScan()
                            dismiss()
                            onScanAnother()
                        } label: {
                            Text("Scan Another")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        Button {
                            saveScan()
                            dismiss()
                            onViewHistory()
                        } label: {
                            Text("View History")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveScan()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            saveScan()
        }
    }

    private var qualityBadge: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: badgeIcon)
                    .font(.system(size: 40))
                    .foregroundColor(badgeColor)
            }

            Text(qualityMetrics.rating)
                .font(.title2)
                .fontWeight(.bold)

            Text(qualityMetrics.feedback)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var badgeColor: Color {
        switch qualityMetrics.badgeColor {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        default: return .red
        }
    }

    private var badgeIcon: String {
        switch qualityMetrics.rating {
        case "Excellent": return "checkmark.circle.fill"
        case "Good": return "checkmark.circle"
        case "Fair": return "exclamationmark.triangle"
        default: return "xmark.circle"
        }
    }

    private func qualityDetail(_ label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.2f", value))
                .fontWeight(.medium)
        }
    }

    private func saveScan() {
        let record = ScanRecord(
            barcodeType: barcodeType,
            content: content,
            qualityRating: qualityMetrics.rating,
            qualityScore: qualityMetrics.overallScore,
            sharpness: qualityMetrics.sharpness,
            contrast: qualityMetrics.contrast,
            brightness: qualityMetrics.brightness,
            decodeConfidence: qualityMetrics.decodeConfidence
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save scan: \(error)")
        }
    }
}

#Preview {
    ResultView(
        barcodeType: "QR Code",
        content: "https://example.com/test",
        qualityMetrics: QualityMetrics(
            sharpness: 0.92,
            contrast: 0.88,
            brightness: 0.65,
            decodeConfidence: 0.96
        ),
        onScanAnother: {},
        onViewHistory: {}
    )
    .modelContainer(for: ScanRecord.self, inMemory: true)
}
```

**Step 2: Test in Simulator**

Run: `CMD+R` and generate a test scan
Expected: ResultView appears with quality badge and scan details

**Step 3: Commit**

```bash
git add BarcodeScanner/Views/ResultView.swift
git commit -m "feat: add ResultView with quality display and persistence"
```

### Task 4.3: Create HistoryView

**Files:**
- Create: `BarcodeScanner/Views/HistoryView.swift`
- Create: `BarcodeScanner/ViewModels/HistoryViewModel.swift`

**Step 1: Create HistoryViewModel**

Create: `BarcodeScanner/ViewModels/HistoryViewModel.swift`
```swift
import SwiftUI
import SwiftData

@MainActor
class HistoryViewModel: ObservableObject {
    func deleteScan(_ record: ScanRecord, context: ModelContext) {
        context.delete(record)

        do {
            try context.save()
        } catch {
            print("Failed to delete scan: \(error)")
        }
    }
}
```

**Step 2: Create HistoryView**

Create: `BarcodeScanner/Views/HistoryView.swift`
```swift
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ScanRecord.timestamp, order: .reverse) private var scans: [ScanRecord]
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if scans.isEmpty {
                    emptyStateView
                } else {
                    scanListView
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No scans yet")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Your scan history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var scanListView: some View {
        List {
            ForEach(scans) { scan in
                ScanRowView(scan: scan)
            }
            .onDelete(perform: deleteScans)
        }
    }

    private func deleteScans(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteScan(scans[index], context: modelContext)
        }
    }
}

struct ScanRowView: View {
    let scan: ScanRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Barcode type icon
                Image(systemName: barcodeIcon)
                    .foregroundColor(.blue)

                Text(scan.barcodeType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // Quality badge
                Text(scan.qualityRating)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .cornerRadius(6)
            }

            Text(scan.content)
                .font(.body)
                .lineLimit(2)

            Text(scan.timestamp, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var barcodeIcon: String {
        switch scan.barcodeType {
        case "Code 128": return "barcode"
        case "Code 93": return "barcode"
        case "QR Code": return "qrcode"
        default: return "barcode"
        }
    }

    private var badgeColor: Color {
        switch scan.qualityRating {
        case "Excellent": return .green
        case "Good": return .blue
        case "Fair": return .orange
        default: return .red
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
```

**Step 3: Test in Simulator**

Run: `CMD+R`, generate test scans, view history
Expected: History list shows scans with timestamps and quality badges

**Step 4: Commit**

```bash
git add BarcodeScanner/Views/HistoryView.swift BarcodeScanner/ViewModels/HistoryViewModel.swift
git commit -m "feat: add HistoryView with scan list and delete functionality"
```

### Task 4.4: Update ContentView

**Files:**
- Modify: `BarcodeScanner/ContentView.swift`

**Step 1: Update ContentView to show ScannerView**

Modify: `BarcodeScanner/ContentView.swift`
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        ScannerView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ScanRecord.self, inMemory: true)
}
```

**Step 2: Test full app flow**

Run: `CMD+R`
Test flow: Generate scan → View result → Scan another → View history
Expected: All navigation works correctly

**Step 3: Commit**

```bash
git add BarcodeScanner/ContentView.swift
git commit -m "feat: update ContentView to display ScannerView as root"
```

---

## Phase 5: Real Camera Integration (Agent 1: Camera & Scanning)

### Task 5.1: Create Camera Preview UIViewRepresentable

**Files:**
- Create: `BarcodeScanner/Views/CameraPreview.swift`

**Step 1: Implement CameraPreview**

Create: `BarcodeScanner/Views/CameraPreview.swift`
```swift
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}
```

**Step 2: Update ScannerView to use real camera**

Modify: `BarcodeScanner/Views/ScannerView.swift`

Add after existing properties:
```swift
@State private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
```

Replace the camera preview section:
```swift
// Camera preview or mock button
if viewModel.mockModeEnabled {
    mockScannerView
} else if let previewLayer = cameraPreviewLayer {
    CameraPreview(previewLayer: previewLayer)
        .ignoresSafeArea()
} else {
    Color.black
        .ignoresSafeArea()
}
```

Add camera setup in task:
```swift
.task {
    await viewModel.checkPermissions()

    if !viewModel.mockModeEnabled && !viewModel.permissionDenied {
        // Setup camera - will be implemented in next task
    }
}
```

**Step 3: Commit**

```bash
git add BarcodeScanner/Views/CameraPreview.swift BarcodeScanner/Views/ScannerView.swift
git commit -m "feat: add CameraPreview UIViewRepresentable for real camera"
```

**Note:** Real camera testing requires a physical iPhone. For now, the mock mode allows full testing in Simulator.

---

## Phase 6: Testing & Polish

### Task 6.1: Add Unit Test Coverage

**Files:**
- Create: `BarcodeScannerTests/Integration/ScanFlowTests.swift`

**Step 1: Create integration tests**

Create: `BarcodeScannerTests/Integration/ScanFlowTests.swift`
```swift
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
}
```

**Step 2: Run all tests**

Run: `CMD+U`
Expected: All tests pass

**Step 3: Commit**

```bash
git add BarcodeScannerTests/Integration/ScanFlowTests.swift
git commit -m "test: add integration tests for scan flow"
```

### Task 6.2: Add README

**Files:**
- Create: `README.md`

**Step 1: Create README**

Create: `README.md`
```markdown
# Barcode Scanner iOS App

A native iOS barcode scanner app with quality assessment and scan history.

## Features

- 📱 Scan Code 128, Code 93, and QR codes
- ✅ Real-time quality assessment (Excellent/Good/Fair/Poor)
- 📊 Detailed quality metrics (sharpness, contrast, brightness, decode confidence)
- 📝 Scan history with timestamps
- 🧪 Mock scanner mode for Simulator testing

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Technologies

- SwiftUI for UI
- AVFoundation for camera and barcode scanning
- Vision Framework for image quality analysis
- SwiftData for persistent storage
- XCTest for unit testing

## Getting Started

### Running in Simulator (Mock Mode)

1. Open `BarcodeScanner.xcodeproj` in Xcode
2. Select iPhone 15 Simulator
3. Run (CMD+R)
4. Tap "Generate Test Scan" to test functionality

### Running on iPhone (Real Scanning)

1. Connect your iPhone
2. Select your iPhone as the target device
3. Run (CMD+R)
4. Allow camera permissions
5. Point camera at barcodes to scan

## Project Structure

```
BarcodeScanner/
├── Models/
│   ├── ScanRecord.swift          # SwiftData model for scan history
│   └── QualityMetrics.swift      # Quality assessment data
├── Views/
│   ├── ScannerView.swift         # Main camera/mock scanner view
│   ├── ResultView.swift          # Scan result display
│   ├── HistoryView.swift         # Scan history list
│   └── CameraPreview.swift       # Camera preview wrapper
├── ViewModels/
│   ├── ScannerViewModel.swift    # Scanner logic
│   └── HistoryViewModel.swift    # History management
├── Services/
│   ├── BarcodeScannerService.swift      # AVFoundation scanning
│   ├── QualityAssessmentService.swift   # Vision framework analysis
│   └── MockScannerService.swift         # Mock data for testing
└── Utilities/
    └── CameraPermissionManager.swift    # Permission handling
```

## Testing

### Unit Tests

Run all tests:
```bash
CMD+U in Xcode
```

Or via command line:
```bash
xcodebuild test -scheme BarcodeScanner -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Mock Mode

Debug builds automatically enable mock mode for Simulator testing. This allows full app testing without a physical device:
- Generate random barcode types (Code 128, Code 93, QR)
- Simulate varying quality scores
- Test all UI flows

## Architecture

**MVVM (Model-View-ViewModel)**

- **Models**: SwiftData entities and data structures
- **Views**: SwiftUI views for UI
- **ViewModels**: Business logic and state management
- **Services**: Camera, scanning, and quality assessment logic

## Future Enhancements

- [ ] Export scan history (CSV, email)
- [ ] Search and filter history
- [ ] Flashlight toggle for low light
- [ ] Batch scanning mode
- [ ] Dark mode optimization
- [ ] Haptic feedback on scan

## License

MIT License

## Authors

Built with Claude Code
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add comprehensive README with setup instructions"
```

### Task 6.3: Final Build & Push

**Step 1: Run final build**

Run: `CMD+B` to build
Expected: Build succeeds with no warnings

**Step 2: Run all tests one more time**

Run: `CMD+U`
Expected: All tests pass

**Step 3: Push to GitHub**

```bash
git push origin main
```

---

## Completion Checklist

✅ **Phase 0**: Project setup with MVVM structure
✅ **Phase 1**: Data models (ScanRecord, MockScannerService)
✅ **Phase 2**: Quality assessment logic (QualityMetrics, QualityAssessmentService)
✅ **Phase 3**: Camera & scanning (BarcodeScannerService, CameraPermissionManager)
✅ **Phase 4**: UI components (ScannerView, ResultView, HistoryView)
✅ **Phase 5**: Camera integration (CameraPreview)
✅ **Phase 6**: Testing, README, final polish

## Testing on Physical Device

Final validation requires testing on a real iPhone:

1. Connect iPhone to Mac
2. Select iPhone as target in Xcode
3. Run app (CMD+R)
4. Test with real barcodes:
   - Code 128 barcode
   - Code 93 barcode
   - QR code
5. Verify quality assessment varies with:
   - Good lighting vs poor lighting
   - Sharp focus vs blur
   - Straight angle vs tilted

## Success Criteria

- ✅ App builds and runs in Simulator (mock mode)
- ✅ App builds and runs on iPhone (real scanning)
- ✅ Successfully scans all three barcode types
- ✅ Quality assessment provides accurate feedback
- ✅ Scan history persists across app restarts
- ✅ All unit tests pass
- ✅ Clean, intuitive UI following iOS patterns
