import SwiftUI

struct WorkoutDetailView: View {
    var exercises: [CompletedExercise]
    @Environment(\.presentationMode) var presentationMode
    
    private func aggregateExercises() -> [ExerciseData] {
        let groupedExercises = Dictionary(grouping: exercises, by: { $0.name })
        return groupedExercises.map { (name, exercises) in
            let totalElapsedTime = exercises.reduce(0) { $0 + $1.elapsedExerciseTime }
            let totalRepetitions = exercises.reduce(0) { $0 + $1.repetition }
            let totalSeries = exercises.reduce(0) { $0 + $1.series }
            let averageCorrectness = exercises.reduce(0.0) { $0 + $1.correctness } / Double(exercises.count)
            return ExerciseData(name: name ?? "Ismeretlen", elapsedTime: Int(totalElapsedTime), repetitions: Int(totalRepetitions), series: Int(totalSeries), correctness: averageCorrectness)
        }
    }
    var body: some View {
        List(aggregateExercises(), id: \.name) { exercise in
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.title2)
                    .bold()
                if(exercise.name == "Plank")
                {
                    Text("Sorozat: \(exercise.series)")
                }
                else{
                    Text("Ismétlések: \(exercise.repetitions)")
                }
                
                if(exercise.elapsedTime >= 60 )
                {
                    Text("Időtartam: \(exercise.elapsedTime / 60) perc")
                }
                else{
                    Text("Időtartam: \(exercise.elapsedTime)  másodperc")
                }
              
              
                Text("Korrektség: \(exercise.correctness, specifier: "%.2f")%")
            }
        }
        .navigationBarTitle("Gyakorlatok", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
               .navigationBarItems(leading: HStack {
                   Image(systemName: "chevron.left")
                       .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                   Button("Vissza") {
                       self.presentationMode.wrappedValue.dismiss()
                   }
               })
    }
}
