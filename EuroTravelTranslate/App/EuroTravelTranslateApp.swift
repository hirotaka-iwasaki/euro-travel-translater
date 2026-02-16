import SwiftUI
import SwiftData

@main
struct EuroTravelTranslateApp: App {
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
