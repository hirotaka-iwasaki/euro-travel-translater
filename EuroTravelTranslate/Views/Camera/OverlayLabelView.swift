import SwiftUI

struct OverlayLabelView: View {
    let overlay: TranslatedOverlay

    var body: some View {
        Text(overlay.translatedText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .lineLimit(2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 4))
            .position(
                x: overlay.bounds.midX,
                y: overlay.bounds.minY - 12
            )
    }
}
