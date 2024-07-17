import SwiftUI
import CoreData

struct WeeklySummaryCardView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var completedExercises: [CompletedExercise] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Ezen a héten")
                    .font(.headline)
                    .bold()
                
                Spacer()
                if(totalWorkoutDuration < 60)
                {
                    Text("\(totalWorkoutDuration) másodperc")
                        .font(.headline)
                }
                else{
                    Text("kb. \(Int(ceil(Double(totalWorkoutDuration)/60))) perc")
                        .font(.headline)
                }
              
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(Date().daysOfWeek, id: \.self) { day in
                   
                    VStack {
                      
                        Circle()
                            .fill(self.hasExercise(on: day) ? Color.green : Color.gray)
                            
                            .frame(height: 20)
                            .overlay{
                                if(self.hasExercise(on: day))
                                {
                                    Image(systemName: "checkmark")
                                        .imageScale(.small)
                                }
                            }
                            
                           
                            
                        Text(dayFormatter.string(from: day))
                    }
                    if day != Date().daysOfWeek.last {
                                Spacer()
                            }
                  
                }
            }
            .padding(.horizontal)
            
        }
        .padding()
     
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(25)
        .shadow(radius: 5)
        .onAppear {
                  fetchCompletedExercises()
              }
    }
    func fetchCompletedExercises() {
           let request: NSFetchRequest<CompletedExercise> = CompletedExercise.fetchRequest()
           request.sortDescriptors = [NSSortDescriptor(keyPath: \CompletedExercise.date, ascending: true)]
           request.predicate = NSPredicate(format: "date >= %@ AND date < %@", Date().startOfWeek as NSDate, Date().endOfWeek as NSDate)

           do {
               completedExercises = try managedObjectContext.fetch(request)
           } catch {
               print("Error fetching data: \(error)")
           }
       }
    
    func hasExercise(on date: Date) -> Bool {
        completedExercises.contains { exercise in
            Calendar.current.isDate(exercise.date ?? Date(), inSameDayAs: date)
        }
    }
    
    var totalWorkoutDuration: Int {
        let totalSeconds = completedExercises.reduce(0) { $0 + (Int($1.elapsedExerciseTime)) }
        return totalSeconds
    }

    let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "hu_HU")
        formatter.dateFormat = "E" 
        return formatter
    }()
}

struct WeeklySummaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklySummaryCardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

extension Date {
    var startOfWeek: Date {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "hu_HU")
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    var endOfWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: self.startOfWeek)!
    }
    
    var daysOfWeek: [Date] {
        return (0...6).map {
            Calendar.current.date(byAdding: .day, value: $0, to: self.startOfWeek)!
        }
    }
}
