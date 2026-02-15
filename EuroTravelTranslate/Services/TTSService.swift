import AVFoundation

@MainActor
final class TTSService {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(text: String, lang: LanguageCode) {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang.localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.0

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: .duckOthers)
            try session.setActive(true)
        } catch {
            AppLogger.tts.error("Audio session error: \(error.localizedDescription)")
        }

        synthesizer.speak(utterance)
        AppLogger.tts.info("Speaking: \(text.prefix(30)) in \(lang.rawValue)")
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
