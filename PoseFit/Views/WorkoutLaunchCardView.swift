//
//  WorkoutLaunchCardView.swift
//  PoseFit
//
//  Created by Kiss Roland on 18/07/2024.
//

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
                    
                      
                    

                      startExerciseButton
                         
                  }
                  .background(Color(UIColor.secondarySystemBackground))
                  .cornerRadius(25)
                  .shadow(radius: 5)
                 
                
                  
                 

            
             
                 
                   NavigationLink(destination: CustomizeWorkoutView(), isActive: $shouldNavigate) {
                       EmptyView()
                   }
               
           
       }

    

    var startExerciseButton: some View {
        Button(action: {
           
                shouldNavigate = true
            
        }) {
            Text("Edzés személyre szabása")
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

#Preview {
    WorkoutLaunchCardView()
}
