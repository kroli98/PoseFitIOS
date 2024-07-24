//
//  DBExercise.swift
//  PoseFit
//
//  Created by Kiss Roland on 18/07/2024.
//

import Foundation
import FirebaseFirestore

struct DBExercise: Codable {
    @DocumentID var exerciseId: String?
    let name: String
    let equipment: String
    let intensityLevel: String
    let primaryMuscleGroup: String
    let secondaryMuscleGroup: String
    let workoutType: String
    
    enum CodingKeys: String, CodingKey {
        case exerciseId
        case name
        case equipment
        case intensityLevel = "intensity_level"
        case primaryMuscleGroup = "primary_muscle_group"
        case secondaryMuscleGroup = "secondary_muscle_group"
        case workoutType = "workout_type"
    }

}
