import SwiftUI

struct ContentView: View {
    @State private var translationBridge = TranslationBridgeController()

    var body: some View {
        ZStack {
            TabView {
                Tab("Voice", systemImage: "mic.fill") {
                    NavigationStack {
                        VoiceView()
                    }
                }

                Tab("Camera", systemImage: "camera.fill") {
                    NavigationStack {
                        CameraView()
                    }
                }

                Tab("Phrases", systemImage: "text.book.closed.fill") {
                    NavigationStack {
                        Text("Phrases")
                            .navigationTitle("Phrases")
                    }
                }

                Tab("Settings", systemImage: "gearshape.fill") {
                    NavigationStack {
                        Text("Settings")
                            .navigationTitle("Settings")
                    }
                }
            }

            TranslationBridgeView(controller: translationBridge)
        }
        .environment(translationBridge)
    }
}
