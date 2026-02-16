import SwiftUI

// MARK: - Liquid Glass Design Tokens

enum Glass {
    // MARK: - Corner Radii
    static let cornerXL: CGFloat = 40
    static let cornerL: CGFloat = 28
    static let cornerM: CGFloat = 20
    static let cornerS: CGFloat = 14
    static let cornerPill: CGFloat = 100

    // MARK: - Border
    static let borderColor = Color.white.opacity(0.55)
    static let borderColorStrong = Color.white.opacity(0.75)
    static let borderWidth: CGFloat = 0.5

    // MARK: - Specular Highlight
    static let highlightTop = Color.white.opacity(0.70)
    static let highlightMid = Color.white.opacity(0.10)

    // MARK: - Shadow
    static let shadowColor = Color.black.opacity(0.07)
    static let shadowRadius: CGFloat = 20
    static let shadowY: CGFloat = 10

    // MARK: - Text Colors
    static let primaryText = Color(red: 0.08, green: 0.10, blue: 0.18)
    static let secondaryText = Color(red: 0.34, green: 0.37, blue: 0.46)
    static let accent = Color(red: 0.02, green: 0.16, blue: 0.56)
    static let accentSubtle = Color(red: 0.02, green: 0.16, blue: 0.56).opacity(0.12)
    static let accentRed = Color(red: 0.80, green: 0.18, blue: 0.24)
    static let accentRedSubtle = Color(red: 0.80, green: 0.18, blue: 0.24).opacity(0.12)

    // MARK: - Background Gradient (French tricolore mesh)
    static let bgTopLeading = Color(red: 0.68, green: 0.78, blue: 0.94)    // French blue
    static let bgTopTrailing = Color(red: 0.78, green: 0.84, blue: 0.96)   // soft blue
    static let bgCenter = Color(red: 0.96, green: 0.95, blue: 0.94)        // cream white
    static let bgBottomLeading = Color(red: 0.94, green: 0.76, blue: 0.78) // French rose
    static let bgBottomTrailing = Color(red: 0.96, green: 0.82, blue: 0.84) // soft rose

    // MARK: - Animation
    static let pressAnimation: Animation = .spring(response: 0.28, dampingFraction: 0.72)
    static let selectAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.7)
}
