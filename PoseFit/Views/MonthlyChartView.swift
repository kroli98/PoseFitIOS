import SwiftUI
import Charts
import CoreData

struct MonthlyChartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var currentDate = Date()
    @State var workoutData: [MonthlyWorkoutData] = []
    @State var totalWorkouts = 0
    @State var totalDuration = 0
    @State var month: String?
    
    
    var body: some View {
        VStack {
            Text("Havi edzési időtartamok")
                .font(.headline)
            Text("\(month ?? "")")

            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }

                Chart {
                    let daysInMonth = Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let dayData = workoutData.first(where: { $0.dayOfMonth == day })
                        BarMark(
                            x: .value("A hónap napjai", "\(day)"),
                            y: .value("Időtartam",Double(dayData?.duration ?? 0) / 60.0)
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading)
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .automatic) { value in
                        AxisGridLine(centered: true)
                        AxisTick(centered: true)
                        AxisValueLabel() {
                            if let day = value.as(String.self), (Int(day) ?? 0) % 3 == 1 {
                                Text("\(day)")
                                    .font(.system(size: 12))
                                
                                
                            }
                        }
                       
                    }
                }

              

                Button(action: {
                    changeMonth(by: 1)
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
            fetchData(for: currentDate)
            totalWorkouts = getTotalWorkouts()
            totalDuration = getTotalDuration()
            month = formattedMonth
        }
    }

    private func getTotalWorkouts() -> Int {
        return workoutData.reduce(0) { $0 + $1.count }
    }

    private func getTotalDuration() -> Int {
        return workoutData.compactMap { $0 }.reduce(0) { $0 + $1.duration }
       }
    func changeMonth(by offset: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: offset, to: currentDate) {
            currentDate = newDate
            fetchData(for: currentDate)
            totalWorkouts = getTotalWorkouts()
            totalDuration = getTotalDuration()
            month = formattedMonth
        }
    }
    func fetchData(for date: Date) {
        var data: [MonthlyWorkoutData] = []
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND workoutToCompletedExercise.@count > 0", startOfMonth as NSDate, endOfMonth as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: true)]

        do {
            let results = try viewContext.fetch(fetchRequest)
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30

            for day in 1...daysInMonth {
                let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
                let workoutsOnDay = results.filter {
                    calendar.isDate($0.date ?? Date(), inSameDayAs: dayDate)
                }

                let totalDuration = workoutsOnDay.reduce(0) { (result, workout) in
                    result + (workout.workoutToCompletedExercise?.allObjects as? [CompletedExercise] ?? []).reduce(0) { $0 + Int($1.elapsedExerciseTime) }
                }

                let workoutCount = workoutsOnDay.count
                data.append(MonthlyWorkoutData(dayOfMonth: day, duration: totalDuration, count: workoutCount))
            }
        } catch {
            print("Error fetching data: \(error)")
        }

        workoutData = data
    }
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "hu_HU")
        return formatter.string(from: currentDate).capitalized
    }




}

struct MonthlyChartView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyChartView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
