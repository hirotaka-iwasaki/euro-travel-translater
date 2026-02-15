import SwiftUI

struct TranslationRow: View {
    let sourceText: String
    let translatedText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(translatedText)
                .font(.body)
                .fontWeight(.medium)
                .textSelection(.enabled)

            Text(sourceText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}
