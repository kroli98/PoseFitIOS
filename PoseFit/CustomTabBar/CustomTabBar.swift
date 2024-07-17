
import SwiftUI

public struct CustomTabBar<T: TabBarItemProtocol>: View {

    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedTab: T
    
   
    private let allCases: [T]

    private var safeAreaInsets: UIEdgeInsets? {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets
    }

    public init(selectedTab: T, allCases: [T]) {
        self._selectedTab = State(initialValue: selectedTab)
        self.allCases = allCases
    }

    public var body: some View {
        
           TabView(selection: $selectedTab) {
               ForEach(allCases, id: \.self) { tab in
                   
                   NavigationView{
                       
                       if (tab.tag != 2)
                       {
                           ScrollView{
                               VStack {
                                   tab.getContent()
                                       .environmentObject(navigationCoordinator)
                                   
                                   
                                   
                               }
                               
                           }
                       }
                       else
                       {
                           
                           tab.getContent()
                               .environmentObject(navigationCoordinator)
                           
                           
                           
                       }
                       
                       
                   }
                   
               }
                   
                   
               }
           
           .overlay(alignment: .bottom) {
               if !navigationCoordinator.isNavigating {
                   let bottomPadding = safeAreaInsets?.bottom == 0 ? TabBarConstants.tabBarBottomPaddingForOlderDevices : 0
                   getCustomTabBarView()
                       .padding(.bottom, bottomPadding)
               }
           }
       }
        

    @ViewBuilder
    private func getCustomTabBarView() -> some View {
        HStack {
            Spacer(minLength: 0)
            ForEach(allCases, id: \.self) { tab in
                CustomTabButton(currentTab: tab, selectedTab: $selectedTab)
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: 600)
        .font(.title2.bold())
        .frame(height: TabBarConstants.customTabBarHeight)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.horizontal, 60)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 5, y: 5)
        .shadow(color: .black.opacity(0.15), radius: 5, x: -5, y: -5)
    }
  
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
     
        let navigationCoordinator = NavigationCoordinator()
         
        CustomTabBar(selectedTab: CustomTabBarItem.settings, allCases: CustomTabBarItem.allCases)
            .environmentObject(navigationCoordinator)
    }
}
