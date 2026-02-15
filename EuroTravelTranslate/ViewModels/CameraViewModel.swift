import SwiftUI
import SwiftData

struct TranslatedOverlay: Identifiable, Sendable {
    let id = UUID()
    let originalText: String
    let translatedText: String
    let bounds: CGRect
}

@Observable
@MainActor
final class CameraViewModel {
    var scannedElements: [ScannedTextElement] = []
    var translatedOverlays: [TranslatedOverlay] = []
    var isFrozen = false
    var selectedLang: LanguageCode = .auto
    var isSaving = false

    private var translatorService: AppleTranslatorService?
    private var modelContext: ModelContext?
    private var translationTask: Task<Void, Never>?

    func setup(translatorService: AppleTranslatorService, modelContext: ModelContext) {
        self.translatorService = translatorService
        self.modelContext = modelContext
    }

    func handleScannedElements(_ elements: [ScannedTextElement]) {
        scannedElements = elements

        translationTask?.cancel()
        translationTask = Task {
            await translateElements(elements)
        }
    }

    func toggleFreeze() {
        isFrozen.toggle()
    }

    func save() {
        guard let modelContext, !translatedOverlays.isEmpty else { return }
        isSaving = true

        let extractedText = translatedOverlays.map(\.originalText).joined(separator: "\n")
        let translatedText = translatedOverlays.map(\.translatedText).joined(separator: "\n")

        let item = CameraCaptureItem(
            sourceLang: selectedLang.rawValue,
            extractedText: extractedText,
            translatedText: translatedText
        )
        modelContext.insert(item)
        try? modelContext.save()

        isSaving = false
        let count = translatedOverlays.count
        AppLogger.camera.info("Saved camera capture with \(count) items")
    }

    private func translateElements(_ elements: [ScannedTextElement]) async {
        guard let translatorService else { return }

        var overlays: [TranslatedOverlay] = []
        for element in elements {
            guard !Task.isCancelled else { return }
            let text = element.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty, text.count >= 2 else { continue }

            do {
                let sourceLang = selectedLang == .auto ? .en : selectedLang
                let translated = try await translatorService.translate(
                    text: text,
                    from: sourceLang,
                    to: .ja
                )
                overlays.append(TranslatedOverlay(
                    originalText: text,
                    translatedText: translated,
                    bounds: element.bounds
                ))
            } catch {
                AppLogger.camera.error("Camera translation failed: \(error.localizedDescription)")
            }
        }

        guard !Task.isCancelled else { return }
        translatedOverlays = overlays
    }
}
