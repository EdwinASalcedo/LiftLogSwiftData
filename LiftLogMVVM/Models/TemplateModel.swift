//
//  TemplateModel.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/11/25.
//

import Foundation
import SwiftData

@Model
class TemplateModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    
    @Relationship var exercises: [ExerciseModel] = []
    
    init(name: String) {
        self.name = name
    }
}
