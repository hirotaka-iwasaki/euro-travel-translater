import SwiftUI

struct RecordExpenseSheet: View {
    let euroAmount: Double
    let jpyAmount: Double
    var onSave: (ExpenseCategory, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: ExpenseCategory
    @State private var memo: String = ""
    @State private var userHasOverridden = false
    @State private var isResolvingPOI = false

    private let suggester = CategorySuggester()
    private let locationService: LocationServiceProtocol
    private let poiResolver: POIResolverProtocol

    init(
        euroAmount: Double,
        jpyAmount: Double,
        locationService: LocationServiceProtocol = LocationService.shared,
        poiResolver: POIResolverProtocol = POIResolver(),
        onSave: @escaping (ExpenseCategory, String) -> Void
    ) {
        self.euroAmount = euroAmount
        self.jpyAmount = jpyAmount
        self.locationService = locationService
        self.poiResolver = poiResolver
        self.onSave = onSave
        let suggested = CategorySuggester().suggest()
        _selectedCategory = State(initialValue: suggested)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Amount display
                FloatingGlassCard(cornerRadius: Glass.cornerL) {
                    VStack(spacing: 4) {
                        Text(formatEuro(euroAmount))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Glass.primaryText)
                        Text(formatJPY(jpyAmount))
                            .font(.title3)
                            .foregroundStyle(Glass.secondaryText)
                    }
                }
                .padding(.top, 8)

                // Category grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 12) {
                    ForEach(ExpenseCategory.allCases, id: \.rawValue) { (category: ExpenseCategory) in
                        Button {
                            selectedCategory = category
                            userHasOverridden = true
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    Image(systemName: category.icon)
                                        .font(.title2)
                                    if isResolvingPOI && selectedCategory == category && !userHasOverridden {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                            .offset(x: 16, y: -12)
                                    }
                                }
                                Text(category.displayName)
                                    .font(.caption)
                            }
                            .foregroundStyle(selectedCategory == category ? category.color : Glass.primaryText)
                            .frame(maxWidth: .infinity, minHeight: 72)
                        }
                        .buttonStyle(.glassCategory(
                            isSelected: selectedCategory == category,
                            accentColor: category.color
                        ))
                    }
                }
                .padding(.horizontal)

                // Memo field
                TextField("メモ（任意）", text: $memo)
                    .padding(12)
                    .glassSurface(cornerRadius: Glass.cornerM, showHighlight: false, shadowIntensity: 0.3)
                    .padding(.horizontal)

                Spacer()

                // Save button
                Button {
                    onSave(selectedCategory, memo)
                    dismiss()
                } label: {
                    Text("保存")
                        .font(.headline)
                        .foregroundStyle(Glass.accent)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.glass(cornerRadius: Glass.cornerL))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("記録する")
            .appBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .task {
                await resolvePOISuggestion()
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func resolvePOISuggestion() async {
        isResolvingPOI = true
        defer { isResolvingPOI = false }

        guard let location = await locationService.requestLocation() else { return }
        guard !userHasOverridden else { return }

        let poiResult = await poiResolver.resolve(at: location)
        guard !userHasOverridden else { return }

        let suggestion = suggester.suggest(poiResult: poiResult)
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCategory = suggestion.category
        }
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
