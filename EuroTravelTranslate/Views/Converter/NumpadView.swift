import SwiftUI

struct NumpadView: View {
    var onDigit: (String) -> Void
    var onDot: () -> Void
    var onDelete: () -> Void
    var onClear: (() -> Void)?

    @State private var tapCount = 0

    private let rows: [[NumpadKey]] = [
        [.digit("7"), .digit("8"), .digit("9")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("1"), .digit("2"), .digit("3")],
        [.dot, .digit("0"), .delete],
    ]

    var body: some View {
        Grid(horizontalSpacing: 14, verticalSpacing: 12) {
            ForEach(rows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { key in
                        numpadButton(for: key)
                    }
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: tapCount)
    }

    @ViewBuilder
    private func numpadButton(for key: NumpadKey) -> some View {
        let base = Button {
            tapCount += 1
            switch key {
            case .digit(let d): onDigit(d)
            case .dot: onDot()
            case .delete: onDelete()
            }
        } label: {
            key.label
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Glass.primaryText)
                .frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(.glassKey(cornerRadius: Glass.cornerM))
        .accessibilityIdentifier(key.accessibilityID)

        if key == .delete, let onClear {
            base.simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in onClear() }
            )
        } else {
            base
        }
    }
}

private enum NumpadKey: Hashable {
    case digit(String)
    case dot
    case delete

    var accessibilityID: String {
        switch self {
        case .digit(let d): return "numpad_\(d)"
        case .dot: return "numpad_dot"
        case .delete: return "numpad_delete"
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .digit(let d):
            Text(d)
        case .dot:
            Text(".")
        case .delete:
            Image(systemName: "delete.backward")
                .font(.system(size: 20, weight: .medium))
        }
    }
}
