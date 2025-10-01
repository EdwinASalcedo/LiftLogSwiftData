//
//  HistoryView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/27/25.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(sort: \WorkoutSessionModel.endTime, order: .reverse)
    private var completedWorkouts: [WorkoutSessionModel]
    
    var body: some View {
        List {
            ForEach(completedWorkouts.filter { $0.isCompleted && $0.endTime != nil }) { workout in
                NavigationLink(destination: CompletedWorkoutDetailView(workoutSession: workout)) {
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
        .navigationTitle("History")
    }
}

struct WorkoutHistoryRow: View {
    let workout: WorkoutSessionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
//                Text(workout.formattedDuration)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
            }
            
            Text((workout.endTime ?? workout.startTime).formatted(.dateTime.weekday(.wide).month(.abbreviated).day().year()))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(workout.exerciseSessions.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CompletedWorkoutDetailView: View {
    let workoutSession: WorkoutSessionModel
    
    var body: some View {
        ZStack {
            // BACKGROUND
            Color.theme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Workout info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(workoutSession.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text((workoutSession.endTime ?? workoutSession.startTime).formatted(.dateTime.weekday(.wide).month(.abbreviated).day().year()))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
    //                    Text("Duration: \(workoutSession.formattedDuration)")
    //                        .font(.subheadline)
    //                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Exercises
                    LazyVStack(spacing: 12) {
                        ForEach(workoutSession.exerciseSessions) { exerciseSession in
                            CompletedExerciseCard(exerciseSession: exerciseSession)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CompletedExerciseCard: View {
    let exerciseSession: ExerciseSessionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exerciseSession.exerciseName)
                .font(.headline)
                .fontWeight(.medium)
            
            Text("\(exerciseSession.bodyPart) • \(exerciseSession.category)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if exerciseSession.completedSets.isEmpty {
                Text("No sets completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(exerciseSession.completedSets.sorted { $0.setNumber < $1.setNumber }) { set in
                        HStack {
                            Text("Set \(set.setNumber):")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .leading)
                            
                            Text("\(set.weight.formatted(.number.precision(.fractionLength(1)))) lbs × \(set.reps) reps")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    
    // Create sample completed workout
    let workout = WorkoutSessionModel(name: "Push Day", templateName: "Push Day")
    workout.endTime = Date()
    workout.isCompleted = true
    
    let exercise1 = ExerciseSessionModel(exerciseName: "Bench Press", bodyPart: "Chest", category: "Barbell")
    let exercise2 = ExerciseSessionModel(exerciseName: "Shoulder Press", bodyPart: "Arms", category: "Dumbbell")
    
    // Add completed sets
    let sets1 = [
        CompletedSetModel(reps: 10, weight: 135, setNumber: 1),
        CompletedSetModel(reps: 8, weight: 140, setNumber: 2),
        CompletedSetModel(reps: 6, weight: 145, setNumber: 3)
    ]
    
    let sets2 = [
        CompletedSetModel(reps: 12, weight: 50, setNumber: 1),
        CompletedSetModel(reps: 10, weight: 55, setNumber: 2)
    ]
    
    sets1.forEach { set in
        set.exerciseSession = exercise1
        exercise1.completedSets.append(set)
        ctx.insert(set)
    }
    
    sets2.forEach { set in
        set.exerciseSession = exercise2
        exercise2.completedSets.append(set)
        ctx.insert(set)
    }
    
    exercise1.workoutSession = workout
    exercise2.workoutSession = workout
    workout.exerciseSessions = [exercise1, exercise2]
    
    ctx.insert(workout)
    ctx.insert(exercise1)
    ctx.insert(exercise2)
    
    try? ctx.save()
    
    return WorkoutHistoryView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
