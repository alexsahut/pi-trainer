//
//  LearningHomeView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import SwiftUI

struct LearningHomeView: View {
    @StateObject private var learningStore = LearningStore()
    @StateObject private var statsStore = StatsStore() // To get selected constant
    
    @State private var sessionViewModel: LearningSessionViewModel?
    @State private var showingSession = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                     Text(statsStore.selectedConstant.symbol)
                        .font(.system(size: 60, weight: .thin))
                        .foregroundColor(.blue)
                    
                    Text("learning.today_plan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)
                
                // Dashboard Cards
                let constant = statsStore.selectedConstant
                let state = learningStore.state(for: constant)
                let due = learningStore.dueChunks(for: constant, limit: state.dailyReviewLimit).count
                let newCount = state.dailyNewChunks // Simplification for V1 display
                
                HStack(spacing: 20) {
                    // Due Card
                    VStack {
                        Text("\(due)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.orange)
                        Text(due == 1 ? "Review" : "Reviews") // Needs Localization? Using formatted string below
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                    
                    // New Card
                    VStack {
                        Text("\(newCount)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                        Text("New")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                // Start Button
                Button(action: {
                    startSession()
                }) {
                    Text("learning.start_session")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .fullScreenCover(item: $sessionViewModel) { viewModel in
            LearningSessionView(viewModel: viewModel)
        }
    }
    
    private func startSession() {
        let vm = LearningSessionViewModel(learningStore: learningStore, constant: statsStore.selectedConstant)
        // Initialize flow
        vm.startSession()
        self.sessionViewModel = vm
    }
}

// Helper for sheet
extension LearningSessionViewModel: Identifiable {
    // We can use ObjectIdentifier as ID for the sheet item
    var id: ObjectIdentifier { ObjectIdentifier(self) }
}
