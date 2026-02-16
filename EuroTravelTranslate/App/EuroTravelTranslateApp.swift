import SwiftUI
import SwiftData
import TipKit

@main
struct EuroTravelTranslateApp: App {
    init() {
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
