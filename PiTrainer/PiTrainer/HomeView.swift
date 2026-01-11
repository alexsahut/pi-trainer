//
//  HomeView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var statsStore = StatsStore()
    @StateObject private var sessionViewModel: SessionViewModel
    
    @State private var showingStats = false
    @State private var showingSession = false
    
    init() {
        let store = StatsStore()
        _statsStore = StateObject(wrappedValue: store)
        _sessionViewModel = StateObject(wrappedValue: SessionViewModel(statsStore: store))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Brand / Title
                VStack(spacing: 8) {
                    Text("π")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(.blue)
                    
                    Text("home.title")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)
                
                // Mode Picker
                VStack(spacing: 12) {
                    Text("home.select_mode")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Picker("home.mode", selection: $sessionViewModel.selectedMode) {
                        Text("home.strict").tag(PracticeEngine.Mode.strict)
                        Text("home.learning").tag(PracticeEngine.Mode.learning)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 40)
                }
                
                // Keypad Layout Picker
                VStack(spacing: 12) {
                    Text("settings.keypad_layout")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Picker("settings.keypad_layout", selection: $statsStore.keypadLayout) {
                        ForEach(KeypadLayout.allCases, id: \.self) { layout in
                            Text(layout.localizedName).tag(layout)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 40)
                }
                
                // Main Actions
                VStack(spacing: 16) {
                    NavigationLink(destination: SessionView(viewModel: sessionViewModel)) {
                        Text("home.start")
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
                    
                    Button(action: { showingStats = true }) {
                        Text("home.stats")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Quick Stats Summary
                if statsStore.globalBestStreak > 0 {
                    VStack(spacing: 4) {
                        Text("home.best_streak")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text("\(statsStore.globalBestStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gold)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStats) {
                StatsView(statsStore: statsStore)
            }
        }
    }
}

#Preview {
    HomeView()
}
