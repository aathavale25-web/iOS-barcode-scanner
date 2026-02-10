import AVFoundation

class CameraPermissionManager {
    func checkPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestPermission() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
}
