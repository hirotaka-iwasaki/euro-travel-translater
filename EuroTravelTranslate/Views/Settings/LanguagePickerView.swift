import SwiftUI

struct LanguagePickerView: View {
    var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Default Input Language") {
                ForEach(LanguageCode.sourceLanguages, id: \.rawValue) { (lang: LanguageCode) in
                    Button {
                        viewModel.selectedInputLang = lang
                        viewModel.save()
                    } label: {
                        HStack {
                            Text(lang.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.selectedInputLang == lang {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }

            Section("Enabled Languages") {
                ForEach(LanguageCode.phrasebookLanguages, id: \.rawValue) { (lang: LanguageCode) in
                    Button {
                        viewModel.toggleLang(lang)
                    } label: {
                        HStack {
                            Text(lang.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.enabledLangs.contains(lang) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Languages")
    }
}
