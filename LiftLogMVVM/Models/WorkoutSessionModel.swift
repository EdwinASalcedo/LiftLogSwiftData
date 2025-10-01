//
//  WorkoutSessionModel.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 9/7/25.
//

import Foundation
import SwiftData

@Model
class WorkoutSessionModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String // "Push Day", "Custom Workout", etc.
    var startTime: Date = Date()
    var endTime: Date?
    var isCompleted: Bool = false
    
    // Optional template reference
    var templateName: String?
    
    // Relationship to completed exercise sessions
    @Relationship(deleteRule: .cascade) var exerciseSessions: [ExerciseSessionModel] = []
    
    init(name: String, templateName: String? = nil) {
        self.name = name
        self.templateName = templateName
    }
    
    // Computed properties
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        guard let duration = duration else { return "In Progress" }
        
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var completionDate: Date {
        return endTime ?? startTime
    }
}

@Model
class ExerciseSessionModel {
    @Attribute(.unique) var id: UUID = UUID()
    var exerciseName: String
    var bodyPart: String
    var category: String
    
    // Relationship to the workout session
    @Relationship(inverse: \WorkoutSessionModel.exerciseSessions) var workoutSession: WorkoutSessionModel?
    
    // Relationship to the completed sets for this exercise in this session
    @Relationship(deleteRule: .cascade) var completedSets: [CompletedSetModel] = []
    
    init(exerciseName: String, bodyPart: String, category: String) {
        self.exerciseName = exerciseName
        self.bodyPart = bodyPart
        self.category = category
    }
}

@Model
class CompletedSetModel {
    @Attribute(.unique) var id: UUID = UUID()
    var reps: Int
    var weight: Double
    var completedAt: Date = Date()
    var setNumber: Int // 1, 2, 3, etc.
    
    // Relationship to the exercise session
    @Relationship(inverse: \ExerciseSessionModel.completedSets) var exerciseSession: ExerciseSessionModel?
    
    init(reps: Int, weight: Double, setNumber: Int) {
        self.reps = reps
        self.weight = weight
        self.setNumber = setNumber
    }
}
