import SwiftUI
import SwiftData

@Observable
@MainActor
final class SettingsViewModel {
    var settings: SettingsState?
    var eurToJpyRate: Double = 160.0
    var rateText: String = "160"
    var tripStartDate: Date?

    private var modelContext: ModelContext?

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }

    private func loadSettings() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SettingsState>()
        if let existing = try? modelContext.fetch(descriptor).first {
            settings = existing
            eurToJpyRate = existing.eurToJpyRate
            rateText = formatRate(existing.eurToJpyRate)
            tripStartDate = existing.tripStartDate
        } else {
            let newSettings = SettingsState()
            modelContext.insert(newSettings)
            try? modelContext.save()
            settings = newSettings
        }
    }

    func commitRate() {
        if let parsed = Double(rateText), parsed > 0 {
            eurToJpyRate = parsed
            rateText = formatRate(parsed)
        } else {
            rateText = formatRate(eurToJpyRate)
        }
        save()
    }

    func revertRateText() {
        rateText = formatRate(eurToJpyRate)
    }

    func save() {
        guard let settings, let modelContext else { return }
        settings.eurToJpyRate = eurToJpyRate
        settings.tripStartDate = tripStartDate
        try? modelContext.save()
    }

    private func formatRate(_ rate: Double) -> String {
        if rate == rate.rounded() {
            return String(Int(rate))
        }
        return String(format: "%.2f", rate)
    }

    func deleteAllExpenses() {
        guard let modelContext else { return }
        do {
            try modelContext.delete(model: ExpenseItem.self)
            try modelContext.save()
        } catch {
            AppLogger.general.error("Failed to delete expenses: \(error)")
        }
    }
}
