import SwiftUI
import Translation

@Observable
@MainActor
final class TranslationBridgeController {
    var pendingRequest: TranslationRequest?
    private var continuation: CheckedContinuation<String, Error>?

    func translate(text: String, source: LanguageCode, target: LanguageCode) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.pendingRequest = TranslationRequest(
                text: text,
                source: source,
                target: target
            )
        }
    }

    func handleResponse(_ response: TranslationSession.Response) {
        continuation?.resume(returning: response.targetText)
        continuation = nil
        pendingRequest = nil
    }

    func handleError(_ error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
        pendingRequest = nil
    }
}

struct TranslationRequest: Equatable {
    let text: String
    let source: LanguageCode
    let target: LanguageCode

    var configuration: TranslationSession.Configuration? {
        let sourceLang: Locale.Language? = source == .auto ? nil : Locale.Language(identifier: source.localeIdentifier)
        let targetLang = Locale.Language(identifier: target.localeIdentifier)
        return .init(source: sourceLang, target: targetLang)
    }
}

struct TranslationBridgeView: View {
    @Bindable var controller: TranslationBridgeController

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .translationTask(controller.pendingRequest?.configuration) { session in
                guard let request = controller.pendingRequest else { return }
                do {
                    nonisolated(unsafe) let s = session
                    let response = try await s.translate(request.text)
                    controller.handleResponse(response)
                } catch {
                    controller.handleError(error)
                }
            }
    }
}
