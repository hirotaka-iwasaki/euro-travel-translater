import OSLog

enum AppLogger {
    static let converter = Logger(subsystem: "art.minasehiro.EuroTravelTranslate", category: "Converter")
    static let expenses = Logger(subsystem: "art.minasehiro.EuroTravelTranslate", category: "Expenses")
    static let general = Logger(subsystem: "art.minasehiro.EuroTravelTranslate", category: "General")
    static let location = Logger(subsystem: "art.minasehiro.EuroTravelTranslate", category: "Location")
}
