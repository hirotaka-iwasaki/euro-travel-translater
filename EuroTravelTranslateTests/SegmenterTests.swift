import Testing
import Foundation
@testable import EuroTravelTranslate

@Suite("Segmenter Tests")
struct SegmenterTests {
    let segmenter = Segmenter()

    private func makeResult(_ text: String, isFinal: Bool = true) -> TranscriptionResult {
        TranscriptionResult(
            text: text,
            isFinal: isFinal,
            confidence: 0.9,
            locale: Locale(identifier: "en-US")
        )
    }

    @Test("Accepts valid final text")
    func acceptsFinalText() {
        let result = segmenter.process(makeResult("Hello world"))
        #expect(result == "Hello world")
    }

    @Test("Rejects partial results")
    func rejectsPartial() {
        let result = segmenter.process(makeResult("Hello", isFinal: false))
        #expect(result == nil)
    }

    @Test("Rejects duplicate final text")
    func rejectsDuplicate() {
        _ = segmenter.process(makeResult("Hello world"))
        let result = segmenter.process(makeResult("Hello world"))
        #expect(result == nil)
    }

    @Test("Rejects short text under 3 chars")
    func rejectsShortText() {
        let result = segmenter.process(makeResult("Hi"))
        #expect(result == nil)
    }

    @Test("Normalizes whitespace")
    func normalizesWhitespace() {
        let result = segmenter.process(makeResult("  Hello   world  "))
        #expect(result == "Hello world")
    }

    @Test("Rejects empty text")
    func rejectsEmpty() {
        let result = segmenter.process(makeResult("   "))
        #expect(result == nil)
    }

    @Test("Reset allows same text again")
    func resetAllowsSameText() {
        _ = segmenter.process(makeResult("Hello world"))
        segmenter.reset()
        let result = segmenter.process(makeResult("Hello world"))
        #expect(result == "Hello world")
    }

    @Test("Accepts different final texts")
    func acceptsDifferentTexts() {
        let r1 = segmenter.process(makeResult("Hello world"))
        let r2 = segmenter.process(makeResult("Goodbye world"))
        #expect(r1 == "Hello world")
        #expect(r2 == "Goodbye world")
    }
}
