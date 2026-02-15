import Foundation

final class AppleTranslatorService: TranslatorService, @unchecked Sendable {
    private let cache = TranslationCache()
    private let bridgeController: TranslationBridgeController

    init(bridgeController: TranslationBridgeController) {
        self.bridgeController = bridgeController
    }

    func translate(text: String, from source: LanguageCode, to target: LanguageCode) async throws -> String {
        // Check cache first
        if let cached = await cache.get(source: source, target: target, text: text) {
            AppLogger.translation.debug("Cache hit: \(text.prefix(30))")
            return cached
        }

        // Translate via bridge
        let result = try await bridgeController.translate(text: text, source: source, target: target)

        // Cache the result
        await cache.set(source: source, target: target, text: text, translation: result)
        AppLogger.translation.info("Translated: \(text.prefix(30)) → \(result.prefix(30))")

        return result
    }
}
