import SwiftUI
import CoreData
import Charts


struct WeeklyChartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var currentDate = Date()
    @State  var weeklyData: [WeeklyWorkoutData] = []
    @State var currentChartId: Int?
    @State var totalWorkouts = 0
    @State var totalDuration = 0
    @State var weekNumber: Int?

    var body: some View {
      
        VStack {
                   
            Text("Heti edzési időtartamok")
                       .font(.headline)
                     
            
            Text("\(weekNumber ?? 0) .hét")

                   HStack {
                       Button(action: {
                           changeWeek(by: -1)
                       }) {
                           Image(systemName: "chevron.left")
                       }

                       Chart {
                                         ForEach(1...7, id: \.self) { day in
                                             let dayData = weeklyData.first(where: { $0.dayOfWeek == day })
                                             BarMark(
                                                 x: .value("A hét napjai", dayOfWeekString(from: day)),
                                                 y: .value("Időtartam", Double(dayData?.duration ?? 0) / 60.0 )
                                             )
                                         }
                                     }
                                     .chartYAxis {
                                         AxisMarks(preset: .aligned, position: .leading)
                                     }
                          

                       Button(action: {
                           changeWeek(by: 1)
                       }) {
                           Image(systemName: "chevron.right")
                       }
                   }

                   HStack {
                       Text("\(totalWorkouts) edzés")
                       Rectangle()
                           .frame(width: 2)
                           .foregroundColor(.gray)
                           .padding(.horizontal, 10)
                     
                     
                       Text("kb. \(Int(ceil(Double(totalDuration) / 60))) perc")

                     
                   }
                   .frame(maxHeight: 30)
                   .padding(.horizontal,50)
                   .padding(.bottom)
               }
               .onAppear {
                   fetchData(forWeekContaining: currentDate)
                   weekNumber = getWeekNumber
                   
                  
                  
               }
    }
    
    private func getTotalWorkouts() -> Int {
        return weeklyData.reduce(0) { $0 + $1.count }
    }

    private func getTotalDuration() -> Int {
        return weeklyData.compactMap { $0 }.reduce(0) { $0 + $1.duration }
       }
    private func changeWeek(by offset: Int) {
          let calendar = Calendar.current
          if let newDate = calendar.date(byAdding: .weekOfYear, value: offset, to: currentDate) {
              currentDate = newDate.startOfWeek(using: calendar)
              fetchData(forWeekContaining: currentDate)
              totalWorkouts = getTotalWorkouts()
              totalDuration = getTotalDuration()
              weekNumber = getWeekNumber
              
          }
      }
    func dayOfWeekString(from day: Int) -> String {
         let calendar = Calendar.current
         let desiredDate = calendar.date(byAdding: .day, value: day - 1, to: currentDate.startOfWeek(using: calendar))!
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "hu_HU")
         formatter.dateFormat = "EEE"
         return formatter.string(from: desiredDate)
     }

    private func getWeek() -> Date {
        let calendar = Calendar.current
        let currentWeekStart = currentDate.startOfWeek(using: calendar)
     
        return  currentWeekStart
    }

    private func fetchData(forWeekContaining date: Date) {
      
        let weekStart = getWeek()
        weeklyData = []
      

        fetchWorkouts(for: weekStart)
        totalWorkouts = getTotalWorkouts()
           totalDuration = getTotalDuration()
    }

    private func fetchWorkouts(for startDate: Date) {
        var data: [WeeklyWorkoutData] = []

        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!

        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: true)]

        do {
            let results = try viewContext.fetch(fetchRequest)

            for day in 1...7 {
                let dayDate = Calendar.current.date(byAdding: .day, value: day - 1, to: startDate)!
                let workoutsOnDay = results.filter { workout in
                              if let workoutDate = workout.date, workout.workoutToCompletedExercise?.count ?? 0 > 0 {
                                  return Calendar.current.isDate(workoutDate, inSameDayAs: dayDate)
                              }
                              return false
                          }
                
                let totalDuration = workoutsOnDay.reduce(into: 0) { result, workout in
                    if let exercisesSet = workout.workoutToCompletedExercise as? Set<CompletedExercise> {
                        let workoutTotalDuration = exercisesSet.reduce(0) { $0 + Int($1.elapsedExerciseTime) }
                        result += workoutTotalDuration
                    }
                }



                let workoutCount = workoutsOnDay.count

                data.append(WeeklyWorkoutData(dayOfWeek: day, duration: totalDuration, count: workoutCount))
                
                
               

            }
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            do {
                let items = try viewContext.fetch(fetchRequest)
                print(items)
            } catch {
                print("Error fetching data: \(error)")
            }
        } catch {
            print("Error fetching data: \(error)")
        }

        weeklyData = data
    }
    
    var getWeekNumber: Int {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: currentDate)
        return weekOfYear
    }

    


}


struct WeeklyChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyChartView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            
    }
}


extension Date {
    func startOfWeek(using calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
}
