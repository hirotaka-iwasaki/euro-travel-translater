import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Voice", systemImage: "mic.fill") {
                NavigationStack {
                    Text("Voice")
                        .navigationTitle("Voice")
                }
            }

            Tab("Camera", systemImage: "camera.fill") {
                NavigationStack {
                    Text("Camera")
                        .navigationTitle("Camera")
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
    }
}
