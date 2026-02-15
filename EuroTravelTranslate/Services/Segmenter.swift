import Foundation
import os

final class Segmenter: Sendable {
    private let lock = OSAllocatedUnfairLock<String?>(initialState: nil)

    /// Process a transcription result. Returns the cleaned text if it's a new, valid final segment.
    func process(_ result: TranscriptionResult) -> String? {
        guard result.isFinal else { return nil }

        let cleaned = normalize(result.text)
        guard !cleaned.isEmpty else { return nil }
        guard cleaned.count >= 3 else { return nil }

        return lock.withLock { lastFinalText in
            if let last = lastFinalText, cleaned == last {
                return nil
            }
            lastFinalText = cleaned
            return cleaned
        }
    }

    func reset() {
        lock.withLock { lastFinalText in
            lastFinalText = nil
        }
    }

    private func normalize(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
    }
}
