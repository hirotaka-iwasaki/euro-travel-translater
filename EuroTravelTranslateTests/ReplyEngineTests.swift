import Testing
import Foundation
@testable import EuroTravelTranslate

@Suite("ReplyEngine Tests")
struct ReplyEngineTests {
    let engine: PhrasebookReplyEngine

    init() {
        // With TEST_HOST, Bundle.main is the host app which contains phrasebook.json
        engine = PhrasebookReplyEngine()
    }
}

extension ReplyEngineTests {

    @Test("Returns suggestions for price keywords")
    func priceKeywords() {
        let suggestions = engine.suggest(
            sourceText: "How much does this cost?",
            translatedText: "これはいくらですか？",
            sourceLang: .en,
            style: .polite
        )
        #expect(!suggestions.isEmpty)
        let ids = suggestions.map(\.categoryId)
        #expect(ids.contains("PRICE"))
    }

    @Test("Returns suggestions for French keywords")
    func frenchKeywords() {
        let suggestions = engine.suggest(
            sourceText: "Combien ça coûte?",
            translatedText: "いくらですか",
            sourceLang: .fr,
            style: .polite
        )
        #expect(!suggestions.isEmpty)
        let ids = suggestions.map(\.categoryId)
        #expect(ids.contains("PRICE"))
    }

    @Test("Respects style filter - polite")
    func politeStyle() {
        let suggestions = engine.suggest(
            sourceText: "Where is the station?",
            translatedText: "駅はどこですか？",
            sourceLang: .en,
            style: .polite
        )
        for suggestion in suggestions {
            #expect(suggestion.style == .polite)
        }
    }

    @Test("Respects style filter - casual")
    func casualStyle() {
        let suggestions = engine.suggest(
            sourceText: "Where is the station?",
            translatedText: "駅はどこ？",
            sourceLang: .en,
            style: .casual
        )
        for suggestion in suggestions {
            #expect(suggestion.style == .casual)
        }
    }

    @Test("Returns default suggestions for unmatched text")
    func defaultSuggestions() {
        let suggestions = engine.suggest(
            sourceText: "xyzzy foobar",
            translatedText: "意味不明",
            sourceLang: .en,
            style: .polite
        )
        #expect(!suggestions.isEmpty)
    }

    @Test("Returns at most 3 suggestions")
    func maxThreeSuggestions() {
        let suggestions = engine.suggest(
            sourceText: "thank you for the price of the order",
            translatedText: "注文の値段をありがとう",
            sourceLang: .en,
            style: .polite
        )
        #expect(suggestions.count <= 3)
    }

    @Test("Suggestions have localText and englishText")
    func suggestionsHaveText() {
        let suggestions = engine.suggest(
            sourceText: "Thank you",
            translatedText: "ありがとう",
            sourceLang: .en,
            style: .polite
        )
        for suggestion in suggestions {
            #expect(!suggestion.localText.isEmpty)
            #expect(!suggestion.englishText.isEmpty)
            #expect(!suggestion.jaHint.isEmpty)
        }
    }
}
