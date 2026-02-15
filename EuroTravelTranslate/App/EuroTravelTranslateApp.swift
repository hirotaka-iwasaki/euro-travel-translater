import SwiftUI
import SwiftData

@main
struct EuroTravelTranslateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            TranscriptItem.self,
            TranslationItem.self,
            CameraCaptureItem.self,
            SettingsState.self,
        ])
    }
}
