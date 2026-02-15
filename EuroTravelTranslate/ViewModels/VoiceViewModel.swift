import SwiftUI
import SwiftData

@Observable
@MainActor
final class VoiceViewModel {
    var isListening = false
    var partialText = ""
    var selectedLang: LanguageCode = .auto
    var transcripts: [TranscriptEntry] = []
    var translations: [TranslationEntry] = []
    var replySuggestions: [ReplySuggestion] = []
    var politeStyle: Bool = true
    var copiedToast = false
    var errorMessage: String?

    private let transcriber = AppleSpeechTranscriber()
    private let segmenter = Segmenter()
    private let replyEngine = PhrasebookReplyEngine()
    private var translatorService: AppleTranslatorService?
    private var listeningTask: Task<Void, Never>?
    private var modelContext: ModelContext?

    struct TranscriptEntry: Identifiable {
        let id = UUID()
        let text: String
        let lang: LanguageCode
        let timestamp: Date
    }

    struct TranslationEntry: Identifiable {
        let id = UUID()
        let sourceText: String
        let translatedText: String
        let timestamp: Date
    }

    func setup(translatorService: AppleTranslatorService, modelContext: ModelContext) {
        self.translatorService = translatorService
        self.modelContext = modelContext
    }

    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    func startListening() {
        guard !isListening else { return }
        isListening = true
        errorMessage = nil
        partialText = ""
        segmenter.reset()

        let locale = resolveLocale()
        let stream = transcriber.start(locale: locale)

        listeningTask = Task { [weak self] in
            do {
                for try await result in stream {
                    guard let self else { return }
                    if result.isFinal {
                        if let cleaned = segmenter.process(result) {
                            let lang = selectedLang == .auto ? .en : selectedLang
                            let entry = TranscriptEntry(text: cleaned, lang: lang, timestamp: Date())
                            transcripts.append(entry)
                            partialText = ""
                            saveTranscript(entry)
                            await translateText(cleaned, sourceLang: lang)
                        }
                    } else {
                        partialText = result.text
                    }
                }
            } catch {
                guard let self else { return }
                AppLogger.stt.error("Listening error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
            self?.isListening = false
        }
    }

    func stopListening() {
        transcriber.stop()
        listeningTask?.cancel()
        listeningTask = nil
        isListening = false
        partialText = ""
    }

    private func translateText(_ text: String, sourceLang: LanguageCode) async {
        guard let translatorService else { return }
        do {
            let translated = try await translatorService.translate(
                text: text,
                from: sourceLang,
                to: .ja
            )
            let entry = TranslationEntry(
                sourceText: text,
                translatedText: translated,
                timestamp: Date()
            )
            translations.append(entry)
            saveTranslation(text: text, translated: translated, sourceLang: sourceLang)
            updateReplySuggestions(sourceText: text, translatedText: translated, sourceLang: sourceLang)
        } catch {
            AppLogger.translation.error("Translation failed: \(error.localizedDescription)")
        }
    }

    private func saveTranscript(_ entry: TranscriptEntry) {
        guard let modelContext else { return }
        let item = TranscriptItem(
            sourceLang: entry.lang.rawValue,
            sourceText: entry.text
        )
        modelContext.insert(item)
        try? modelContext.save()
    }

    private func saveTranslation(text: String, translated: String, sourceLang: LanguageCode) {
        guard let modelContext else { return }
        let item = TranslationItem(
            sourceLang: sourceLang.rawValue,
            sourceText: text,
            translatedText: translated,
            mode: "voice"
        )
        modelContext.insert(item)
        try? modelContext.save()
    }

    private func resolveLocale() -> Locale {
        if selectedLang == .auto {
            return Locale(identifier: "en-US")
        }
        return selectedLang.locale
    }

    private func updateReplySuggestions(sourceText: String, translatedText: String, sourceLang: LanguageCode) {
        let style: ReplyStyle = politeStyle ? .polite : .casual
        replySuggestions = replyEngine.suggest(
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLang: sourceLang,
            style: style
        )
    }

    func clearSession() {
        transcripts.removeAll()
        translations.removeAll()
        replySuggestions.removeAll()
        partialText = ""
        segmenter.reset()
    }
}
