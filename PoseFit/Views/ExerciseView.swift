import SwiftUI

struct ExerciseView: View {
    @Binding var exercise: Exercise
    @Binding var isSelected: Bool
    var onExerciseModified: (Exercise) -> Void 

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.title3)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                .onTapGesture {
                    withAnimation {
                        isSelected.toggle()
                    }
                }

            if isSelected {
                VStack(alignment: .center) {
                    if(exercise.name != "Plank") {
                        Text("Ismétlés:")
                        StepperControl(value: Binding(
                            get: { self.exercise.repetition },
                            set: { newValue in
                                self.exercise.repetition = newValue
                                self.onExerciseModified(self.exercise)
                            }
                        ), step: 1...20)
                    } else {
                        Text("Időtartam:")
                        StepperControl(value: Binding(
                            get: { self.exercise.duration ?? 30 },
                            set: { newValue in
                                self.exercise.duration = newValue
                                self.onExerciseModified(self.exercise)
                            }
                        ), step: 1...120)
                    }
                    Text("Sorozat:")
                    StepperControl(value: Binding(
                        get: { self.exercise.set },
                        set: { newValue in
                            self.exercise.set = newValue
                            self.onExerciseModified(self.exercise)
                        }
                    ), step: 1...10)
                }
                .padding(.horizontal,5)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                
            }
            
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.gray).opacity(0.5))
        .frame(maxWidth: .infinity)
    }
}

struct StepperControl: View {
    @Binding var value: Int
    let step: ClosedRange<Int>

    var body: some View {
        HStack {
            Button(action: {
                if value > step.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "minus.circle")
                    .font(.title)
            }

            Text("\(value)")
                .frame(minWidth: 50)

            Button(action: {
                if value < step.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "plus.circle")
                    .font(.title)
            }
        }
    }
}


struct ExerciseView_Previews: PreviewProvider {
    static var testExercise = Exercise(name: "Teszt Gyakorlat", repetition: 10, set: 3, duration: nil, keyPointTriples: [], referenceAngles: [])
    @State static var isSelected = true

    static var previews: some View {
        ExerciseView(exercise: .constant(testExercise), isSelected: .constant(isSelected), onExerciseModified: { _ in })
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

