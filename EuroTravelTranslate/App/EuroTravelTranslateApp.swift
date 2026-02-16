import SwiftUI
import SwiftData
import TipKit

@main
struct EuroTravelTranslateApp: App {
    init() {
        let isUITest = ProcessInfo.processInfo.arguments.contains("-UITests")
        guard !isUITest else { return }
        #if DEBUG
        try? Tips.resetDatastore()
        #endif
        try? Tips.configure([
            .displayFrequency(.immediate)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            SettingsState.self,
            ExpenseItem.self,
        ])
    }
}
