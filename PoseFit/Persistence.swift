import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
      
        for _ in 0..<4 {
            let viewContext = controller.container.viewContext
            let workout = Workout(context: viewContext)
            workout.date = generateRandomDateThisWeek()
            
            for _ in 0..<10 {
                let newItem = CompletedExercise(context: viewContext)
                newItem.date = workout.date
                newItem.name = "Exercise \(Int.random(in: 1...5))"
                newItem.repetition = Int32.random(in: 5...20)
                newItem.series = Int32.random(in: 1...5)
                newItem.correctness = Double.random(in: 0.0...100.0)
                newItem.elapsedExerciseTime = Int32.random(in: 60...160)
                
                workout.addToWorkoutToCompletedExercise(newItem)
                
                do {
                    try viewContext.save()
                } catch {
                    fatalError("Unresolved error \(error)")
                }
            }
        }
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PoseGym")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

   
    static func generateRandomDateThisWeek() -> Date {
        let today = Date()
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: today)
        let daysOffset = Int.random(in: 1...7) - weekDay
        let randomDateThisWeek = calendar.date(byAdding: .day, value: daysOffset, to: today)!
        return randomDateThisWeek
    }
}
