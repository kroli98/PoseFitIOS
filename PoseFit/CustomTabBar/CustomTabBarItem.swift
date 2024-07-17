

import SwiftUI

enum CustomTabBarItem: TabBarItemProtocol {
    case home
    
    case analysis

    case settings
    
    

    var tag: Int {
        switch self {
        case .home:
            return 0
      
        case .analysis:
            return 1
            
        case .settings:
            return 2
            
       
        }
    }

    var imageName: String {
        switch self {
        case .home:
            return "house"
       
        case .settings:
            return "gearshape.fill"
            
        case .analysis:
            return "chart.bar.fill"
        }
    }

    func getContent() -> some View {
        switch self {
        case .home:
           HomeView()
            .frame(maxHeight: .infinity)
            .setupCustomTab(tab: CustomTabBarItem.home)
      
        case .settings:
            SettingsView()
                .frame(maxHeight: .infinity)
                .setupCustomTab(tab: CustomTabBarItem.settings)
            
        case .analysis:
            AnalyticsView()
                .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .setupCustomTab(tab: CustomTabBarItem.analysis)
        }
    }
}
