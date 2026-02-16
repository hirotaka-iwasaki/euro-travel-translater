import SwiftUI

struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExpensesViewModel()

    var body: some View {
        List {
            // Summary card
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("今日")
                            .font(.subheadline)
                            .foregroundStyle(Glass.secondaryText)
                        Spacer()
                        Text("\(formatEuro(viewModel.todayTotal))  (\(formatJPY(viewModel.todayTotal * viewModel.eurToJpyRate)))")
                            .font(.headline)
                            .foregroundStyle(Glass.primaryText)
                    }
                    HStack {
                        Text("合計")
                            .font(.subheadline)
                            .foregroundStyle(Glass.secondaryText)
                        Spacer()
                        Text("\(formatEuro(viewModel.tripTotal))  (\(formatJPY(viewModel.tripTotal * viewModel.eurToJpyRate)))")
                            .font(.headline)
                            .foregroundStyle(Glass.primaryText)
                    }
                }
            }
            .listRowBackground(Color.white.opacity(0.45))

            // Category breakdown
            if !viewModel.categoryTotals.isEmpty {
                Section("カテゴリ別") {
                    ForEach(viewModel.categoryTotals, id: \.0) { category, total in
                        HStack(spacing: 10) {
                            Image(systemName: category.icon)
                                .foregroundStyle(category.color)
                                .frame(width: 24)
                            Text(category.displayName)
                                .font(.subheadline)
                                .foregroundStyle(Glass.primaryText)

                            // Bar
                            GeometryReader { geo in
                                let maxTotal = viewModel.categoryTotals.first?.1 ?? 1
                                let ratio = maxTotal > 0 ? total / maxTotal : 0
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(category.color.opacity(0.6))
                                    .frame(width: geo.size.width * ratio, height: 14)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .frame(height: 20)

                            Text(formatEuro(total))
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(Glass.primaryText)
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.45))
            }

            // Daily groups
            ForEach(viewModel.groupedByDay, id: \.0) { day, items in
                Section(dayHeader(day)) {
                    ForEach(items, id: \.id) { item in
                        HStack(spacing: 10) {
                            Image(systemName: item.expenseCategory.icon)
                                .foregroundStyle(item.expenseCategory.color)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.expenseCategory.displayName)
                                    .font(.subheadline)
                                    .foregroundStyle(Glass.primaryText)
                                if !item.memo.isEmpty {
                                    Text(item.memo)
                                        .font(.caption)
                                        .foregroundStyle(Glass.secondaryText)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(formatEuro(item.euroAmount))
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(Glass.primaryText)
                                Text(formatJPY(item.euroAmount * viewModel.eurToJpyRate))
                                    .font(.caption)
                                    .foregroundStyle(Glass.secondaryText)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteExpense(items[index])
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.45))
            }

            if viewModel.expenses.isEmpty {
                Section {
                    ContentUnavailableView(
                        "支出なし",
                        systemImage: "yensign.circle",
                        description: Text("変換タブから金額を記録できます")
                    )
                }
                .listRowBackground(Color.white.opacity(0.45))
            }
        }
        .scrollContentBackground(.hidden)
        .appBackground()
        .navigationTitle("支出")
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    private func dayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter.string(from: date)
    }

    private func formatEuro(_ amount: Double) -> String {
        String(format: "€%.2f", amount)
    }

    private func formatJPY(_ amount: Double) -> String {
        let rounded = Int(amount.rounded())
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"
        return "¥\(formatted)"
    }
}
