import Foundation

struct ScannedTextElement: Sendable {
    let text: String
    let bounds: CGRect
}

protocol TextScanner: Sendable {
    func start() -> AsyncStream<[ScannedTextElement]>
    func stop()
}
