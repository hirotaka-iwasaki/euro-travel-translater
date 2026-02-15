import SwiftUI

struct PhrasesView: View {
    @State private var viewModel = PhrasesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            controlBar
            categoryList
        }
        .navigationTitle("Phrases")
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            // Language selector
            Menu {
                ForEach(LanguageCode.phrasebookLanguages) { lang in
                    Button {
                        viewModel.selectedLang = lang
                    } label: {
                        if viewModel.selectedLang == lang {
                            Label(lang.displayName, systemImage: "checkmark")
                        } else {
                            Text(lang.displayName)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.selectedLang.shortLabel)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor, in: Capsule())
                .foregroundStyle(.white)
            }

            // Style toggle
            Picker("Style", selection: $viewModel.politeStyle) {
                Text("Polite").tag(true)
                Text("Casual").tag(false)
            }
            .pickerStyle(.segmented)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private var categoryList: some View {
        List {
            ForEach(viewModel.categories, id: \.id) { category in
                NavigationLink {
                    CategoryListView(category: category, viewModel: viewModel)
                } label: {
                    HStack {
                        Text(category.label_ja)
                            .font(.body)
                        Spacer()
                        Text("\(viewModel.phrases(for: category).count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
