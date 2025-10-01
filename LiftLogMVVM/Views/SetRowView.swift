//
//  SetRowView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 7/30/25.
//

import SwiftUI
import SwiftData

struct SetRowView: View {
    @Bindable var exerciseSet: ExerciseSetModel
    private let setIndex: Int
    @Environment(\.modelContext) private var modelContext
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    
    init(exerciseSet: ExerciseSetModel, setIndex: Int) {
        self.exerciseSet = exerciseSet
        self.setIndex = setIndex
    }
    
    var body: some View {
        HStack(spacing: 12) {
            setIndexView
            
            Spacer()
            
            repsXSet
            
            Spacer()
            
            markSet
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(exerciseSet.isCompleted ? .green.opacity(0.1) : .clear)
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss keyboard when tapping outside text fields
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            weightText = exerciseSet.weight == 0 ? "" : exerciseSet.weight.asDecimalWith2Decimals()
            repsText = exerciseSet.reps == 0 ? "" : "\(exerciseSet.reps)"
        }
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    let container = try! ModelContainer(
        for: TemplateModel.self, ExerciseModel.self, ExerciseSetModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    // seed sample data
    let s = ExerciseSetModel(reps: 10, weight: 135)
    ctx.insert(s)
    try? ctx.save()
    
    return NavigationStack {
        SetRowView(exerciseSet: s, setIndex: 1)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

extension SetRowView {
    private var setIndexView: some View {
        // Set index number
        Text("\(setIndex)")
            .foregroundStyle(exerciseSet.isCompleted ? .white : .secondary)
            .fontWeight(.medium)
            .frame(width: 30, height: 30)
            .background(exerciseSet.isCompleted ? .green : .gray.opacity(0.25))
            .cornerRadius(8)
    }
    
    private var repsXSet: some View {
        HStack {
            // Weight
            HStack(spacing: 4) {
                TextField("0", text: $weightText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .fontWeight(.medium)
                    .frame(minWidth: 40, maxWidth: 68)
                    .onChange(of: weightText) {_, newValue in
                        let filtered = filterWeightInput(newValue)
                        if filtered != newValue {
                            weightText = filtered
                        }
                        exerciseSet.weight = Double(filtered) ?? 0
                    }
                
                Text(" lbs")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(.gray.opacity(0.2))
            .cornerRadius(8)
            
            Spacer()
            
            Text("x")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Reps
            HStack(spacing: 4) {
                TextField("0", text: $repsText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .fontWeight(.medium)
                    .frame(minWidth: 30, maxWidth: 50)
                    .onChange(of: repsText) {_, newValue in
                        let filtered = filterRepsInput(newValue)
                        if filtered != newValue {
                            repsText = filtered
                        }
                        exerciseSet.reps = Int(filtered) ?? 0
                    }
                
                Text(" reps")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
    
    private var markSet: some View {
        Button(action: {
            withAnimation(.smooth) {
                exerciseSet.isCompleted.toggle()
            }
        }, label: {
            Image(systemName: "checkmark")
                .foregroundStyle(exerciseSet.isCompleted ? .white : .secondary)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30, height: 30)
                .background(exerciseSet.isCompleted ? .green : .gray.opacity(0.25))
                .cornerRadius(8)
        })
        .buttonStyle(.plain)
    }
    
    private func filterWeightInput(_ input: String) -> String {
            let filtered = input.filter { "0123456789.".contains($0) }
            
            // Ensure only one decimal point
            let components = filtered.components(separatedBy: ".")
            if components.count > 2 {
                return components[0] + "." + components[1]
            }
            
            // Limit to reasonable length (e.g., 6 digits before decimal, 2 after)
            if let dotIndex = filtered.firstIndex(of: ".") {
                let beforeDecimal = String(filtered[..<dotIndex])
                let afterDecimal = String(filtered[filtered.index(after: dotIndex)...])
                
                let limitedBefore = String(beforeDecimal.prefix(6))
                let limitedAfter = String(afterDecimal.prefix(2))
                
                return limitedBefore + "." + limitedAfter
            } else {
                return String(filtered.prefix(6)) // Limit to 6 digits if no decimal
            }
        }
        
    // Helper function to filter reps input (integers only)
    private func filterRepsInput(_ input: String) -> String {
        let filtered = input.filter { "0123456789".contains($0) }
        return String(filtered.prefix(4)) // Limit to 4 digits(should be enough for reps!)
    }
    
}
