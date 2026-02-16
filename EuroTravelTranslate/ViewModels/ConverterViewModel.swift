import SwiftUI
import SwiftData

@Observable
@MainActor
final class ConverterViewModel {
    var inputText: String = ""
    var eurAmount: Double = 0
    var jpyAmount: Double = 0
    var eurToJpyRate: Double = 160.0

    private var modelContext: ModelContext?

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadRate()
    }

    private func loadRate() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SettingsState>()
        if let settings = try? modelContext.fetch(descriptor).first {
            eurToJpyRate = settings.eurToJpyRate
        }
        recalculate()
    }

    func refreshRate() {
        loadRate()
    }

    func appendDigit(_ digit: String) {
        guard digit.count == 1, "0123456789".contains(digit) else { return }

        // Limit total length
        if inputText.count >= 9 { return }

        // Prevent leading zeros (except for "0.")
        if inputText == "0" && digit == "0" { return }
        if inputText == "0" {
            inputText = digit
            recalculate()
            return
        }

        // Limit decimal places to 2
        if let dotIndex = inputText.firstIndex(of: ".") {
            let decimals = inputText[inputText.index(after: dotIndex)...]
            if decimals.count >= 2 { return }
        }

        inputText += digit
        recalculate()
    }

    func appendDot() {
        if inputText.isEmpty {
            inputText = "0."
        } else if !inputText.contains(".") {
            inputText += "."
        }
        recalculate()
    }

    func deleteLast() {
        guard !inputText.isEmpty else { return }
        inputText.removeLast()
        recalculate()
    }

    func setAmount(_ amount: Double) {
        if amount == amount.rounded() && amount >= 0 {
            inputText = String(Int(amount))
        } else {
            inputText = String(format: "%.2f", amount)
        }
        recalculate()
    }

    func clear() {
        inputText = ""
        eurAmount = 0
        jpyAmount = 0
    }

    private func recalculate() {
        eurAmount = Double(inputText) ?? 0
        jpyAmount = eurAmount * eurToJpyRate
    }
}
