//
//  NewExerciseView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/12/25.
//

import SwiftUI
import SwiftData

struct NewExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName = ""
    @State private var selectedBodyPart = ""
    @State private var selectedCategory = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Predefined options
    private let bodyParts = ["Chest", "Back", "Shoulders", "Arms", "Legs", "Core", "Cardio", "Other"]
    private let categories = ["Barbell", "Dumbbell", "Machine", "Cable", "Bodyweight", "Resistance Band", "Other", "Smith Machine",]
    
    var body: some View {
        VStack(spacing: 24) {
            header
                
            // Form
            VStack(spacing: 20) {
                exerciseNameInput
                
                bodyPartSelection
                
                categorySelection
            }
            
            Spacer()
            
            createExerciseButton
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedBodyPart.isEmpty &&
        !selectedCategory.isEmpty
    }
    
    private func createExercise() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            // Fetch all exercises and check manually (simple but works)
            let allExercises = try modelContext.fetch(FetchDescriptor<ExerciseModel>())
            
            // Check for duplicates case-insensitively
            let duplicateExists = allExercises.contains { existingExercise in
                existingExercise.name.lowercased() == trimmedName.lowercased()
            }
            
            if duplicateExists {
                errorMessage = "An exercise with this name already exists."
                showingError = true
                return
            }
            
            // Create new exercise
            let newExercise = ExerciseModel(
                name: trimmedName,
                bodyPart: selectedBodyPart,
                category: selectedCategory
            )
            
            modelContext.insert(newExercise)
            try modelContext.save()
            
            dismiss()
            
        } catch {
            errorMessage = "Failed to create exercise. Please try again."
            showingError = true
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TemplateModel.self, ExerciseModel.self, ExerciseSetModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    
    NavigationStack {
        NewExerciseView()
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

extension NewExerciseView {
    private var header: some View {
        // Header
        VStack(alignment: .leading, spacing: 8) {
            Text("Create New Exercise")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add a custom exercise to your library")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var exerciseNameInput: some View {
        // Exercise Name
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Name")
                .font(.headline)
                .fontWeight(.medium)
            
            TextField("e.g., Incline Dumbbell Press", text: $exerciseName)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.words)
        }
    }
    
    private var bodyPartSelection: some View {
        // Body Part Selection
        VStack(alignment: .leading, spacing: 8) {
            Text("Body Part")
                .font(.headline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100))
            ], spacing: 8) {
                ForEach(bodyParts, id: \.self) { bodyPart in
                    Button(action: {
                        selectedBodyPart = bodyPart
                    }) {
                        Text(bodyPart)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedBodyPart == bodyPart ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(selectedBodyPart == bodyPart ? .blue : .gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var categorySelection: some View {
        // Category Selection
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100))
            ], spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? .green : .gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var createExerciseButton: some View {
        // Create Button
        Button(action: {
            createExercise()
        }) {
            Text("Create Exercise")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? .blue : .gray)
                .cornerRadius(12)
        }
        .disabled(!isFormValid)
    }
}
