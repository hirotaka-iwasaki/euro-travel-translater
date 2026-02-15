import SwiftUI
import VisionKit

struct DataScannerRepresentable: UIViewControllerRepresentable {
    let recognizedLanguages: [String]
    let onTextFound: @Sendable ([ScannedTextElement]) -> Void
    @Binding var isFrozen: Bool

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(languages: recognizedLanguages)],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: false
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        if isFrozen {
            if scanner.isScanning {
                scanner.stopScanning()
            }
        } else {
            if !scanner.isScanning {
                try? scanner.startScanning()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextFound: onTextFound)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate, @unchecked Sendable {
        let onTextFound: @Sendable ([ScannedTextElement]) -> Void
        private var lastUpdate = Date.distantPast
        private let minInterval: TimeInterval = 0.1 // ~10fps throttle

        init(onTextFound: @escaping @Sendable ([ScannedTextElement]) -> Void) {
            self.onTextFound = onTextFound
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            let now = Date()
            guard now.timeIntervalSince(lastUpdate) >= minInterval else { return }
            lastUpdate = now

            let elements = allItems.compactMap { item -> ScannedTextElement? in
                guard case .text(let text) = item else { return nil }
                let bounds = text.bounds
                let rect = CGRect(
                    x: bounds.topLeft.x,
                    y: bounds.topLeft.y,
                    width: bounds.topRight.x - bounds.topLeft.x,
                    height: bounds.bottomLeft.y - bounds.topLeft.y
                )
                return ScannedTextElement(text: text.transcript, bounds: rect)
            }

            onTextFound(elements)
        }
    }
}
