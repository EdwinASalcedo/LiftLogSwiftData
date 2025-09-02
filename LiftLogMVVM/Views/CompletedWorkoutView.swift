//
//  CompletedWorkoutView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/27/25.
//

import SwiftUI
import SwiftData

struct CompletedWorkoutView: View {
    
    let workoutExercises: [ExerciseModel]
    let workoutTitle: String
    let workoutDate: Date
    
    init(exercises: [ExerciseModel], title: String = "Completed Workout", date: Date = Date()) {
        self.workoutExercises = exercises
        self.workoutTitle = title
        self.workoutDate = date
    }
    
    var body: some View {
        HStack {
            Button(action: {
                
            }, label: {
                Text("X")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                    .frame(width: 30, height: 20)
                    .background(.gray.opacity(0.25))
                    .cornerRadius(8)
            })
            
            Spacer()
            
            Text(workoutTitle)
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                    .frame(width: 30, height: 20)
                    .background(.gray.opacity(0.25))
                    .cornerRadius(8)
            })
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        
        HStack {
            Text(workoutDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day().year()))
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(workoutExercises) { exercise in
                    CompletedExerciseView(exercise: exercise)
                }
            }
        }
        
        Spacer()
    }
}

struct CompletedExerciseView: View {
    let exercise: ExerciseModel
    @Query private var sets: [ExerciseSetModel]
    
    init(exercise: ExerciseModel) {
        self.exercise = exercise
        
        let exerciseID = exercise.persistentModelID
        let predicate = #Predicate<ExerciseSetModel> { set in
            set.exercise?.persistentModelID == exerciseID && set.isCompleted == true
        }
        
        self._sets = Query(
            filter: predicate,
            sort: [SortDescriptor(\.createdAt, order: .forward)]
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("\(index + 1)  ")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        
                        Text("\(set.weight.formatted(.number.precision(.fractionLength(1)))) lbs × \(set.reps)")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TemplateModel.self, ExerciseModel.self, ExerciseSetModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    
    let sampleExercises: [ExerciseModel] = [
        ExerciseModel(name: "Iso-Lateral Chest Press", bodyPart: "Chest", category: "Machine"),
        ExerciseModel(name: "Shoulder Press", bodyPart: "Arms", category: "Machine"),
        ExerciseModel(name: "Chest Fly", bodyPart: "Chest", category: "Machine"),
        ExerciseModel(name: "Lateral Raise", bodyPart: "Arms", category: "Cable"),
        ExerciseModel(name: "Cable Crossover", bodyPart: "Chest", category: "Cable"),
    ]
    sampleExercises.forEach { exercise in
        ctx.insert(exercise)
        
        let sampleSets = [
            ExerciseSetModel(isCompleted: true, reps: 10, weight: 135),
            ExerciseSetModel(isCompleted: true, reps: 10, weight: 135),
            ExerciseSetModel(isCompleted: true, reps: 10, weight: 135),
        ]
        
        sampleSets.forEach { set in
            set.exercise = exercise
            ctx.insert(set)
        }
    }
    
    try? ctx.save()
    
    return NavigationStack {
        CompletedWorkoutView(exercises: sampleExercises, title: "Push Day", date: Date())
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
