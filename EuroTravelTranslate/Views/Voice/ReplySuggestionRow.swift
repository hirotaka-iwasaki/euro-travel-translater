import SwiftUI

struct ReplySuggestionRow: View {
    let suggestion: ReplySuggestion
    var onCopy: () -> Void = {}
    var onSpeak: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(suggestion.localText)
                .font(.body)
                .fontWeight(.medium)

            Text(suggestion.englishText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(suggestion.jaHint)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            UIPasteboard.general.string = suggestion.localText
            onCopy()
        }
        .onLongPressGesture {
            onSpeak()
        }
    }
}
