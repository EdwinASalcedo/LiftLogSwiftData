//
//  HistoryView.swift
//  LiftLogMVVM
//
//  Created by Edwin Salcedo on 8/27/25.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack {
            // BACKGROUND
            Color.theme.background
                .ignoresSafeArea()
            
            ScrollView {
                Text("History")
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
