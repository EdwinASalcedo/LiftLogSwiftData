//
//  HomeView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 7/30/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseModel.name, order: .forward) private var exercises: [ExerciseModel]
    @Query(sort: \TemplateModel.name, order: .forward) private var templates: [TemplateModel]
    @Query private var allSets: [ExerciseSetModel]
    
    @State private var isWorkoutInProgress: Bool = false
    @State private var workoutExercises: [ExerciseModel] = []
    @State private var showingAddExercise: Bool = false
    @State private var currentTemplate: TemplateModel? = nil
    @State private var workoutTitle: String = "Start Workout"
    @State private var showingFinishAlert: Bool = false
    @State private var showingSaveTemplateAlert: Bool = false
    @State private var showingCancelAlert: Bool = false
    @State private var workoutStartTime = Date()
    @State private var showingHistory: Bool = false
    @State private var templateName: String = ""
    
    var body: some View {
        ZStack {
            // BACKGROUND
            Color.theme.background
                .ignoresSafeArea()
            
            // CONTENT
            VStack {
                homeHeader
                
                if isWorkoutInProgress {
                    workoutInProgress
                } else {
                    emptyWorkoutView
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            NavigationStack {
                AddExerciseView { selectedExercises in
                    addExercisesToWorkout(selectedExercises)
                }
            }
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack {
                WorkoutHistoryView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert("Finish Workout?", isPresented: $showingFinishAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Finish") {
                //saveAndFinishWorkout()
                templateName = workoutTitle
                showingSaveTemplateAlert = true
            }
        } message: {
            Text("Great job! Your workout will be saved to your history.")
        }
        .alert("Save as Template?", isPresented: $showingSaveTemplateAlert) {
            TextField("Template Name", text: $templateName)
            Button("No thanks!", role: .cancel) {
                saveAndFinishWorkout()
                templateName = ""
            }
            Button("Save as Template") {
                saveAndCreate()
                templateName = ""
            }
        } message: {
            Text("Save this workout as a template so you can perform it again in the future")
        }
        .alert("Cancel Workout", isPresented: $showingCancelAlert) {
            Button("Resume", role: .cancel) {}
            Button("Cancel Workout", role: .destructive) {
                discardAndCancelWorkout()
            }
        } message: {
            Text("Are you sure you want to cancel this workout? All progress will be lost.")
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TemplateModel.self, ExerciseModel.self, ExerciseSetModel.self, WorkoutSessionModel.self, ExerciseSessionModel.self, CompletedSetModel.self,
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
    
    let sampleTemplates: [TemplateModel] = [
        TemplateModel(name: "Sample Push Day")
    ]
    
    sampleTemplates[0].exercises = sampleExercises
    sampleTemplates.forEach { ctx.insert($0) }
    try? ctx.save()
    
    return NavigationStack {
        HomeView()
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

extension HomeView {
    
    private var homeHeader: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack {
                    Text(workoutTitle)
                        .font(.headline)
                        .fontWeight(.heavy)
                    
                    // Template Selection
                    Menu {
                        Button("Start Empty Workout") {
                            startNewWorkout()
                        }
                        
                        if !templates.isEmpty {
                            Divider()
                            
                            ForEach(templates) { template in
                                Button(template.name) {
                                    // In case user started workout but switched mid way through
                                    discardAndCancelWorkout()
                                    startNewWorkoutFromTemplate(template)
                                }
                            }
                        } else {
                            Button("No templates available") {
                                
                            }
                            .disabled(true)
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.secondary)
                            //.background(.red)
                    }
                    .menuStyle(.button)
                    //.buttonStyle(.plain)
                    .fixedSize()
                }
                
                HStack {
                    Button(action: {
                        showingHistory = true
                    }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(Date().formatted(date: .abbreviated, time: .omitted))")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            if isWorkoutInProgress {
                Button(action: {
                    showingFinishAlert = true
                }, label: {
                    Text("Finish")
                        .foregroundStyle(allSetsCompleted ? .green.opacity(0.9) : .gray.opacity(0.9))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(allSetsCompleted ? .green.opacity(0.3) : .gray.opacity(0.3))
                        .cornerRadius(8)
                })
                .disabled(!allSetsCompleted)
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
    
    private var emptyWorkoutView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.gray.opacity(0.6))
                
                Text("Ready to start your workout?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Begin by starting a new workout or choosing from your templates")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            VStack {
                Button(action: {
                    startNewWorkout()
                }, label: {
                    Text("Start Empty Workout")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                })
            }
        }
    }
    
    private var workoutInProgress: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(workoutExercises) { exercise in
                    ExerciseSetView(exercise: exercise) { exerciseToRemove in
                        removeExerciseFromWorkout(exerciseToRemove)
                    }
                }
                
                addExerciseButton
                
                cancelWorkoutButton
            }
        }
    }
    
    private var addExerciseButton: some View {
        Button(action: {
            showingAddExercise = true
        }, label: {
            Text("Add Exercise")
                .foregroundStyle(.blue.opacity(0.9))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(.blue.opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 16)
        })
        .padding(.top, 32)
    }
    
    private var cancelWorkoutButton: some View {
        Button(action: {
            showingCancelAlert = true
        }, label: {
            Text("Cancel Workout")
                .foregroundStyle(.red.opacity(0.9))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(.red.opacity(0.3))
                .cornerRadius(8)
                .padding(.horizontal, 16)
        })
        .padding(.vertical, 16)
    }
    
    // MARK: Computed Properties
    
    private var allSetsCompleted: Bool {
        let currentWorkoutSets = currentWorkoutSets
        return !currentWorkoutSets.isEmpty && currentWorkoutSets.allSatisfy { $0.isCompleted }
    }
    
    private var currentWorkoutSets: [ExerciseSetModel] {
        let workoutExerciseIds = Set(workoutExercises.map{ $0.id })
        return allSets.filter { set in
            guard let exerciseId = set.exercise?.id else { return false }
            return workoutExerciseIds.contains(exerciseId)
        }
    }
    
    // MARK: Functions
    
    private func startNewWorkout() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isWorkoutInProgress = true
            workoutExercises = []
            currentTemplate = nil
            workoutTitle = "Current Workout"
        }
    }
    
    private func startNewWorkoutFromTemplate(_ template: TemplateModel) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isWorkoutInProgress = true
            workoutExercises = template.exercises
            currentTemplate = template
            workoutTitle = template.name
            
            populateExercisesWithPreviousSets()
        }
    }
    
    private func populateExercisesWithPreviousSets() {
        guard let template = currentTemplate else { return }
        
        for exercise in workoutExercises {
            do {
                let allSets = try modelContext.fetch(FetchDescriptor<ExerciseSetModel>(
                    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                ))
                
                let exerciseSets = allSets.filter { set in
                    set.exercise?.id == exercise.id
                }
                
                let setsToAdd = Array(exerciseSets.prefix(3))
                
                for oldSet in setsToAdd {
                    let newSet = ExerciseSetModel(
                        isCompleted: false,
                        reps: oldSet.reps,
                        weight: oldSet.weight,
                    )
                    newSet.exercise = exercise
                    modelContext.insert(newSet)
                }
                
                try modelContext.save()
            } catch {
                print("Error loading previous sets for \(exercise.name): \(error)")
            }
        }
    }
    
    private func createTemplateFromWorkout() {
        guard !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Template name cannot be empty")
            return
        }
            
        do {
            // Create new template with user-provided name
            let newTemplate = TemplateModel(name: templateName.trimmingCharacters(in: .whitespacesAndNewlines))
            
            newTemplate.exercises = workoutExercises
            
            modelContext.insert(newTemplate)
            try modelContext.save()
            
            print("Template '\(templateName)' created successfully with \(workoutExercises.count) exercises!")
            
        } catch {
            print("Error creating template: \(error)")
        }
    }
    
    private func saveAndFinishWorkout() {
        do {
            // Create workout session
            let workoutSession = WorkoutSessionModel(
                name: workoutTitle,
                templateName: currentTemplate?.name
            )
            
            // Set the start time from when workout began
            workoutSession.startTime = workoutStartTime
            
            workoutSession.endTime = Date()
            workoutSession.isCompleted = true
            
            // Create exercise sessions for each exercise in the workout
            for exercise in workoutExercises {
                let exerciseSession = ExerciseSessionModel(
                    exerciseName: exercise.name,
                    bodyPart: exercise.bodyPart,
                    category: exercise.category
                )
                
                // Get completed sets for this exercise
                let completedSetsForExercise = currentWorkoutSets.filter { set in
                    set.exercise?.id == exercise.id && set.isCompleted == true
                }.sorted { $0.createdAt < $1.createdAt }
                
                // Create completed set records
                for (index, set) in completedSetsForExercise.enumerated() {
                    let completedSet = CompletedSetModel(
                        reps: set.reps,
                        weight: set.weight,
                        setNumber: index + 1
                    )
                    completedSet.exerciseSession = exerciseSession
                    exerciseSession.completedSets.append(completedSet)
                    modelContext.insert(completedSet)
                }
                    
                exerciseSession.workoutSession = workoutSession
                workoutSession.exerciseSessions.append(exerciseSession)
                modelContext.insert(exerciseSession)
            }
            
            modelContext.insert(workoutSession)
        
            // Clean up temporary workout data
            let setsToDelete = currentWorkoutSets
            for set in setsToDelete {
                modelContext.delete(set)
            }
            
            try modelContext.save()
            
            // Reset to empty state
            withAnimation(.easeInOut(duration: 0.3)) {
                isWorkoutInProgress = false
                workoutExercises = []
                currentTemplate = nil
                workoutTitle = "Start Workout"
                workoutStartTime = Date()
            }
            
            print("Workout saved to history successfully! Duration: \(workoutSession.formattedDuration)")
            
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func saveAndCreate() {
        createTemplateFromWorkout()
        saveAndFinishWorkout()
    }
    
    private func discardAndCancelWorkout() {
        let setsToDelete = currentWorkoutSets
        for set in setsToDelete {
            modelContext.delete(set)
        }
        
        do {
            try modelContext.save()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isWorkoutInProgress = false
                workoutExercises = []
                currentTemplate = nil
                workoutTitle = "Start Workout"
            }
        } catch {
            print("Error discarding workout data: \(error)")
        }
    }
    
    private func addExercisesToWorkout(_ exercises: [ExerciseModel]) {
        withAnimation(.easeInOut(duration: 0.3)) {
            workoutExercises.append(contentsOf: exercises)
        }
    }
    
    private func removeExerciseFromWorkout(_ exercise: ExerciseModel) {
        workoutExercises.removeAll { $0.id == exercise.id }
    }
}
