import SwiftUI
import CoreData
import Charts
struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
 
    @State private var selectedTimeframe: Timeframe = .week
    @State var date = Date()
    

    enum Timeframe: String, CaseIterable, Identifiable {
        case week = "Hét"
        case month = "Hónap"
        var id: String { self.rawValue }
    }
    

    var body: some View {
       
         
                
                VStack {
                    
                    Text("Áttekintés")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Picker("", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .padding()
                    
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    if selectedTimeframe == .week {
                        
                        VStack{
                            WeeklyChartView()
                                .padding()
                              
                           
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .mask(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                        .padding()
                        
                    } else {
                        VStack {
                               MonthlyChartView()
                                   .padding()
                               
                          
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .mask(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
                        .padding()
                    }
                    
                    Text("Edzési napló")
                        .font(.title)
                    WorkoutHistoryView()
                        .environment(\.managedObjectContext, viewContext)
                        .frame( maxWidth: .infinity)
                        .cornerRadius(25.0)
                    
                }
              
                .ignoresSafeArea(.all, edges: .bottom)
                .padding(.top)
            
        

       
    }

 
    
 

    
}



struct WorkoutHistoryView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.managedObjectContext) private var viewContext
    @State private var completedExercises: [CompletedExercise] = []
    @State private var isDetailViewActive = false
    @State private var selectedExercises: [CompletedExercise] = []
    var groupedExercises: [Date: [CompletedExercise]] {
        Dictionary(grouping: completedExercises, by: { $0.date ?? Date() })
    }
  

    var body: some View {
       
            VStack(spacing: 10) {
                ForEach(groupedExercises.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Saját testsúlyos edzés")
                                    .font(.headline)
                                Text("\(date, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                let totalDuration = (groupedExercises[date]?.reduce(0) { $0 + Int($1.elapsedExerciseTime) } ?? 0)
                                if(totalDuration >= 60 )
                                {
                                    Text("kb. \(Int(ceil(Double(totalDuration) / 60))) perc")
                                        .font(.headline)
                                }
                                else{
                                    Text("\(totalDuration) másodperc")
                                        .font(.headline)
                                }
                                   
                            }
                            Button(action: {
                                self.selectedExercises = groupedExercises[date] ?? []
                                
                                self.isDetailViewActive = true
                                navigationCoordinator.isNavigating = true

                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .onAppear {
                      fetchCompletedExercises()
                navigationCoordinator.isNavigating = false
                  }
           
           

            NavigationLink(destination: WorkoutDetailView(exercises: selectedExercises), isActive: $isDetailViewActive) {
                EmptyView()
            }
        
    }
    private func fetchCompletedExercises() {
         let fetchRequest: NSFetchRequest<CompletedExercise> = CompletedExercise.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CompletedExercise.date, ascending: false)]

         do {
             completedExercises = try viewContext.fetch(fetchRequest)
         } catch {
             print("Error fetching completed exercises: \(error)")
         }
     }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.locale = Locale(identifier: "hu_HU")
    formatter.dateFormat = "yyyy MMM dd"
    return formatter
}()





struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            AnalyticsView()
        }
            .environmentObject(NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
           
    }
}


