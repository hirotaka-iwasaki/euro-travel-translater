import Foundation

enum LanguageCode: String, Codable, CaseIterable, Sendable, Identifiable {
    case auto
    case ja
    case en
    case fr
    case de
    case es
    case it
    case pt
    case nl

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .auto: "Auto"
        case .ja: "日本語"
        case .en: "English"
        case .fr: "Français"
        case .de: "Deutsch"
        case .es: "Español"
        case .it: "Italiano"
        case .pt: "Português"
        case .nl: "Nederlands"
        }
    }

    var shortLabel: String {
        switch self {
        case .auto: "Auto"
        default: rawValue.uppercased()
        }
    }

    var localeIdentifier: String {
        switch self {
        case .auto: "en"
        case .ja: "ja-JP"
        case .en: "en-US"
        case .fr: "fr-FR"
        case .de: "de-DE"
        case .es: "es-ES"
        case .it: "it-IT"
        case .pt: "pt-PT"
        case .nl: "nl-NL"
        }
    }

    var locale: Locale {
        Locale(identifier: localeIdentifier)
    }

    /// Languages that can be selected as source (excludes Japanese since it's always the target)
    static var sourceLanguages: [LanguageCode] {
        [.auto, .en, .fr, .de, .es, .it, .pt, .nl]
    }

    /// Languages supported in the phrasebook
    static var phrasebookLanguages: [LanguageCode] {
        [.en, .fr, .de, .es, .it]
    }
}
