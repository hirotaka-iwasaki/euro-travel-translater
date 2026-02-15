import AVFoundation
import Speech

final class AppleSpeechTranscriber: SpeechTranscriber, @unchecked Sendable {
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?

    func start(locale: Locale) -> AsyncThrowingStream<TranscriptionResult, Error> {
        AsyncThrowingStream { continuation in
            do {
                try startRecognition(locale: locale, continuation: continuation)
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    func stop() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        AppLogger.stt.info("Speech transcriber stopped")
    }

    private func startRecognition(
        locale: Locale,
        continuation: AsyncThrowingStream<TranscriptionResult, Error>.Continuation
    ) throws {
        stop()

        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechTranscriberError.recognizerUnavailable
        }
        self.recognizer = recognizer

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        AppLogger.stt.info("Speech transcriber started with locale: \(locale.identifier)")

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result {
                let transcription = result.bestTranscription
                let item = TranscriptionResult(
                    text: transcription.formattedString,
                    isFinal: result.isFinal,
                    confidence: transcription.segments.last.map { Double($0.confidence) },
                    locale: locale
                )
                continuation.yield(item)

                if result.isFinal {
                    self?.stop()
                    continuation.finish()
                }
            }

            if let error {
                AppLogger.stt.error("Recognition error: \(error.localizedDescription)")
                self?.stop()
                continuation.finish(throwing: error)
            }
        }

        continuation.onTermination = { @Sendable [weak self] _ in
            self?.stop()
        }
    }
}

enum SpeechTranscriberError: Error, LocalizedError {
    case recognizerUnavailable
    case audioEngineError

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable: "Speech recognizer is not available for this language"
        case .audioEngineError: "Failed to start audio engine"
        }
    }
}
