//
//  ExerciseSetModel.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/11/25.
//

import Foundation
import SwiftData

@Model
class ExerciseSetModel {
    @Attribute(.unique) var id: UUID = UUID()
    var createdAt: Date = Date()
    var isCompleted: Bool = false
    var reps: Int = 0
    var weight: Double = 0
    
    // inverse relationship to Exercise
    @Relationship(inverse: \ExerciseModel.exerciseSets) var exercise: ExerciseModel?
    
    init(isCompleted: Bool = false, reps: Int = 0, weight: Double = 0) {
        self.isCompleted = isCompleted
        self.reps = reps
        self.weight = weight
    }
}
