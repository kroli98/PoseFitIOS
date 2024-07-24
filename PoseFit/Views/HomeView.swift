
import AVFoundation
import SwiftUI
import CoreData


struct HomeView: View {
   
    @State var name: String = "Ismeretlen"
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared

  


    var body: some View {
        
        VStack {
            Text("Üdv, \(name)!")
                .font(.largeTitle)
            
           

            WeeklySummaryCardView()
                .frame(maxHeight: 150)
                .padding(.bottom)
            
              

            WorkoutLaunchCardView()
            
           

            Spacer()
        }
        .padding()
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
          
        
            
            navigationCoordinator.isNavigating = false
            
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            do {
                let items = try viewContext.fetch(fetchRequest)
                print(items)
            } catch {
                print("Error fetching data: \(error)")
            }
        }
        .alert(item: $connectivityManager.notificationMessage) { message in
             Alert(title: Text(message.text),
                   dismissButton: .default(Text("Dismiss")))
        }
        .task{
            do{
                let user = try await UserManager.shared.getCurrentUser()
                if let userName = user.name {
                    name = userName
                    return 
                } else {
                    print("User name is nil")
                  
                    return
                }
            }
            catch{
                print("Error fetching current user: \(error)")
            }


        }
        
    }
   
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let navigationCoordinator = NavigationCoordinator()
        ScrollView{
            HomeView()
        }
            .environmentObject(navigationCoordinator)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

    }
}
