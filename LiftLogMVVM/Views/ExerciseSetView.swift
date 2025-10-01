//
//  ExerciseSetView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/8/25.
//

import SwiftUI
import SwiftData

struct ExerciseSetView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var exercise: ExerciseModel // SwiftData models are observable
    @Query private var sets: [ExerciseSetModel]
    
    // Callback for exercise removal within HomeView
    let onExerciseRemoved: ((ExerciseModel) -> Void)?
    
    init(exercise: ExerciseModel, onExerciseRemoved: ((ExerciseModel) -> Void)? = nil) {
        self.exercise = exercise
        self.onExerciseRemoved = onExerciseRemoved
        
        let exerciseID = exercise.persistentModelID
        let predicate = #Predicate<ExerciseSetModel> { set in
            set.exercise?.persistentModelID == exerciseID
        }
        
        self._sets = Query(
            filter: predicate,
            sort: [SortDescriptor(\.createdAt, order: .forward)]
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .foregroundStyle(.primary)
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                Menu {
                    Button(action: {
                        // Remove this current exercise from the workout
                        removeExercise()
                    }, label: {
                        Image(systemName: "trash")
                        Text("Remove Exercise")
                            .foregroundStyle(.red)
                            .font(.caption)
                    })
                    
                    Button(action: {
                        // Replace this workout by showing the AddExerciseView sheet (only allow 1 exercise to be selected)
                    }, label: {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Replace Exercise")
                    })
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .frame(width: 30, height: 20)
                        .background(.gray.opacity(0.25))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            
            List {
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, eSet in
                    SetRowView(exerciseSet: eSet, setIndex: index + 1)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .onDelete(perform: deleteSets)
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .frame(height: CGFloat(sets.count * 52))
            
            Button(action: {
                addSets()
            }, label: {
                Text("+ Add Set")
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 24)
                    .background(.gray.opacity(0.25))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
            })
        }
        .padding(.vertical, 16)
        .cornerRadius(16)
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss keyboard when tapping outside text fields
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TemplateModel.self, ExerciseModel.self, ExerciseSetModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    // seed sample data
    let e = ExerciseModel(name: "Bench Press", bodyPart: "Chest", category: "Barbell")
    ctx.insert(e)
    let s = ExerciseSetModel(reps: 10, weight: 135)
    ctx.insert(s)
    s.exercise = e
    try? ctx.save()
    
    return NavigationStack {
        ExerciseSetView(exercise: e)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

extension ExerciseSetView {
    
    private func removeExercise() {
        // Delete all sets associated with this exercise
        for set in sets {
            modelContext.delete(set)
        }
        
        // Call parent callback to remove from workout
        onExerciseRemoved?(exercise)
        
        do {
            try modelContext.save()
            print("Exercise and sets removed successfully")
        } catch {
            print("Failed to remove exercise: \(error)")
        }
    }
    
    private func addSets() {
        withAnimation(.smooth) {
            let newSet = ExerciseSetModel(reps: 0, weight: 0)
            newSet.exercise = exercise
            modelContext.insert(newSet)
            
            do {
                try modelContext.save()
                print("Set added successfully")
            } catch {
                print("Failed to save: \(error)")
            }
        }
    }
    
    private func deleteSets(at offsets: IndexSet) {
        withAnimation(.smooth) {
            for index in offsets {
                let setToDelete = sets[index]
                modelContext.delete(setToDelete)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete set: \(error.localizedDescription)")
            }
        }
    }
}
