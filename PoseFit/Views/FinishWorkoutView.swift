import SwiftUI

struct FinishWorkoutView: View {
 
    var completedExercises: [ExerciseData]
    @Environment(\.presentationMode) var presentationMode
    @Binding var dismiss: Bool

    private func aggregateExercises() -> [ExerciseData] {
        let groupedExercises = Dictionary(grouping: completedExercises, by: { $0.name })
        return groupedExercises.map { (name, exercises) in
            let totalElapsedTime = exercises.reduce(0) { $0 + $1.elapsedTime }
            let totalRepetitions = exercises.reduce(0) { $0 + $1.repetitions }
            let totalSeries = exercises.reduce(0) { $0 + $1.series }
            let averageCorrectness = exercises.reduce(0.0) { $0 + $1.correctness } / Double(exercises.count)
            return ExerciseData(name: name, elapsedTime: totalElapsedTime, repetitions: totalRepetitions, series: totalSeries, correctness: averageCorrectness)
        }
    }

    var body: some View {
        VStack {
            Text("Befejezted az edzést!")
                .font(.title)
                .padding()
            Spacer()
            Text("Elvégzett gyakorlatok:")
                .font(.title2)
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
            Button("Bezár") {
                presentationMode.wrappedValue.dismiss()
                dismiss = true
            }
            .padding()
            .foregroundColor(Color(UIColor.label))
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray)
            )
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            dismiss = true
        }
    }
}


struct FinishWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleExercises = [
                  ExerciseData(name: "Fekvőtámasz", elapsedTime: 300, repetitions: 10, series: 3, correctness: 95.0),
                  ExerciseData(name: "Guggolás", elapsedTime: 200, repetitions: 15, series: 2, correctness: 90.0),
                  ExerciseData(name: "Felülés", elapsedTime: 150, repetitions: 20, series: 2, correctness: 92.5)
              ]
        FinishWorkoutView( completedExercises: sampleExercises, dismiss: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
