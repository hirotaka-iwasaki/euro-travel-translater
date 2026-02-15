import OSLog

enum AppLogger {
    static let stt = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "STT")
    static let translation = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "Translation")
    static let camera = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "Camera")
    static let tts = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "TTS")
    static let permission = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "Permission")
    static let general = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "General")
}
