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
