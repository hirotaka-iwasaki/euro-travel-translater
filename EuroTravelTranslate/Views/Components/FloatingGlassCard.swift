import SwiftUI

struct FloatingGlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    init(cornerRadius: CGFloat = Glass.cornerL, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .glassSurface(cornerRadius: cornerRadius)
    }
}

struct FloatingGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = Glass.cornerM

    func body(content: Content) -> some View {
        content
            .glassSurface(cornerRadius: cornerRadius)
    }
}

extension View {
    func floatingGlass(cornerRadius: CGFloat = Glass.cornerM) -> some View {
        modifier(FloatingGlassModifier(cornerRadius: cornerRadius))
    }
}

/// 背景とコンテンツの間に挟む大きなパネルレイヤー
struct GlassPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    init(cornerRadius: CGFloat = Glass.cornerXL, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .glassSurface(cornerRadius: cornerRadius, shadowIntensity: 0.5)
    }
}
