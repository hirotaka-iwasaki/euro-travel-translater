import SwiftUI

struct CategoryListView: View {
    let category: PhrasebookCategory
    @Bindable var viewModel: PhrasesViewModel

    var body: some View {
        List {
            ForEach(viewModel.phrases(for: category), id: \.en) { phrase in
                let localText = viewModel.localText(for: phrase)
                PhraseRow(
                    localText: localText,
                    englishText: phrase.en,
                    jaHint: phrase.ja_hint,
                    onCopy: {
                        viewModel.copyToClipboard(text: localText)
                    },
                    onSpeak: {
                        viewModel.speak(text: localText)
                    }
                )
            }
        }
        .navigationTitle(category.label_ja)
    }
}
