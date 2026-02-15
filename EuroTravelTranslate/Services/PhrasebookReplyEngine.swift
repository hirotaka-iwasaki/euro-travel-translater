import Foundation

final class PhrasebookReplyEngine: ReplyEngine, Sendable {
    private let phrasebook: Phrasebook

    init(bundle: Bundle = .main) {
        let searchBundles = [bundle, .main]
        var loadedBook: Phrasebook?
        for b in searchBundles {
            if let url = b.url(forResource: "phrasebook", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let book = try? JSONDecoder().decode(Phrasebook.self, from: data) {
                loadedBook = book
                break
            }
        }
        if let book = loadedBook {
            phrasebook = book
            AppLogger.general.info("Loaded phrasebook with \(book.categories.count) categories")
        } else {
            AppLogger.general.error("Failed to load phrasebook.json")
            phrasebook = Phrasebook(version: 1, categories: [])
        }
    }

    func suggest(
        sourceText: String,
        translatedText: String,
        sourceLang: LanguageCode,
        style: ReplyStyle
    ) -> [ReplySuggestion] {
        let scores = scoreCategories(
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLang: sourceLang
        )

        let topCategories = scores
            .sorted { $0.value > $1.value }
            .prefix(3)
            .filter { $0.value > 0 }
            .map(\.key)

        let categoryIds = topCategories.isEmpty
            ? ["THANKS", "UNDERSTAND", "REPEAT"]
            : Array(topCategories)

        return categoryIds.compactMap { categoryId in
            guard let category = phrasebook.categories.first(where: { $0.id == categoryId }) else {
                return nil
            }

            let langKey = resolvePhraseLang(sourceLang)
            let phrase = category.phrases.first { $0.style == style.rawValue }
                ?? category.phrases.first

            guard let phrase else { return nil }

            let localText = phrase.text(for: langKey) ?? phrase.en
            return ReplySuggestion(
                categoryId: categoryId,
                localText: localText,
                englishText: phrase.en,
                jaHint: phrase.ja_hint,
                style: style
            )
        }
    }

    private func scoreCategories(
        sourceText: String,
        translatedText: String,
        sourceLang: LanguageCode
    ) -> [String: Int] {
        let combinedText = (sourceText + " " + translatedText).lowercased()
        var scores: [String: Int] = [:]

        for category in phrasebook.categories {
            var score = 0

            // Score with English keywords always
            if let enKeywords = category.keywords["en"] {
                for keyword in enKeywords {
                    if combinedText.contains(keyword.lowercased()) {
                        score += 2
                    }
                }
            }

            // Score with source language keywords
            let langKey = resolvePhraseLang(sourceLang)
            if langKey != "en", let langKeywords = category.keywords[langKey] {
                for keyword in langKeywords {
                    if combinedText.contains(keyword.lowercased()) {
                        score += 3
                    }
                }
            }

            scores[category.id] = score
        }

        return scores
    }

    private func resolvePhraseLang(_ lang: LanguageCode) -> String {
        switch lang {
        case .auto, .ja: return "en"
        default: return lang.rawValue
        }
    }
}

// MARK: - Phrasebook Models

struct Phrasebook: Codable, Sendable {
    let version: Int
    let categories: [PhrasebookCategory]
}

struct PhrasebookCategory: Codable, Sendable {
    let id: String
    let label_ja: String
    let phrases: [PhrasebookPhrase]
    let keywords: [String: [String]]
}

struct PhrasebookPhrase: Codable, Sendable {
    let style: String
    let ja_hint: String
    let en: String
    let fr: String?
    let de: String?
    let es: String?
    let it: String?

    func text(for lang: String) -> String? {
        switch lang {
        case "en": en
        case "fr": fr
        case "de": de
        case "es": es
        case "it": it
        default: nil
        }
    }
}
