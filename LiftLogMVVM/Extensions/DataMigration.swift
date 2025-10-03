//
//  DataMigration.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 10/2/25.
//

import Foundation
import Swift
import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [ExerciseV1.self, TemplateV1.self, ExerciseSetModel.self, WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self]
    }
    
    @Model
    class ExerciseV1 {
        @Attribute(.unique) var id: UUID = UUID()
        var name: String
        var bodyPart: String
        var category: String
        
        @Relationship var exerciseSets: [ExerciseSetModel] = []
        @Relationship(inverse: \TemplateV1.exercises) var template: TemplateV1? // OLD: one-to-many
        
        init(name: String, bodyPart: String, category: String) {
            self.name = name
            self.bodyPart = bodyPart
            self.category = category
        }
    }
    
    @Model
    class TemplateV1 {
        @Attribute(.unique) var id: UUID = UUID()
        var name: String
        @Relationship var exercises: [ExerciseV1] = []
        
        init(name: String) {
            self.name = name
        }
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [ExerciseModel.self, TemplateModel.self, ExerciseSetModel.self, WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self]
    }
}

// MARK: - Migration Plan

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: { context in
            print("Starting migration from V1 to V2...")
            
            // Fetch all old exercises with their template relationships
            let oldExercises = try context.fetch(FetchDescriptor<SchemaV1.ExerciseV1>())
            let oldTemplates = try context.fetch(FetchDescriptor<SchemaV1.TemplateV1>())
            
            print("Found \(oldExercises.count) exercises and \(oldTemplates.count) templates to migrate")
        },
        didMigrate: { context in
            print("Migration from V1 to V2 completed successfully!")
        }
    )
}
