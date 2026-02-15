import SwiftUI
import SwiftData

struct VoiceHistoryView: View {
    @Query(
        filter: #Predicate<TranslationItem> { $0.mode == "voice" },
        sort: \TranslationItem.createdAt,
        order: .reverse
    )
    private var translations: [TranslationItem]

    var body: some View {
        List {
            if translations.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock",
                    description: Text("Voice translations will appear here")
                )
            } else {
                ForEach(todayTranslations) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.translatedText)
                            .font(.body)
                        Text(item.sourceText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(item.createdAt, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Voice History")
    }

    private var todayTranslations: [TranslationItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return translations.filter { $0.createdAt >= today }
    }
}
