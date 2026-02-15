import SwiftUI
import SwiftData
import Translation

@Observable
@MainActor
final class SettingsViewModel {
    var settings: SettingsState?
    var selectedInputLang: LanguageCode = .auto
    var enabledLangs: Set<LanguageCode> = [.en, .fr, .de, .es, .it]
    var politeStyle: Bool = true
    var ttsEnabled: Bool = true
    var offlineStatus: String = "Not checked"
    var isCheckingOffline = false

    private var modelContext: ModelContext?

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }

    private func loadSettings() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SettingsState>()
        if let existing = try? modelContext.fetch(descriptor).first {
            settings = existing
            selectedInputLang = LanguageCode(rawValue: existing.selectedInputLang) ?? .auto
            enabledLangs = Set(existing.enabledLangs.compactMap { LanguageCode(rawValue: $0) })
            politeStyle = existing.politeStyle
            ttsEnabled = existing.ttsEnabled
        } else {
            let newSettings = SettingsState()
            modelContext.insert(newSettings)
            try? modelContext.save()
            settings = newSettings
        }
    }

    func save() {
        guard let settings, let modelContext else { return }
        settings.selectedInputLang = selectedInputLang.rawValue
        settings.enabledLangs = enabledLangs.map(\.rawValue)
        settings.politeStyle = politeStyle
        settings.ttsEnabled = ttsEnabled
        try? modelContext.save()
    }

    func toggleLang(_ lang: LanguageCode) {
        if enabledLangs.contains(lang) {
            enabledLangs.remove(lang)
        } else {
            enabledLangs.insert(lang)
        }
        save()
    }

    func checkOfflineAvailability() async {
        isCheckingOffline = true
        offlineStatus = "Checking..."

        let languages = enabledLangs.map { $0.localeIdentifier }
        let ja = Locale.Language(identifier: "ja-JP")

        var results: [String] = []
        for langId in languages {
            let lang = Locale.Language(identifier: langId)
            let status = LanguageAvailability()
            let s = await status.status(from: lang, to: ja)
            let label = LanguageCode(rawValue: String(langId.prefix(2)).lowercased()) ?? .en
            switch s {
            case .installed:
                results.append("\(label.shortLabel): Ready")
            case .supported:
                results.append("\(label.shortLabel): Download needed")
            case .unsupported:
                results.append("\(label.shortLabel): Unsupported")
            @unknown default:
                results.append("\(label.shortLabel): Unknown")
            }
        }

        offlineStatus = results.joined(separator: "\n")
        isCheckingOffline = false

        settings?.offlineReadyCheckedAt = Date()
        if let modelContext {
            try? modelContext.save()
        }
    }
}

