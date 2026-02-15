import SwiftUI

struct ContentView: View {
    @State private var translationBridge = TranslationBridgeController()
    @State private var permissionManager = PermissionManager()
    @State private var showPermissionSheet = false

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
                        PhrasesView()
                    }
                }

                Tab("Settings", systemImage: "gearshape.fill") {
                    NavigationStack {
                        SettingsView()
                    }
                }
            }

            TranslationBridgeView(controller: translationBridge)
        }
        .environment(translationBridge)
        .environment(permissionManager)
        .onAppear {
            if permissionManager.needsAnyPermission {
                showPermissionSheet = true
            }
        }
        .sheet(isPresented: $showPermissionSheet) {
            PermissionSheetView(permissionManager: permissionManager)
        }
    }
}

struct PermissionSheetView: View {
    var permissionManager: PermissionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.accentColor)

                Text("Welcome to Euro Travel Translate")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("This app needs a few permissions to help you translate during your trip.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    permissionRow(
                        icon: "mic.fill",
                        title: "Microphone",
                        description: "Listen to conversations",
                        granted: permissionManager.microphoneGranted
                    )

                    permissionRow(
                        icon: "waveform",
                        title: "Speech Recognition",
                        description: "Convert speech to text",
                        granted: permissionManager.speechStatus == .authorized
                    )

                    permissionRow(
                        icon: "camera.fill",
                        title: "Camera",
                        description: "Scan signs and menus",
                        granted: permissionManager.cameraStatus == .authorized
                    )
                }
                .padding(.horizontal)

                Spacer()

                if permissionManager.allGranted {
                    Button("Get Started") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button("Grant Permissions") {
                        Task {
                            await permissionManager.requestAll()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(.vertical, 32)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { dismiss() }
                }
            }
        }
    }

    private func permissionRow(icon: String, title: String, description: String, granted: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 32)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: granted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(granted ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }
}
