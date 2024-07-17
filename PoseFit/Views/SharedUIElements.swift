//
//  SharedUIElements.swift
//  Shared
//
//  Created by Kiss Roland on 19/04/2024.
//

import Foundation
import SwiftUI
import UIKit

struct SetsView: View {
    let organizedExercisesGroups: [[Exercise]]
    let currentGroup: Int
    let currentExercise: Int
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(0..<organizedExercisesGroups.count, id: \.self) { groupIndex in
                    HStack {
                        ForEach(0..<organizedExercisesGroups[groupIndex].count, id: \.self) { exerciseIndex in
                            let exercise = organizedExercisesGroups[groupIndex][exerciseIndex]
                            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                                .frame(maxHeight: 15, alignment: .bottom)
                                .foregroundColor(exercise.isCompleted ? .green : .gray)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke((groupIndex == currentGroup && exerciseIndex == currentExercise) ? Color.green : Color.clear, lineWidth: 5)
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 0)
                                .frame(maxWidth: .infinity)
                        }
                    }
                #if os(iOS)
                 .background(Color(UIColor.secondarySystemFill))
                 #else
                 .background(Color.secondary)
                 #endif
                 .opacity(0.8)
                 .cornerRadius(10.0)
                }
            }
        }
        #if os(iOS)
        .frame(maxHeight: .infinity, alignment: .bottom)
       
        .padding()
        #endif
    }
}

#Preview {
    SetsView(organizedExercisesGroups: Exercises.groupedSampleExercises, currentGroup: 0, currentExercise: 1)
}
