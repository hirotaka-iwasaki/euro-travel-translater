import Foundation

enum AppError: Error, LocalizedError, Sendable {
    case permissionDenied(PermissionType)
    case sttFailed(String)
    case translationFailed(String)
    case cameraUnavailable
    case phrasebookLoadFailed

    enum PermissionType: String, Sendable {
        case camera
        case microphone
        case speech
    }

    var errorDescription: String? {
        switch self {
        case .permissionDenied(let type):
            "\(type.rawValue.capitalized) permission is required"
        case .sttFailed(let detail):
            "Speech recognition failed: \(detail)"
        case .translationFailed(let detail):
            "Translation failed: \(detail)"
        case .cameraUnavailable:
            "Camera is not available on this device"
        case .phrasebookLoadFailed:
            "Failed to load phrasebook"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            "Please enable the permission in Settings"
        case .sttFailed:
            "Try again or check your microphone"
        case .translationFailed:
            "Check your internet connection or download offline models"
        case .cameraUnavailable:
            "This feature requires a camera"
        case .phrasebookLoadFailed:
            "Try reinstalling the app"
        }
    }

    var needsSettingsNavigation: Bool {
        if case .permissionDenied = self { return true }
        return false
    }
}
