import SwiftUI
import SwiftData

@Observable
@MainActor
final class ExpensesViewModel {
    var expenses: [ExpenseItem] = []
    var todayTotal: Double = 0
    var tripTotal: Double = 0
    var categoryTotals: [(ExpenseCategory, Double)] = []
    var eurToJpyRate: Double = 160.0

    private var modelContext: ModelContext?
    private var tripStartDate: Date?

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
        refresh()
    }

    private func loadSettings() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SettingsState>()
        if let settings = try? modelContext.fetch(descriptor).first {
            eurToJpyRate = settings.eurToJpyRate
            tripStartDate = settings.tripStartDate
        }
    }

    func addExpense(euroAmount: Double, category: ExpenseCategory, memo: String) {
        guard let modelContext else { return }
        let item = ExpenseItem(euroAmount: euroAmount, category: category, memo: memo)
        modelContext.insert(item)
        try? modelContext.save()
        AppLogger.expenses.info("Added expense: €\(euroAmount) [\(category.rawValue)]")
        refresh()
    }

    func deleteExpense(_ item: ExpenseItem) {
        guard let modelContext else { return }
        modelContext.delete(item)
        try? modelContext.save()
        refresh()
    }

    func refresh() {
        guard let modelContext else { return }
        loadSettings()

        let descriptor = FetchDescriptor<ExpenseItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        expenses = (try? modelContext.fetch(descriptor)) ?? []

        // Today total
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        todayTotal = expenses
            .filter { $0.createdAt >= startOfToday }
            .reduce(0) { $0 + $1.euroAmount }

        // Trip total
        if let start = tripStartDate {
            tripTotal = expenses
                .filter { $0.createdAt >= start }
                .reduce(0) { $0 + $1.euroAmount }
        } else {
            tripTotal = expenses.reduce(0) { $0 + $1.euroAmount }
        }

        // Category totals
        var totals: [ExpenseCategory: Double] = [:]
        for item in expenses {
            let cat = item.expenseCategory
            totals[cat, default: 0] += item.euroAmount
        }
        categoryTotals = totals
            .sorted { $0.value > $1.value }
    }

    /// Group expenses by day (descending)
    var groupedByDay: [(Date, [ExpenseItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { item in
            calendar.startOfDay(for: item.createdAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}
