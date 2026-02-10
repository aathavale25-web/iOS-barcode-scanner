import SwiftUI
import SwiftData
import Combine

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
