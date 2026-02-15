import UIKit

@Observable
@MainActor
final class PhrasesViewModel {
    var categories: [PhrasebookCategory] = []
    var selectedLang: LanguageCode = .fr
    var politeStyle: Bool = true
    let ttsService = TTSService()

    init() {
        loadPhrasebook()
    }

    private func loadPhrasebook() {
        guard let url = Bundle.main.url(forResource: "phrasebook", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let book = try? JSONDecoder().decode(Phrasebook.self, from: data)
        else { return }
        categories = book.categories
    }

    func phrases(for category: PhrasebookCategory) -> [PhrasebookPhrase] {
        let style = politeStyle ? "polite" : "casual"
        return category.phrases.filter { $0.style == style }
    }

    func localText(for phrase: PhrasebookPhrase) -> String {
        phrase.text(for: selectedLang.rawValue) ?? phrase.en
    }

    func speak(text: String) {
        ttsService.speak(text: text, lang: selectedLang)
    }

    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}
