import Foundation
import SwiftData

@Model
final class TranslationItem {
    var id: UUID
    var createdAt: Date
    var sourceLang: String
    var targetLang: String
    var sourceText: String
    var translatedText: String
    var mode: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        sourceLang: String,
        targetLang: String = "ja",
        sourceText: String,
        translatedText: String,
        mode: String = "voice"
    ) {
        self.id = id
        self.createdAt = createdAt
        self.sourceLang = sourceLang
        self.targetLang = targetLang
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.mode = mode
    }
}
