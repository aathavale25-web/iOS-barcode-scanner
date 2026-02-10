# iOS Barcode Scanner - Design Document

**Date:** 2026-02-10
**Target Platform:** iOS 17+
**Tech Stack:** Swift, SwiftUI, AVFoundation, Vision Framework, SwiftData

## Overview

A native iOS application for scanning Code 128, Code 93, and QR codes with real-time quality assessment and scan history tracking.

## Core Requirements

- Scan Code 128, Code 93, and QR codes using iPhone camera
- Assess barcode quality using image analysis + decode confidence
- Display scan results with quality rating and decoded content
- Store scan history with timestamps
- Simple, clean UI following iOS design patterns

## Architecture

### MVVM Structure

**Models:**
- `BarcodeScanner` - Scan results and barcode data
- `ScanHistory` - SwiftData model for persistent storage
- `QualityMetrics` - Image quality assessment data

**Views:**
- `ScannerView` - Camera interface with scan frame overlay
- `ResultView` - Quality rating + decoded content display
- `HistoryView` - List of past scans with timestamps

**ViewModels:**
- `ScannerViewModel` - Camera management and scanning logic
- `HistoryViewModel` - Data persistence and history management

### Core Technologies

- **AVFoundation**: Camera access and barcode detection (native support for Code 128, Code 93, QR)
- **Vision Framework**: Image quality analysis (sharpness, contrast, brightness)
- **SwiftData**: Persistent storage of scan history (iOS 17+)
- **SwiftUI**: All UI components and navigation

### Navigation Flow

```
App Launch
    ↓
ScannerView (camera active)
    ↓
[Barcode Detected]
    ↓
ResultView (quality + content)
    ↓
[Scan Another] → Back to ScannerView
[View History] → HistoryView
```

## Quality Assessment System

### Two-Part Quality Analysis

**1. Decode Confidence (AVFoundation)**
- Baseline confidence score from barcode scanner
- Indicates successful decode accuracy
- Primary "did we read it correctly?" metric

**2. Image Quality Analysis (Vision Framework)**

Metrics analyzed:
- **Sharpness**: Laplacian variance to detect blur
- **Contrast**: Histogram analysis for bar/background separation
- **Lighting**: Brightness assessment (too dark/overexposed detection)
- **Completeness**: Barcode fully within frame boundaries

### Quality Rating System

**Combined Score Calculation:**

- **Excellent**: High decode confidence + all image metrics pass
- **Good**: High decode confidence + most image metrics pass
- **Fair**: Successful decode but image quality issues detected
- **Poor**: Low decode confidence or failed decode

**User Feedback:**
- Prominent quality badge with color coding (green/yellow/orange/red)
- Actionable tips: "Good scan! Clear and readable" or "Fair - try better lighting"

## Data Model

### SwiftData Schema

```swift
@Model
class ScanRecord {
    var id: UUID
    var timestamp: Date
    var barcodeType: String      // "Code 128", "Code 93", "QR Code"
    var content: String           // Decoded barcode data
    var qualityRating: String     // "Excellent", "Good", "Fair", "Poor"
    var qualityScore: Double      // 0.0 - 1.0 numeric score

    // Detailed metrics for analysis
    var sharpness: Double
    var contrast: Double
    var brightness: Double
    var decodeConfidence: Double
}
```

### Storage Strategy

- **Auto-persistence**: SwiftData saves automatically on record creation
- **No size limits**: Initial version stores unlimited scans
- **Sort order**: Newest first (timestamp descending)
- **Future consideration**: Add cleanup/export for large histories

## UI Components

### ScannerView (Main Screen)

**Layout:**
- Camera preview (full screen)
- Scan frame overlay (visual positioning guide)
- Top bar: App title + "History" button (top-right)
- Bottom area: Instructions ("Position barcode within frame")

**Behavior:**
- Auto-scan when barcode enters frame
- Immediate transition to ResultView on successful scan

### ResultView (Scan Results)

**Layout:**
- Quality badge at top (color-coded)
- Quality rating text with description
- Barcode type label (Code 128/Code 93/QR Code)
- Decoded content (large, readable text)
- Two action buttons:
  - "Scan Another" (primary) - return to camera
  - "View History" (secondary) - show history list

### HistoryView (Scan History)

**Layout:**
- Navigation bar with "History" title + "Done" button
- List of scan records (newest first)
- Each row displays:
  - Timestamp
  - Barcode type icon
  - Content preview (truncated if long)
  - Quality badge

**Empty State:**
- "No scans yet" message with icon

## Error Handling

### Camera Permissions

- **First launch**: Request with clear explanation
- **Denied**: Alert with "Open Settings" option
- **Graceful degradation**: Show helpful message if no access

### Scanning Errors

- **No barcode detected**: Subtle hint after 3 seconds ("Move closer or adjust angle")
- **Unsupported type**: Alert "This barcode type is not supported"
- **Failed decode**: "Unable to read barcode, try better lighting"

### Edge Cases

- **Low light**: Visual indicator, suggest better lighting
- **Multiple barcodes**: Scan most centered/prominent one
- **Damaged barcodes**: Quality score "Poor" with warning
- **Data persistence failure**: User-friendly "Could not save" message

## Testing Strategy

### Mock Scanner Mode (Development)

**Debug-only feature for iOS Simulator testing:**

```swift
#if DEBUG
struct MockScannerMode {
    static var enabled: Bool = true

    static func generateTestScan() -> ScanResult {
        // Returns random barcode type with varying quality scores
        // Simulates different scenarios without physical device
    }
}
#endif
```

**Implementation:**
- Settings toggle to enable/disable mock mode
- "Generate Test Scan" button replaces camera view
- Randomly generates Code 128, Code 93, and QR results
- Simulates quality variations (Excellent → Poor)
- Allows full app testing in Simulator

**Additional Testing Tools:**
- SwiftUI Previews with sample data for UI development
- Photo library integration for static barcode image testing

### Unit Tests

- Quality assessment calculations (sharpness, contrast, brightness)
- Quality score logic (rating determination)
- SwiftData CRUD operations
- Mock scanner data generation

### UI Tests

- Navigation flow (Scanner → Result → History)
- Button actions and state transitions
- Empty state handling
- Permission alerts

### Manual Testing (Physical Device)

**Required for final validation:**
- Real barcode scanning (Code 128, Code 93, QR)
- Quality variations (good/poor lighting, blur, angles)
- History persistence across app restarts
- Camera permission handling

**Test Materials:**
- Online barcode generators for creating test samples
- Printed barcodes with varying quality

## Development Approach

### Team Agent Structure

**Agent 1: Camera & Scanning**
- AVFoundation camera setup
- Barcode detection implementation
- Camera permissions handling

**Agent 2: Quality Assessment**
- Vision framework integration
- Image quality metrics (sharpness, contrast, brightness)
- Quality score calculation logic

**Agent 3: UI/SwiftUI Components**
- ScannerView, ResultView, HistoryView
- Navigation flow
- Mock scanner mode UI

**Agent 4: Data Persistence**
- SwiftData model and persistence
- HistoryViewModel
- CRUD operations

### Implementation Order

1. **Phase 1**: Project setup, basic UI structure, mock scanner mode
2. **Phase 2**: Camera integration, barcode detection
3. **Phase 3**: Quality assessment implementation
4. **Phase 4**: SwiftData persistence and history
5. **Phase 5**: Testing, polish, and refinement

## Future Enhancements (Out of Scope for v1)

- Export/share history (CSV, email)
- Search and filter history
- Flashlight toggle for low light
- Barcode generation
- Multi-barcode batch scanning
- Dark mode optimization
- Haptic feedback on successful scan

## Success Criteria

- ✅ Successfully scans Code 128, Code 93, and QR codes
- ✅ Provides quality assessment with actionable feedback
- ✅ Stores scan history with timestamps
- ✅ Clean, intuitive UI following iOS patterns
- ✅ Works in Simulator via mock mode
- ✅ Passes all unit and UI tests
- ✅ Validated on physical iPhone with real barcodes
