import Testing
@testable import EuroTravelTranslate

@Suite("TranslationCache Tests")
struct TranslationCacheTests {

    @Test("Set and get returns cached value")
    func setAndGet() async {
        let cache = TranslationCache(maxSize: 10)
        await cache.set(source: .en, target: .ja, text: "hello", translation: "こんにちは")
        let result = await cache.get(source: .en, target: .ja, text: "hello")
        #expect(result == "こんにちは")
    }

    @Test("Cache miss returns nil")
    func cacheMiss() async {
        let cache = TranslationCache(maxSize: 10)
        let result = await cache.get(source: .en, target: .ja, text: "nonexistent")
        #expect(result == nil)
    }

    @Test("Different lang pairs are separate entries")
    func differentLangPairs() async {
        let cache = TranslationCache(maxSize: 10)
        await cache.set(source: .en, target: .ja, text: "hello", translation: "こんにちは")
        await cache.set(source: .fr, target: .ja, text: "hello", translation: "bonjour→こんにちは")

        let enResult = await cache.get(source: .en, target: .ja, text: "hello")
        let frResult = await cache.get(source: .fr, target: .ja, text: "hello")
        #expect(enResult == "こんにちは")
        #expect(frResult == "bonjour→こんにちは")
    }

    @Test("LRU eviction removes oldest")
    func lruEviction() async {
        let cache = TranslationCache(maxSize: 3)
        await cache.set(source: .en, target: .ja, text: "a", translation: "1")
        await cache.set(source: .en, target: .ja, text: "b", translation: "2")
        await cache.set(source: .en, target: .ja, text: "c", translation: "3")
        // This should evict "a"
        await cache.set(source: .en, target: .ja, text: "d", translation: "4")

        let evicted = await cache.get(source: .en, target: .ja, text: "a")
        let kept = await cache.get(source: .en, target: .ja, text: "b")
        #expect(evicted == nil)
        #expect(kept == "2")
    }

    @Test("Clear removes all entries")
    func clearRemovesAll() async {
        let cache = TranslationCache(maxSize: 10)
        await cache.set(source: .en, target: .ja, text: "hello", translation: "こんにちは")
        await cache.clear()
        let result = await cache.get(source: .en, target: .ja, text: "hello")
        #expect(result == nil)
        let count = await cache.count
        #expect(count == 0)
    }

    @Test("Accessing entry moves it to recently used")
    func accessUpdatesLRU() async {
        let cache = TranslationCache(maxSize: 3)
        await cache.set(source: .en, target: .ja, text: "a", translation: "1")
        await cache.set(source: .en, target: .ja, text: "b", translation: "2")
        await cache.set(source: .en, target: .ja, text: "c", translation: "3")

        // Access "a" to make it recently used
        _ = await cache.get(source: .en, target: .ja, text: "a")

        // This should evict "b" (oldest unused) instead of "a"
        await cache.set(source: .en, target: .ja, text: "d", translation: "4")

        let a = await cache.get(source: .en, target: .ja, text: "a")
        let b = await cache.get(source: .en, target: .ja, text: "b")
        #expect(a == "1")
        #expect(b == nil)
    }
}
