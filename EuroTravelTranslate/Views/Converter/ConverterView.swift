import SwiftUI

struct ConverterView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ConverterViewModel()
    @State private var expensesVM = ExpensesViewModel()
    @State private var showRecordSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Amount display (double-tap to clear)
            Spacer()
            VStack(spacing: 6) {
                Text(euroDisplay)
                    .font(.system(size: 52, weight: .semibold, design: .rounded))
                    .foregroundStyle(Glass.primaryText)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(jpyDisplay)
                    .font(.system(size: 26, weight: .regular, design: .rounded))
                    .foregroundStyle(Glass.secondaryText.opacity(0.8))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                guard !viewModel.inputText.isEmpty else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.clear()
                }
            }
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.inputText)
            Spacer()

            // Numpad
            NumpadView(
                onDigit: { viewModel.appendDigit($0) },
                onDot: { viewModel.appendDot() },
                onDelete: { viewModel.deleteLast() },
                onClear: { viewModel.clear() }
            )
            .padding(.horizontal, 20)

            // Record button
            Button {
                showRecordSheet = true
            } label: {
                Text("記録する")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        viewModel.eurAmount > 0
                            ? Glass.accentRed
                            : Glass.secondaryText.opacity(0.6)
                    )
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.glass(cornerRadius: Glass.cornerL))
            .sensoryFeedback(.impact(weight: .light), trigger: showRecordSheet)
            .disabled(viewModel.eurAmount <= 0)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
        .padding(.horizontal, 8)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Convertisseur")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Glass.accent)
            }
        }
        .appBackground()
        .onAppear {
            viewModel.setup(modelContext: modelContext)
            expensesVM.setup(modelContext: modelContext)
        }
        .sheet(isPresented: $showRecordSheet) {
            RecordExpenseSheet(
                euroAmount: viewModel.eurAmount,
                jpyAmount: viewModel.jpyAmount
            ) { category, memo in
                expensesVM.addExpense(
                    euroAmount: viewModel.eurAmount,
                    category: category,
                    memo: memo
                )
                viewModel.clear()
            }
        }
    }

    private var euroDisplay: String {
        if viewModel.inputText.isEmpty {
            return "€0"
        }
        return "€\(viewModel.inputText)"
    }

    private var jpyDisplay: String {
        let rounded = Int(viewModel.jpyAmount.rounded())
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"
        return "¥\(formatted)"
    }
}
