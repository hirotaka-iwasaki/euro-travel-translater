import SwiftUI

struct TranscriptRow: View {
    let text: String
    let lang: LanguageCode

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(lang.shortLabel)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.blue, in: RoundedRectangle(cornerRadius: 4))

            Text(text)
                .font(.body)
                .textSelection(.enabled)
        }
        .padding(.vertical, 4)
    }
}
