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

    var body: some View {
        ZStack(alignment: .top) {
            // Frame around barcode
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: bounds.width, height: bounds.height)
                .position(x: bounds.midX, y: bounds.midY)

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
                    x: bounds.midX,
                    y: bounds.minY - 20
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
