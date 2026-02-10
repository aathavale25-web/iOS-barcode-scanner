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
