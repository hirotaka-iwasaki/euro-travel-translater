import Foundation

struct ReplySuggestion: Sendable, Identifiable {
    let id = UUID()
    let categoryId: String
    let localText: String
    let englishText: String
    let jaHint: String
    let style: ReplyStyle
}

enum ReplyStyle: String, Codable, Sendable {
    case polite
    case casual
}

protocol ReplyEngine: Sendable {
    func suggest(
        sourceText: String,
        translatedText: String,
        sourceLang: LanguageCode,
        style: ReplyStyle
    ) -> [ReplySuggestion]
}
