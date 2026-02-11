import SwiftUI

// SwiftUI App Icon Generator
// Run this in a SwiftUI preview to generate an icon screenshot

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 20) {
                // Barcode symbol
                VStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        HStack(spacing: 3) {
                            ForEach(0..<6) { barIndex in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: barWidth(barIndex), height: 80)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                        .blur(radius: 10)
                )

                // Optional: Small camera viewfinder
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 100, height: 60)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                Spacer()
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                        }
                    )
            }
        }
        .frame(width: 1024, height: 1024) // iOS App Icon size
    }

    func barWidth(_ index: Int) -> CGFloat {
        let widths: [CGFloat] = [8, 4, 10, 6, 8, 4]
        return widths[index % widths.count]
    }
}

#Preview {
    AppIconView()
}

// Instructions:
// 1. Copy this file into your Xcode project
// 2. Open in Xcode and view the preview
// 3. Take a screenshot of the preview (CMD+Shift+4)
// 4. Save as 1024x1024 PNG
// 5. Drag into Assets.xcassets → AppIcon
