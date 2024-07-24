import SwiftUI
import FirebaseAppCheck
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
        
        // let settings = FirestoreSettings()
        // settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        // let db = Firestore.firestore()
        // db.settings = settings
        
        let settings = FirestoreSettings()
        settings.dispatchQueue = DispatchQueue.main
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        settings.isSSLEnabled = true
        let db = Firestore.firestore()
      
        db.settings = settings
        
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
@main
struct PoseGymApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSignInView: Bool = false

    let persistenceController = PersistenceController.shared
    var navigationCoordinator = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationView {
                    CustomTabBar(selectedTab: .home, allCases: CustomTabBarItem.allCases)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(navigationCoordinator)
                        .onAppear {
                            AppDelegate.orientationLock = .portrait
                            
                          
                        }
                        .onDisappear {
                            AppDelegate.orientationLock = .all
                        }
                       
                }
                .task {
                    let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                    self.showSignInView = authUser == nil ? true : false
                }
                .fullScreenCover(isPresented: $showSignInView) {
                    NavigationView {
                        AuthenticationView()
                            .onAppear {
                                AppDelegate.orientationLock = .portrait
                            }
                            .onDisappear {
                                AppDelegate.orientationLock = .all
                            }
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(navigationCoordinator)
                    }
                }
            }
        }
    }
}
