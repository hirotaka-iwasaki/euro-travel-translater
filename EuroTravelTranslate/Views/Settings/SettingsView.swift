import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showDeleteConfirm = false
    @State private var showRateInput = false

    var body: some View {
        List {
            Section("為替レート") {
                Button {
                    showRateInput = true
                } label: {
                    HStack {
                        Text("€1 = ¥")
                            .foregroundStyle(Glass.primaryText)
                        Text(viewModel.rateText)
                            .fontWeight(.semibold)
                            .foregroundStyle(Glass.primaryText)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundStyle(Glass.secondaryText)
                    }
                }

                let preview = Int((12.5 * viewModel.eurToJpyRate).rounded())
                Text("€12.50 → ¥\(preview)")
                    .font(.caption)
                    .foregroundStyle(Glass.secondaryText)
            }
            .listRowBackground(Color.white.opacity(0.45))

            Section("旅行期間") {
                Toggle("旅行開始日を設定", isOn: Binding(
                    get: { viewModel.tripStartDate != nil },
                    set: { enabled in
                        viewModel.tripStartDate = enabled ? Date() : nil
                        viewModel.save()
                    }
                ))

                if let startDate = viewModel.tripStartDate {
                    DatePicker(
                        "開始日",
                        selection: Binding(
                            get: { startDate },
                            set: {
                                viewModel.tripStartDate = $0
                                viewModel.save()
                            }
                        ),
                        displayedComponents: .date
                    )
                }
            }
            .listRowBackground(Color.white.opacity(0.45))

            Section("データ") {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("全支出データを削除", systemImage: "trash")
                }
            }
            .listRowBackground(Color.white.opacity(0.45))

            Section("アプリ情報") {
                HStack {
                    Text("バージョン")
                        .foregroundStyle(Glass.primaryText)
                    Spacer()
                    Text("2.0.0")
                        .foregroundStyle(Glass.secondaryText)
                }
            }
            .listRowBackground(Color.white.opacity(0.45))
        }
        .scrollContentBackground(.hidden)
        .appBackground()
        .navigationTitle("設定")
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .alert("為替レート", isPresented: $showRateInput) {
            TextField("レート", text: $viewModel.rateText)
                .keyboardType(.decimalPad)
            Button("保存") {
                viewModel.commitRate()
            }
            Button("キャンセル", role: .cancel) {
                viewModel.revertRateText()
            }
        } message: {
            Text("€1あたりの円レートを入力")
        }
        .alert("確認", isPresented: $showDeleteConfirm) {
            Button("削除", role: .destructive) {
                viewModel.deleteAllExpenses()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("全ての支出データを削除しますか？この操作は取り消せません。")
        }
    }
}
