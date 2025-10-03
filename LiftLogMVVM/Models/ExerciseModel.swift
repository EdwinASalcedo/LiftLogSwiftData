//
//  ExerciseModel.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/11/25.
//

import Foundation
import SwiftData

@Model
class ExerciseModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var bodyPart: String
    var category: String
    
    // Children
    @Relationship var exerciseSets: [ExerciseSetModel] = []
    
    // optional back pointer to template (one to many)
    @Relationship(inverse: \TemplateModel.exercises) var templates: [TemplateModel] = []
    
    init(name: String, bodyPart: String, category: String) {
        self.name = name
        self.bodyPart = bodyPart
        self.category = category
    }
}
