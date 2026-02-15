import Foundation
import SwiftData

@Model
final class SettingsState {
    var selectedInputLang: String
    var enabledLangs: [String]
    var politeStyle: Bool
    var ttsEnabled: Bool
    var offlineReadyCheckedAt: Date?

    init(
        selectedInputLang: String = "auto",
        enabledLangs: [String] = ["en", "fr", "de", "es", "it"],
        politeStyle: Bool = true,
        ttsEnabled: Bool = true,
        offlineReadyCheckedAt: Date? = nil
    ) {
        self.selectedInputLang = selectedInputLang
        self.enabledLangs = enabledLangs
        self.politeStyle = politeStyle
        self.ttsEnabled = ttsEnabled
        self.offlineReadyCheckedAt = offlineReadyCheckedAt
    }
}
