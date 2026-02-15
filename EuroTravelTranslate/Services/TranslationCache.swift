import Foundation

actor TranslationCache {
    private var cache: [String: String] = [:]
    private var accessOrder: [String] = []
    private let maxSize: Int

    init(maxSize: Int = 500) {
        self.maxSize = maxSize
    }

    func get(source: LanguageCode, target: LanguageCode, text: String) -> String? {
        let key = makeKey(source: source, target: target, text: text)
        guard let value = cache[key] else { return nil }
        // Move to end of access order (most recently used)
        if let idx = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: idx)
            accessOrder.append(key)
        }
        return value
    }

    func set(source: LanguageCode, target: LanguageCode, text: String, translation: String) {
        let key = makeKey(source: source, target: target, text: text)

        if cache[key] == nil {
            // Evict LRU if at capacity
            while cache.count >= maxSize, let oldest = accessOrder.first {
                accessOrder.removeFirst()
                cache.removeValue(forKey: oldest)
            }
            accessOrder.append(key)
        } else {
            // Update access order
            if let idx = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: idx)
                accessOrder.append(key)
            }
        }

        cache[key] = translation
    }

    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }

    var count: Int { cache.count }

    private func makeKey(source: LanguageCode, target: LanguageCode, text: String) -> String {
        "\(source.rawValue)>\(target.rawValue):\(text)"
    }
}
