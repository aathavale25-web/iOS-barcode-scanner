import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @State private var showingHistory = false
    @State private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    @State private var cameraSetupComplete = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview or mock button
                if viewModel.mockModeEnabled {
                    mockScannerView
                } else if let previewLayer = cameraPreviewLayer {
                    CameraPreview(previewLayer: previewLayer)
                        .ignoresSafeArea()
                } else {
                    // Loading or error state
                    VStack(spacing: 20) {
                        if viewModel.permissionDenied {
                            Image(systemName: "camera.fill.badge.ellipsis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Camera Access Needed")
                                .font(.headline)
                        } else {
                            ProgressView("Setting up camera...")
                                .tint(.white)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
                }

                // Scan frame overlay (only show when camera is ready)
                if cameraPreviewLayer != nil {
                    scanFrameOverlay
                }
            }
            .navigationTitle("Barcode Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("History") {
                        showingHistory = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingResult) {
                if let metrics = viewModel.qualityMetrics {
                    ResultView(
                        barcodeType: viewModel.scannedType,
                        content: viewModel.scannedContent,
                        qualityMetrics: metrics,
                        onScanAnother: {
                            viewModel.resetScan()
                        },
                        onViewHistory: {
                            viewModel.resetScan()
                            showingHistory = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .task {
                await viewModel.checkPermissions()

                if !viewModel.mockModeEnabled && !viewModel.permissionDenied {
                    if let layer = viewModel.setupCamera() {
                        cameraPreviewLayer = layer
                        viewModel.startScanning()
                        cameraSetupComplete = true
                    } else {
                        print("❌ Camera setup failed")
                    }
                } else {
                    print("Mock mode: \(viewModel.mockModeEnabled), Permission denied: \(viewModel.permissionDenied)")
                }
            }
            .onDisappear {
                if !viewModel.mockModeEnabled {
                    viewModel.stopScanning()
                }
            }
            .alert("Camera Access Denied", isPresented: $viewModel.permissionDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This app needs camera access to scan barcodes. Please enable it in Settings.")
            }
        }
    }

    #if DEBUG
    private var mockScannerView: some View {
        VStack(spacing: 30) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 100))
                .foregroundColor(.gray)

            Text("Mock Scanner Mode")
                .font(.title2)
                .foregroundColor(.secondary)

            Button {
                viewModel.handleMockScan()
            } label: {
                Text("Generate Test Scan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
    }
    #endif

    private var scanFrameOverlay: some View {
        GeometryReader { geometry in
            let frameWidth = geometry.size.width * 0.7
            let frameHeight = frameWidth * 0.6

            VStack {
                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: frameWidth, height: frameHeight)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("Position barcode within frame")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                                .padding(.bottom, -40)
                        }
                    )

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ScannerView()
}
