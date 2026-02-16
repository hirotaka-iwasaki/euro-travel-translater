import SwiftUI

// MARK: - Neumorphic Design Tokens

enum Neumorphic {
    // MARK: Colors — light surface with French blue tint
    static let surfaceColor = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let lightShadowColor = Color.white.opacity(0.80)
    static let darkShadowColor = Color(red: 0.70, green: 0.72, blue: 0.76).opacity(0.40)
    static let primaryText = Color(red: 0.08, green: 0.10, blue: 0.18)
    static let secondaryText = Color(red: 0.34, green: 0.37, blue: 0.46)
    static let accent = Color(red: 0.02, green: 0.16, blue: 0.56)

    // MARK: Corner Radii
    static let cornerXL: CGFloat = 36
    static let cornerL: CGFloat = 24
    static let cornerM: CGFloat = 18

    // MARK: Shadow Parameters — softer & wider for Dallo-style neumorphism
    enum Raised {
        static let radius: CGFloat = 14
        static let lightOffset: CGFloat = -8
        static let darkOffset: CGFloat = 8
    }

    enum Pressed {
        static let radius: CGFloat = 6
        static let lightOffset: CGFloat = -4
        static let darkOffset: CGFloat = 4
    }
}

// MARK: - Raised Modifier (浮き出し)

struct NeumorphicRaisedModifier: ViewModifier {
    var cornerRadius: CGFloat = Neumorphic.cornerL

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Neumorphic.surfaceColor)
                    .shadow(color: Neumorphic.lightShadowColor,
                            radius: Neumorphic.Raised.radius,
                            x: Neumorphic.Raised.lightOffset,
                            y: Neumorphic.Raised.lightOffset)
                    .shadow(color: Neumorphic.darkShadowColor,
                            radius: Neumorphic.Raised.radius,
                            x: Neumorphic.Raised.darkOffset,
                            y: Neumorphic.Raised.darkOffset)
            )
    }
}

// MARK: - Pressed Modifier (凹み)

struct NeumorphicPressedModifier: ViewModifier {
    var cornerRadius: CGFloat = Neumorphic.cornerL

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        Neumorphic.surfaceColor
                            .shadow(.inner(color: Neumorphic.darkShadowColor,
                                           radius: Neumorphic.Pressed.radius,
                                           x: Neumorphic.Pressed.darkOffset,
                                           y: Neumorphic.Pressed.darkOffset))
                            .shadow(.inner(color: Neumorphic.lightShadowColor,
                                           radius: Neumorphic.Pressed.radius,
                                           x: Neumorphic.Pressed.lightOffset,
                                           y: Neumorphic.Pressed.lightOffset))
                    )
            )
    }
}

// MARK: - Button Style (raised → pressed with spring)

struct NeumorphicButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = Neumorphic.cornerL

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            Neumorphic.surfaceColor
                                .shadow(.inner(color: Neumorphic.darkShadowColor,
                                               radius: Neumorphic.Pressed.radius,
                                               x: Neumorphic.Pressed.darkOffset,
                                               y: Neumorphic.Pressed.darkOffset))
                                .shadow(.inner(color: Neumorphic.lightShadowColor,
                                               radius: Neumorphic.Pressed.radius,
                                               x: Neumorphic.Pressed.lightOffset,
                                               y: Neumorphic.Pressed.lightOffset))
                        )
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Neumorphic.surfaceColor)
                        .shadow(color: Neumorphic.lightShadowColor,
                                radius: Neumorphic.Raised.radius,
                                x: Neumorphic.Raised.lightOffset,
                                y: Neumorphic.Raised.lightOffset)
                        .shadow(color: Neumorphic.darkShadowColor,
                                radius: Neumorphic.Raised.radius,
                                x: Neumorphic.Raised.darkOffset,
                                y: Neumorphic.Raised.darkOffset)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func neumorphicRaised(cornerRadius: CGFloat = Neumorphic.cornerL) -> some View {
        modifier(NeumorphicRaisedModifier(cornerRadius: cornerRadius))
    }

    func neumorphicPressed(cornerRadius: CGFloat = Neumorphic.cornerL) -> some View {
        modifier(NeumorphicPressedModifier(cornerRadius: cornerRadius))
    }
}

extension ButtonStyle where Self == NeumorphicButtonStyle {
    static func neumorphic(cornerRadius: CGFloat = Neumorphic.cornerL) -> NeumorphicButtonStyle {
        NeumorphicButtonStyle(cornerRadius: cornerRadius)
    }
}
