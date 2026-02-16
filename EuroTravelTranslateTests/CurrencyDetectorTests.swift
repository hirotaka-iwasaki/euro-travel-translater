import Testing
import Foundation
@testable import EuroTravelTranslate

@Suite("CurrencyDetector Tests")
struct CurrencyDetectorTests {
    let detector = CurrencyDetector()
    let rate: Double = 160.0
}

extension CurrencyDetectorTests {

    @Test("Detects €15.50 prefix format")
    func prefixEuroSymbol() {
        let conversions = detector.detect(in: "The price is €15.50 for this item", rate: rate)
        #expect(conversions.count == 1)
        #expect(conversions[0].euroAmount == 15.50)
        #expect(conversions[0].jpyAmount == 2480.0)
    }

    @Test("Detects 15,50 € suffix format with comma decimal")
    func suffixEuroSymbolComma() {
        let conversions = detector.detect(in: "Le prix est 15,50 € pour cet article", rate: rate)
        #expect(conversions.count == 1)
        #expect(conversions[0].euroAmount == 15.50)
    }

    @Test("Detects EUR 20 format")
    func eurCodePrefix() {
        let conversions = detector.detect(in: "Total: EUR 20", rate: rate)
        #expect(conversions.count == 1)
        #expect(conversions[0].euroAmount == 20.0)
        #expect(conversions[0].jpyAmount == 3200.0)
    }

    @Test("Detects 15 euros word format")
    func euroWord() {
        let conversions = detector.detect(in: "It costs 15 euros", rate: rate)
        #expect(conversions.count == 1)
        #expect(conversions[0].euroAmount == 15.0)
    }

    @Test("Detects 15ユーロ Japanese format")
    func euroJapanese() {
        let conversions = detector.detect(in: "価格は15ユーロです", rate: rate)
        #expect(conversions.count == 1)
        #expect(conversions[0].euroAmount == 15.0)
        #expect(conversions[0].jpyAmount == 2400.0)
    }

    @Test("Detects multiple amounts in one text")
    func multipleAmounts() {
        let conversions = detector.detect(in: "Coffee €3.50, cake €5", rate: rate)
        #expect(conversions.count == 2)
        #expect(conversions[0].euroAmount == 3.50)
        #expect(conversions[1].euroAmount == 5.0)
    }

    @Test("Returns empty for text without amounts")
    func noAmounts() {
        let conversions = detector.detect(in: "Hello world, no prices here", rate: rate)
        #expect(conversions.isEmpty)
    }

    @Test("Annotates text with JPY conversion")
    func annotateText() {
        let result = detector.annotate(text: "Price: €10", rate: rate)
        #expect(result.contains("¥1,600"))
        #expect(result.contains("€10"))
    }

    @Test("Annotate returns original text when no amounts found")
    func annotateNoChange() {
        let original = "No currency here"
        let result = detector.annotate(text: original, rate: rate)
        #expect(result == original)
    }

    @Test("Handles €0 correctly")
    func zeroAmount() {
        let conversions = detector.detect(in: "Free: €0", rate: rate)
        #expect(conversions.count == 1)
        #expect(conversions[0].jpyAmount == 0.0)
    }
}
