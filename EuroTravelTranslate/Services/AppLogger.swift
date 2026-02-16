import OSLog

enum AppLogger {
    static let converter = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "Converter")
    static let expenses = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "Expenses")
    static let general = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "General")
    static let location = Logger(subsystem: "com.minasehiro.EuroTravelTranslate", category: "Location")
}
