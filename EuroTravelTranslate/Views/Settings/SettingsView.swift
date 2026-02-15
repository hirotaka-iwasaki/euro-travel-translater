import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        List {
            Section("Language") {
                NavigationLink {
                    LanguagePickerView(viewModel: viewModel)
                } label: {
                    HStack {
                        Text("Languages")
                        Spacer()
                        Text(viewModel.selectedInputLang.displayName)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Reply Style") {
                Picker("Default Style", selection: $viewModel.politeStyle) {
                    Text("Polite").tag(true)
                    Text("Casual").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.politeStyle) {
                    viewModel.save()
                }
            }

            Section("Text-to-Speech") {
                Toggle("TTS Enabled", isOn: $viewModel.ttsEnabled)
                    .onChange(of: viewModel.ttsEnabled) {
                        viewModel.save()
                    }
            }

            Section("Offline") {
                NavigationLink {
                    OfflineCheckView(viewModel: viewModel)
                } label: {
                    Text("Offline Availability Check")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }
}
