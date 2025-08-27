//
//  AddExerciseView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/8/25.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    
    @State private var searchText: String = ""
    @State private var selectedBodyPart: String = "Any Body Part"
    @State private var selectedCategory: String = "Any Category"
    @State private var selectedExercises: Set<UUID> = []
    @State private var showingNewExercise: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseModel.name, order: .forward) private var allExercises: [ExerciseModel]
    
    let onExercisesSelected: (([ExerciseModel]) -> Void)?
    init(onExercisesSelected: (([ExerciseModel]) -> Void)? = nil) {
        self.onExercisesSelected = onExercisesSelected
    }
    
    private var filteredExercises: [ExerciseModel] {
        allExercises.filter { exercise in
                // Search text filter
            let matchesSearch = searchText.isEmpty ||
                exercise.name.localizedCaseInsensitiveContains(searchText) ||
                exercise.bodyPart.localizedCaseInsensitiveContains(searchText) ||
                exercise.category.localizedCaseInsensitiveContains(searchText)
                
                // Body part filter
            let matchesBodyPart = selectedBodyPart == "Any Body Part" ||
                    exercise.bodyPart == selectedBodyPart
                
                // Category filter
            let matchesCategory = selectedCategory == "Any Category" ||
                    exercise.category == selectedCategory
                
            return matchesSearch && matchesBodyPart && matchesCategory
        }
    }
    
    private var availableBodyParts: [String] = ["Chest","Legs","Arms","Back","Other",]
    private var availableCategories: [String] = ["Barbell", "Dumbbell", "Machine", "Other",]
    
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
            VStack(spacing: 16) {
                homeHeader
                
                exerciseList
            }
            .padding(.top, 32)
            .sheet(isPresented: $showingNewExercise) {
                NewExerciseView()
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TemplateModel.self, ExerciseModel.self, ExerciseSetModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    
    let exercisesSample = [
        ExerciseModel(name: "Bench Press", bodyPart: "Chest", category: "Barbell"),
        ExerciseModel(name: "Shoulder Press", bodyPart: "Arms", category: "Dumbbell"),
        ExerciseModel(name: "Hack Squat", bodyPart: "Legs", category: "Machine"),
        ExerciseModel(name: "Push Ups", bodyPart: "Chest", category: "Other"),
    ]
    exercisesSample.forEach { ctx.insert($0) }
    try? ctx.save()
    
    return NavigationStack {
        AddExerciseView()
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

extension AddExerciseView {
    private var homeHeader: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("X")
                        .foregroundStyle(.gray.opacity(0.9))
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(width: 30, height: 30)
                        .background(.gray.opacity(0.3))
                        .cornerRadius(8)
                })
                .padding(.trailing)
                
                Button(action: {
                    showingNewExercise = true
                }, label: {
                    Text("New")
                        .foregroundStyle(.blue.opacity(0.9))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                        .frame(height: 30)
                        .background(.blue.opacity(0.3))
                        .cornerRadius(8)
                })
                
                Spacer()
                
                Button(action: {
                    addSelectedExercises()
                }, label: {
                    Text("Add (\(selectedExercises.count))")
                        .foregroundStyle(selectedExercises.isEmpty ? .gray.opacity(0.9) : .green.opacity(0.9))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                        .frame(height: 30)
                        .background(selectedExercises.isEmpty ? .gray.opacity(0.4) : .green.opacity(0.3))
                        .cornerRadius(8)
                })
                .disabled(selectedExercises.isEmpty)
            }
            .padding(.horizontal)
            
            // Custom Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(.gray.opacity(0.15))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Filters
            HStack {
                Menu {
                    ForEach(availableBodyParts, id: \.self) { bodyPart in
                        Button(action: {
                            selectedBodyPart = bodyPart
                        }) {
                            HStack {
                                Text(bodyPart)
                                if selectedBodyPart == bodyPart {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedBodyPart)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(selectedBodyPart == "Any Body Part" ? .gray.opacity(0.9) :  .blue.opacity(0.9))
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .frame(height: 30)
                    .background(selectedBodyPart == "Any Body Part" ? .gray.opacity(0.3) :  .blue.opacity(0.3))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Menu {
                    ForEach(availableCategories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                Text(category)
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedCategory)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(selectedCategory == "Any Category" ? .gray.opacity(0.9) :  .blue.opacity(0.9))
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .frame(height: 30)
                    .background(selectedCategory == "Any Category" ? .gray.opacity(0.3) :  .blue.opacity(0.3))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var exerciseList: some View {
        ScrollView {
            if filteredExercises.isEmpty {
                VStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    
                    Text("No Exercises Found")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    Text("Add new exercises!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRowView(exercise: exercise, isSelected: selectedExercises.contains(exercise.id)) {
                            toggleExerciseSelection(exercise)
                        }
                    }
                }
            }
        }
    }
    
    private func toggleExerciseSelection(_ exercise: ExerciseModel) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }
        
    private func addSelectedExercises() {
        let exercisesToAdd = allExercises.filter { selectedExercises.contains($0.id) }
        onExercisesSelected?(exercisesToAdd)
        dismiss()
    }

}

// Separate view for each exercise row
struct ExerciseRowView: View {
    let exercise: ExerciseModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            // Exercise Information
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(exercise.bodyPart)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(exercise.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
                
            Spacer()
                
            // Selection indicator
            Image(systemName: isSelected ? "checkmark" : "empty")
                .foregroundColor(isSelected ? .green : .gray)
                .font(.title3)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(isSelected ? .green.opacity(0.1) : .clear)
        .onTapGesture {
            onTap()
        }
    
    Divider()
    }
}
