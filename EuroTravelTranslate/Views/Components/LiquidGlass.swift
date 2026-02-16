import SwiftUI

// MARK: - Glass Surface Modifier

struct GlassSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat
    var showHighlight: Bool
    var shadowIntensity: Double

    init(
        cornerRadius: CGFloat = Glass.cornerL,
        showHighlight: Bool = true,
        shadowIntensity: Double = 1.0
    ) {
        self.cornerRadius = cornerRadius
        self.showHighlight = showHighlight
        self.shadowIntensity = shadowIntensity
    }

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Base frosted glass
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // Specular highlight (top → center fade)
                    if showHighlight {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Glass.highlightTop,
                                        Glass.highlightMid,
                                        Color.clear,
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .allowsHitTesting(false)
                    }

                    // Thin edge border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Glass.borderColorStrong,
                                    Glass.borderColor,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: Glass.borderWidth
                        )
                }
            }
            .shadow(
                color: Glass.shadowColor.opacity(shadowIntensity),
                radius: Glass.shadowRadius,
                x: 0,
                y: Glass.shadowY
            )
    }
}

// MARK: - Glass Button Style (Card / Record button)

struct GlassButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat

    init(cornerRadius: CGFloat = Glass.cornerL) {
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            Color.white.opacity(configuration.isPressed ? 0.08 : 0.25)
                        )
                }
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(Glass.pressAnimation, value: configuration.isPressed)
    }
}

// MARK: - Glass Key Button Style (Numpad)

struct GlassKeyButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat

    init(cornerRadius: CGFloat = Glass.cornerM) {
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.thinMaterial)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            Color.white.opacity(configuration.isPressed ? 0.12 : 0.45)
                        )
                }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(Glass.pressAnimation, value: configuration.isPressed)
    }
}

// MARK: - Glass Category Button Style (Record Sheet)

struct GlassCategoryButtonStyle: ButtonStyle {
    var isSelected: Bool
    var accentColor: Color
    var cornerRadius: CGFloat

    init(isSelected: Bool, accentColor: Color = Glass.accent, cornerRadius: CGFloat = Glass.cornerM) {
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    if isSelected {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(accentColor.opacity(0.10))
                    }

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(configuration.isPressed ? 0.20 : 0.50),
                                    Color.white.opacity(0.05),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            isSelected
                                ? accentColor.opacity(0.35)
                                : Color.white.opacity(configuration.isPressed ? 0.35 : 0.55),
                            lineWidth: isSelected ? 1.0 : Glass.borderWidth
                        )
                }
            }
            .shadow(
                color: Glass.shadowColor,
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(Glass.pressAnimation, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func glassSurface(
        cornerRadius: CGFloat = Glass.cornerL,
        showHighlight: Bool = true,
        shadowIntensity: Double = 1.0
    ) -> some View {
        modifier(GlassSurfaceModifier(
            cornerRadius: cornerRadius,
            showHighlight: showHighlight,
            shadowIntensity: shadowIntensity
        ))
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static func glass(cornerRadius: CGFloat = Glass.cornerL) -> GlassButtonStyle {
        GlassButtonStyle(cornerRadius: cornerRadius)
    }
}

extension ButtonStyle where Self == GlassKeyButtonStyle {
    static func glassKey(cornerRadius: CGFloat = Glass.cornerM) -> GlassKeyButtonStyle {
        GlassKeyButtonStyle(cornerRadius: cornerRadius)
    }
}

extension ButtonStyle where Self == GlassCategoryButtonStyle {
    static func glassCategory(isSelected: Bool, accentColor: Color = Glass.accent) -> GlassCategoryButtonStyle {
        GlassCategoryButtonStyle(isSelected: isSelected, accentColor: accentColor)
    }
}

// MARK: - Previews

#Preview("Glass Components") {
    ZStack {
        AppBackground()
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 32) {
                // GlassCard
                VStack(spacing: 8) {
                    Text("GlassCard")
                        .font(.caption)
                        .foregroundStyle(Glass.secondaryText)
                    Text("€42.50")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundStyle(Glass.primaryText)
                    Text("¥6,800")
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundStyle(Glass.secondaryText)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .glassSurface(cornerRadius: Glass.cornerL)
                .padding(.horizontal, 24)

                // GlassKey
                VStack(spacing: 8) {
                    Text("GlassKey")
                        .font(.caption)
                        .foregroundStyle(Glass.secondaryText)
                    HStack(spacing: 14) {
                        ForEach(["7", "8", "9"], id: \.self) { digit in
                            Button(digit) {}
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundStyle(Glass.primaryText)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .buttonStyle(.glassKey())
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // GlassButton
                VStack(spacing: 8) {
                    Text("GlassButton")
                        .font(.caption)
                        .foregroundStyle(Glass.secondaryText)
                    Button {} label: {
                        Text("記録する")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Glass.accent)
                            .frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(.glass(cornerRadius: Glass.cornerL))
                    .padding(.horizontal, 24)
                }

                // GlassBottomBar
                VStack(spacing: 8) {
                    Text("GlassBottomBar")
                        .font(.caption)
                        .foregroundStyle(Glass.secondaryText)
                    HStack(spacing: 0) {
                        ForEach(["yensign", "list.bullet", "gearshape"], id: \.self) { icon in
                            VStack(spacing: 4) {
                                Image(systemName: icon)
                                    .font(.system(size: 20, weight: .medium))
                                Text("Tab")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(icon == "yensign" ? Glass.accent : Glass.secondaryText)
                            .frame(maxWidth: .infinity, minHeight: 52)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .glassSurface(cornerRadius: Glass.cornerPill, shadowIntensity: 0.8)
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 32)
        }
    }
}
