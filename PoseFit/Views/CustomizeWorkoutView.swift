//
//  CustomizeWorkoutView.swift
//  PoseFit
//
//  Created by Kiss Roland on 18/07/2024.
//

import SwiftUI

enum WorkoutType: String, CaseIterable, Identifiable {
    case mixed = "Mixed"
    case strength = "Strength"
    case hiit = "HIIT"
    case warmup = "Warmup"
    case core = "Core"
    
    var id: String { self.rawValue }
}

enum MuscleFocus: String, CaseIterable, Identifiable {
    case shoulders = "Shoulders"
    case core = "Core"
    case chest = "Chest"
    case fullBody = "Full Body"
    
    var id: String { self.rawValue }
}

enum IntensityLevel: String, CaseIterable, Identifiable {
    case mixed = "Mixed"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
       
    var id: String { self.rawValue }
}
enum Equipment: String, CaseIterable, Identifiable {
    case none = "None"
    case medicineBall = "Medicine Ball"
    case pullUpBar = "Pull-Up Bar"
    case kettlebell = "Kettlebell"
    case chair = "Chair"
    case dumbbells = "Dumbbells"
    case box = "Box"
    case jumpRope = "Jump Rope"
    case stabilityBall = "Stability Ball"
    case resistanceBand = "Resistance Band"
    
    var id: String { self.rawValue }
}


struct CustomizeWorkoutView: View {
    @State var selectedWorkoutType: WorkoutType = .mixed
    @State var selectedIntensity: IntensityLevel = .mixed
    @State var exercises: [DBExercise] = []
    @State var selectedMuscles: Set<MuscleFocus> = [MuscleFocus.fullBody]
    @State var selectedEquipments: Set<Equipment> = [Equipment.none]
    @State var filteredExercises: [DBExercise] = []
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Custom Workout")
                    .font(.largeTitle)
                    .padding(.vertical)
                
                VStack(alignment:.leading){
                    Text("Workout type")
                        .font(.title)
                    
                    Picker("Select a workout", selection: $selectedWorkoutType) {
                        ForEach(WorkoutType.allCases) { workout in
                            Text(workout.rawValue).tag(workout)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    .frame(maxHeight: 150)
                    .onChange(of: selectedWorkoutType){
                        filterExercises()
                    }
                }
                
                
                
                VStack(alignment:.leading){
                    Text("Muscle focus")
                        .font(.title)
                    
                    List {
                        ForEach(MuscleFocus.allCases) { muscle in
                            HStack {
                                Text(muscle.rawValue)
                                Spacer()
                                if selectedMuscles.contains(muscle) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(for: muscle)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                
                    .frame(minHeight: 200)
                    
                    .scrollContentBackground(.hidden)
                    .onChange(of: selectedMuscles){
                        filterExercises()
                    }                }
                
                VStack(alignment:.leading){
                    Text("Intensity")
                        .font(.title)
                    
                    Picker("Select intensity", selection: $selectedIntensity) {
                        
                        ForEach(IntensityLevel.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    .frame(maxHeight: 150)
                    .onChange(of: selectedIntensity){
                        filterExercises()
                    }
                }
                
                VStack(alignment:.leading){
                    Text("Equipments")
                        .font(.title)
                
                                           List {
                                               ForEach(Equipment.allCases) { equipment in
                                                   HStack {
                                                       Text(equipment.rawValue)
                                                       Spacer()
                                                       if selectedEquipments.contains(equipment) {
                                                           Image(systemName: "checkmark")
                                                               .foregroundColor(.blue)
                                                       }
                                                   }
                                                   
                                                   .contentShape(Rectangle())
                                                   .onTapGesture {
                                                       toggleSelection(for: equipment)
                                                   }
                                               }
                                           }
                                           .listStyle(PlainListStyle())
                                       
                                           .frame(minHeight: 300)
                                           .onChange(of: selectedEquipments){
                                               filterExercises()
                                           }
                                               
                                        
                    
                    
                }
              
                
              
                Text("Filtered exercises")
                
                List {
                    ForEach(filteredExercises, id: \.exerciseId) { exercise in
                        Text(exercise.name)
                            }
                 
                }
                .listStyle(PlainListStyle())
            
                .frame(minHeight: 200)
                
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Start Workout")
                        .padding()
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                        .shadow(radius: 15)
                }
                .padding()
                
             
                
            }
           
            .padding(.horizontal)
        }
        .task {
            do {
                exercises = try await ExerciseManager.shared.getExercises()
                filteredExercises = exercises
                
            } catch {
                print("Failed to load exercises")
            }
        }
        
    }
        
    
    private func toggleSelection(for muscle: MuscleFocus) {
        
       
        if selectedMuscles.count == MuscleFocus.allCases.count - 2
        {
            selectedMuscles = [.fullBody]
            return
        }
        if selectedMuscles.contains(muscle) {
           
            selectedMuscles.remove(muscle)
        } else {
            if muscle == .fullBody  {
                selectedMuscles = [muscle]
                return
            }
            selectedMuscles.remove(.fullBody)
            selectedMuscles.insert(muscle)
        }
    }
    private func toggleSelection(for equipment: Equipment) {
        
        
        
        if selectedEquipments.contains(equipment) {
            selectedEquipments.remove(equipment)
            
            if selectedEquipments.isEmpty {
                selectedEquipments = [.none]
                      
            }
        }
        else {
            if equipment == .none  {
                selectedEquipments = [equipment]
                      
            }
            else{
                selectedEquipments.remove(.none)
                        
            }
            selectedEquipments.insert(equipment)
        }
    }
    private func filterExercises() {
            filteredExercises = exercises.filter { exercise in
                let matchesWorkout = exercise.workoutType == selectedWorkoutType.rawValue || selectedWorkoutType.rawValue == WorkoutType.mixed.rawValue
                let matchesIntensity = exercise.intensityLevel == selectedIntensity.rawValue || selectedIntensity.rawValue == IntensityLevel.mixed.rawValue
                let matchesPrimaryMuscle = selectedMuscles.isEmpty || selectedMuscles.contains(where: { $0.rawValue == exercise.primaryMuscleGroup }) || selectedMuscles.contains(.fullBody)
                let matchesSecondaryMuscle = selectedMuscles.isEmpty || selectedMuscles.contains(where: { $0.rawValue == exercise.secondaryMuscleGroup })
                let matchesEquipment = selectedEquipments.contains(where: { $0.rawValue == exercise.equipment })
            
                return matchesWorkout && matchesIntensity && (matchesPrimaryMuscle || matchesSecondaryMuscle) && matchesEquipment
            }
        }
}

struct CustomizeWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeWorkoutView()
    }
}
