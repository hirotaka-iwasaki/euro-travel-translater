import Foundation

protocol TranslatorService: Sendable {
    func translate(
        text: String,
        from source: LanguageCode,
        to target: LanguageCode
    ) async throws -> String
}
