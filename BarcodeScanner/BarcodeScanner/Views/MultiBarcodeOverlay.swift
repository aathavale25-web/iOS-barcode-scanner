import SwiftUI
import AVFoundation

struct MultiBarcodeOverlay: View {
    let detectedBarcodes: [ScannedBarcode]
    let previewLayer: AVCaptureVideoPreviewLayer
    let onBarcodeSelected: (ScannedBarcode) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(detectedBarcodes, id: \.id) { barcode in
                    if let bounds = barcode.bounds {
                        BarcodeFrameView(
                            barcode: barcode,
                            bounds: bounds,
                            previewLayerFrame: previewLayer.frame,
                            geometrySize: geometry.size,
                            onTap: { onBarcodeSelected(barcode) }
                        )
                    }
                }
            }
        }
    }
}

struct BarcodeFrameView: View {
    let barcode: ScannedBarcode
    let bounds: CGRect
    let previewLayerFrame: CGRect
    let geometrySize: CGSize
    let onTap: () -> Void

    var barcodeTypeName: String {
        switch barcode.type {
        case .code128: return "Code 128"
        case .code93: return "Code 93"
        case .qr: return "QR Code"
        case .upce: return "UPC-E"
        case .ean8: return "EAN-8"
        case .ean13: return "EAN-13"
        default: return "Unknown"
        }
    }

    // Scale bounds if preview layer and overlay don't match perfectly
    var adjustedBounds: CGRect {
        // If sizes match, use bounds as-is
        guard previewLayerFrame.width > 0 && previewLayerFrame.height > 0 else {
            return bounds
        }

        let scaleX = geometrySize.width / previewLayerFrame.width
        let scaleY = geometrySize.height / previewLayerFrame.height

        return CGRect(
            x: bounds.origin.x * scaleX,
            y: bounds.origin.y * scaleY,
            width: bounds.width * scaleX,
            height: bounds.height * scaleY
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Frame around barcode
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: adjustedBounds.width, height: adjustedBounds.height)
                .position(x: adjustedBounds.midX, y: adjustedBounds.midY)

            // Label above frame
            Text("\(barcodeTypeName) - \(barcode.content)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.green.opacity(0.9))
                )
                .position(
                    x: adjustedBounds.midX,
                    y: max(20, adjustedBounds.minY - 20)
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
