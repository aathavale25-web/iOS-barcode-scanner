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
