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
