import SwiftUI

struct WorkoutLaunchCardView: View {
   
    @State var selectedExercises: [Exercise] = []
    @State private var shouldNavigate: Bool = false
    @State var exercises: [Exercise] = Exercises.validExercises
    @State var organizedExercisesGroups: [[Exercise]]?
    
    let columns = [
         GridItem(.flexible()),
         GridItem(.flexible())
     ]
    
    var body: some View {
     
                  VStack(spacing: 20) {
                      Text("Válaszd ki a gyakorlatokat")
                          .font(.title2)
                          .padding(.top)
                      LazyVGrid(columns: columns, spacing: 10) {
                          ForEach(exercises.indices, id: \.self) { index in
                              ExerciseView(
                                  exercise: $exercises[index],
                                  isSelected: Binding<Bool>(
                                      get: { self.selectedExercises.contains(where: { $0.id == exercises[index].id }) },
                                      set: { newValue in
                                          toggleSelection(for: exercises[index])
                                      }
                                  ),   onExerciseModified: { modifiedExercise in
                                      self.updateSelectedExercise(modifiedExercise)
                                  }
                              )
                          }
                      }
                    

                      startExerciseButton
                         
                  }
                  .background(Color(UIColor.secondarySystemBackground))
                  .cornerRadius(25)
                  .shadow(radius: 5)
                 
                
                  
                 

            
               if let groups = organizedExercisesGroups {
                 
                   NavigationLink(destination: InWorkoutView(organizedExercisesGroups: groups), isActive: $shouldNavigate) {
                       EmptyView()
                   }
               }
           
       }

    

    var startExerciseButton: some View {
        Button(action: {
            if !selectedExercises.isEmpty {
                organizedExercisesGroups = organizedExercises()
              
                shouldNavigate = true
            }
        }) {
            Text("Edzés indítása")
                .padding()
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                .shadow(radius: 15)
        }
    }

    func toggleSelection(for exercise: Exercise) {
       
        if selectedExercises.contains(where: { $0.name == exercise.name }) {
            selectedExercises.removeAll { $0.name == exercise.name }
        } else {
            selectedExercises.append(exercise)
        }
    }

    func updateSelectedExercise(_ modifiedExercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.name == modifiedExercise.name }) {
            selectedExercises[index] = modifiedExercise
           
        }
        print("Módosítva")
    }
 

    func organizedExercises() -> [[Exercise]] {
        var groups: [[Exercise]] = []
        
        let maxSets = selectedExercises.map { $0.set }.max() ?? 0
        
        for set in 1...maxSets {
            var currentGroup: [Exercise] = []
            for exercise in selectedExercises {
                
                if set <= exercise.set && !currentGroup.contains(where: { $0.name == exercise.name }) {
                    let newExercise = Exercise(name: exercise.name, repetition: exercise.repetition, set: 1, duration: exercise.duration, keyPointTriples: exercise.keyPointTriples, referenceAngles: exercise.referenceAngles)
                  
                    currentGroup.append(newExercise)
                    print(newExercise.set)
                }
            }
            groups.append(currentGroup)
        }
     
        return groups
    }

  
}

struct WorkoutLaunchCardView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutLaunchCardView()
    }
}
