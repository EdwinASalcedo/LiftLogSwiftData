//
//  LiftLogMVVMApp.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 7/30/25.
//

import SwiftUI
import SwiftData

@main
struct LiftLogMVVMApp: App {
    
    //@StateObject private var vm = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .modelContainer(for: [ExerciseModel.self, ExerciseSetModel.self, TemplateModel.self, WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self])
            //.environmentObject(vm)
        }
    }
}
