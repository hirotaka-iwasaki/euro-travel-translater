import SwiftUI

struct AppBackground: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0],
            ],
            colors: [
                Glass.bgTopLeading, Glass.bgTopLeading, Glass.bgTopTrailing,
                Glass.bgTopTrailing, Glass.bgCenter,     Glass.bgCenter,
                Glass.bgBottomLeading, Glass.bgBottomLeading, Glass.bgBottomTrailing,
            ]
        )
        .ignoresSafeArea()
    }
}

extension View {
    func appBackground() -> some View {
        self.background { AppBackground() }
    }
}
