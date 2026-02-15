import Foundation
import SwiftData

@Model
final class TranscriptItem {
    var id: UUID
    var createdAt: Date
    var sourceLang: String
    var sourceText: String
    var isFinal: Bool
    var confidence: Double?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        sourceLang: String,
        sourceText: String,
        isFinal: Bool = true,
        confidence: Double? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.sourceLang = sourceLang
        self.sourceText = sourceText
        self.isFinal = isFinal
        self.confidence = confidence
    }
}
