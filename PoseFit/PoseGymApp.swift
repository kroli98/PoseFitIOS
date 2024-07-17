import SwiftUI

@main
struct PoseGymApp: App {
    let persistenceController = PersistenceController.shared
    var navigationCoordinator = NavigationCoordinator()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate



    
  
    var body: some Scene {
        WindowGroup {
            NavigationView{
                if UserDefaults.standard.string(forKey: "UserName") == nil {
                    FirstLaunchView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .onAppear {
                            
                            AppDelegate.orientationLock = .portrait
                        }.onDisappear {
                            AppDelegate.orientationLock = .all
                        }
                        .environmentObject(navigationCoordinator)
                } else {
                    CustomTabBar(selectedTab: .home, allCases: CustomTabBarItem.allCases)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(navigationCoordinator)
                        .onAppear {
                            AppDelegate.orientationLock = .portrait
                        }.onDisappear {
                            AppDelegate.orientationLock = .all
                        }
                }
            }
        }
        
        
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
