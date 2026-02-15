import SwiftUI

struct PhraseRow: View {
    let localText: String
    let englishText: String
    let jaHint: String
    var onCopy: () -> Void = {}
    var onSpeak: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(localText)
                .font(.body)
                .fontWeight(.medium)

            Text(englishText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(jaHint)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
        .onLongPressGesture {
            onSpeak()
        }
    }
}
