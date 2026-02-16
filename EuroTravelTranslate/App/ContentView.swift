import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    init() {
        // Hide the default tab bar — we use a custom glass one
        UITabBar.appearance().isHidden = true

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.shadowColor = .clear
        let primaryUIColor = UIColor(Glass.primaryText)
        navAppearance.titleTextAttributes = [.foregroundColor: primaryUIColor]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: primaryUIColor]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    ConverterView()
                }
                .tag(0)

                NavigationStack {
                    ExpensesView()
                }
                .tag(1)

                NavigationStack {
                    SettingsView()
                }
                .tag(2)
            }

            // Custom glass tab bar
            GlassTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Custom Glass Tab Bar

private struct GlassTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var tabNamespace

    private let items: [(icon: String, label: String)] = [
        ("yensign", "変換"),
        ("list.bullet", "支出"),
        ("gearshape", "設定"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    withAnimation(Glass.selectAnimation) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: items[index].icon)
                            .font(.system(size: 20, weight: .medium))
                        Text(items[index].label)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(selectedTab == index ? Glass.accent : Glass.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background {
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: Glass.cornerM, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: Glass.cornerM, style: .continuous)
                                        .fill(Glass.accentSubtle)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: Glass.cornerM, style: .continuous)
                                        .strokeBorder(
                                            Glass.accent.opacity(0.2),
                                            lineWidth: 0.5
                                        )
                                }
                                .padding(4)
                                .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .glassSurface(cornerRadius: Glass.cornerPill, shadowIntensity: 0.8)
    }
}
