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
