import Foundation

struct TranscriptionResult: Sendable {
    let text: String
    let isFinal: Bool
    let confidence: Double?
    let locale: Locale
}

protocol SpeechTranscriber: Sendable {
    func start(locale: Locale) -> AsyncThrowingStream<TranscriptionResult, Error>
    func stop()
}
