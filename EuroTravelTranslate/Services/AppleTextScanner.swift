import VisionKit

@MainActor
enum AppleTextScanner {
    static var isSupported: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }
}
