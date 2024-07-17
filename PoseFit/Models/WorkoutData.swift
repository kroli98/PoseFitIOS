
import Foundation

struct WeeklyWorkoutData: Identifiable {
    let id = UUID()
    let dayOfWeek: Int
    let duration: Int
    let count: Int
}
extension WeeklyWorkoutData {
    static let sampleData: [WeeklyWorkoutData] = [
        WeeklyWorkoutData(dayOfWeek: 1, duration: 120, count: 5),
        WeeklyWorkoutData(dayOfWeek: 2, duration: 180,count: 4),
       
    ]
}

struct MonthlyWorkoutData {
    var dayOfMonth: Int
    var duration: Int
    let count: Int
}
extension MonthlyWorkoutData {
    static let sampleData: [MonthlyWorkoutData] = [
        MonthlyWorkoutData(dayOfMonth: 1, duration: 250,count: 10),
        MonthlyWorkoutData(dayOfMonth: 2, duration: 350, count: 6),
       
    ]
}
