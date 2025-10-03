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
    @State private var showingDataResetAlert = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .modelContainer(modelContainer)
            .alert("Data Update Required", isPresented: $showingDataResetAlert) {
                Button("Reset Data", role: .destructive) {
                    resetAppData()
                }
                Button("Cancel", role: .cancel) {
                    // Exit the app - user can try again
                    exit(0)
                }
            } message: {
                Text("The app has been updated with improved template sharing. This requires resetting your data. Your exercise library will be preserved, but templates and workout history will need to be recreated.")
            }
        }
    }
    
    private var modelContainer: ModelContainer {
        do {
            // Try to create container with just the current models (no migration)
            let container = try ModelContainer(
                for: ExerciseModel.self, ExerciseSetModel.self, TemplateModel.self,
                     WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self
            )
            print("✅ SwiftData container initialized successfully")
            return container
        } catch {
            print("❌ Failed to create container: \(error)")
            
            // Show alert to user about data reset
            DispatchQueue.main.async {
                showingDataResetAlert = true
            }
            
            // Return a temporary in-memory container to prevent crash
            do {
                let tempContainer = try ModelContainer(
                    for: ExerciseModel.self, ExerciseSetModel.self, TemplateModel.self,
                         WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
                print("⚠️ Created temporary in-memory container")
                return tempContainer
            } catch {
                fatalError("Could not create temporary ModelContainer: \(error)")
            }
        }
    }
    
    private func resetAppData() {
        // Clear the persistent store by removing the default store URL
        do {
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            if FileManager.default.fileExists(atPath: url.path()) {
                try FileManager.default.removeItem(at: url)
                print("✅ Cleared persistent store")
            }
        } catch {
            print("❌ Failed to clear store: \(error)")
        }
        
        // Restart the app (user needs to manually restart)
        exit(0)
    }
}
