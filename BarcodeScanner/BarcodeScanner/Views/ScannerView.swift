import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @State private var showingHistory = false
    @State private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    @State private var cameraSetupComplete = false
    @State private var debugMessage = "Initializing..."

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

                // Debug overlay (top of screen)
                VStack {
                    Text("DEBUG: \(debugMessage)")
                        .font(.caption)
                        .padding(8)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 8)
                    Spacer()
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
                debugMessage = "Checking permissions..."
                await viewModel.checkPermissions()

                if viewModel.permissionDenied {
                    debugMessage = "Camera permission DENIED"
                } else if viewModel.mockModeEnabled {
                    debugMessage = "Mock mode is ENABLED"
                } else {
                    debugMessage = "Setting up camera..."
                    if let layer = viewModel.setupCamera() {
                        cameraPreviewLayer = layer
                        debugMessage = "Starting camera..."
                        viewModel.startScanning()
                        cameraSetupComplete = true
                        debugMessage = "Camera RUNNING"
                    } else {
                        debugMessage = "Camera setup FAILED"
                    }
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
