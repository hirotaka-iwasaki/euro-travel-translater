import SwiftUI

struct OfflineCheckView: View {
    var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                Button {
                    Task {
                        await viewModel.checkOfflineAvailability()
                    }
                } label: {
                    HStack {
                        Text("Check Availability")
                        Spacer()
                        if viewModel.isCheckingOffline {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.isCheckingOffline)
            } header: {
                Text("Translation Models")
            } footer: {
                Text("Check if translation models are downloaded for offline use. Go to Settings > Translate on your device to download languages.")
            }

            Section("Status") {
                Text(viewModel.offlineStatus)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            if let checkedAt = viewModel.settings?.offlineReadyCheckedAt {
                Section {
                    Text("Last checked: \(checkedAt, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .navigationTitle("Offline Check")
    }
}
