import AVFoundation
import Speech
import Observation
import UIKit

@Observable
@MainActor
final class PermissionManager {
    var cameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    var microphoneGranted: Bool = AVAudioApplication.shared.recordPermission == .granted
    var speechStatus: SFSpeechRecognizerAuthorizationStatus = SFSpeechRecognizer.authorizationStatus()

    var allGranted: Bool {
        cameraStatus == .authorized
            && microphoneGranted
            && speechStatus == .authorized
    }

    var needsAnyPermission: Bool {
        !allGranted
    }

    func requestCamera() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        cameraStatus = granted ? .authorized : .denied
        AppLogger.permission.info("Camera permission: \(granted)")
    }

    func requestMicrophone() async {
        let granted = await AVAudioApplication.requestRecordPermission()
        microphoneGranted = granted
        AppLogger.permission.info("Microphone permission: \(granted)")
    }

    func requestSpeech() async {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        speechStatus = status
        AppLogger.permission.info("Speech permission: \(status.rawValue)")
    }

    func requestAll() async {
        await requestMicrophone()
        await requestSpeech()
        await requestCamera()
    }

    func refreshStatuses() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        microphoneGranted = AVAudioApplication.shared.recordPermission == .granted
        speechStatus = SFSpeechRecognizer.authorizationStatus()
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
