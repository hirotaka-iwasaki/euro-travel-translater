import Foundation
import SwiftData

@Model
final class CameraCaptureItem {
    var id: UUID
    var createdAt: Date
    var sourceLang: String
    var extractedText: String
    var translatedText: String
    @Attribute(.externalStorage) var imageData: Data?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        sourceLang: String,
        extractedText: String,
        translatedText: String,
        imageData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.sourceLang = sourceLang
        self.extractedText = extractedText
        self.translatedText = translatedText
        self.imageData = imageData
    }
}
