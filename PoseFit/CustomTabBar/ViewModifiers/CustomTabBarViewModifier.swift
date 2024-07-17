
import SwiftUI

struct CustomTabBarViewModifier<V: TabBarItemProtocol>: ViewModifier {
    private let tab: V

    private var safeAreaInsets: UIEdgeInsets? {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets
    }
    
    init(tab: V) {
        self.tab = tab
    }

    func body(content: Content) -> some View {
        let bottomPadding = safeAreaInsets?.bottom  == 0 ? TabBarConstants.tabBarBottomPaddingForOlderDevices : 0

        content
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                Spacer().frame(height: TabBarConstants.customTabBarHeight + bottomPadding)
            }
            .tag(tab.tag)
            .onAppear {
                UITabBar.changeTabBarState(shouldHide: true)
            }
    }
}

public extension View {

    func setupCustomTab<V: TabBarItemProtocol>(tab: V) -> some View {
        return modifier(CustomTabBarViewModifier(tab: tab))
    }
}
