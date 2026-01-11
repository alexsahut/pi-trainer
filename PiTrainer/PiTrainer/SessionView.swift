//
//  SessionView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import SwiftUI

struct SessionView: View {
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header showing stats
            HStack {
                VStack(alignment: .leading) {
                    let modeName = viewModel.selectedMode == .strict ? 
                        String(localized: "home.strict") : 
                        String(localized: "home.learning")
                    
                    Text(String(localized: "session.mode_label \(modeName)"))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(String(localized: "session.streak \(viewModel.engine.currentStreak)"))
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(localized: "session.errors_count \(viewModel.errors)"))
                        .font(.headline)
                        .foregroundColor(viewModel.errors > 0 ? .red : .primary)
                    
                    Text(String(localized: "session.best_streak \(viewModel.bestStreak)"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            
            // Pi Display Area
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        Text("3.")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                        
                        Text(viewModel.typedDigits)
                            .font(.system(size: 48, weight: .medium, design: .monospaced))
                        
                        // Current cursor / pending digit
                        ZStack {
                            Rectangle()
                                .fill(viewModel.showErrorFlash ? Color.red.opacity(0.3) : Color.blue.opacity(0.2))
                                .frame(width: 30, height: 60)
                                .cornerRadius(4)
                            
                            if let expected = viewModel.expectedDigit {
                                Text("\(expected)")
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                                    .foregroundColor(.red)
                            } else {
                                Text("?")
                                    .font(.system(size: 40, weight: .thin, design: .monospaced))
                                    .foregroundColor(.blue)
                            }
                        }
                        .id("cursor")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                }
                .onChange(of: viewModel.typedDigits) { _ in
                    withAnimation {
                        proxy.scrollTo("cursor", anchor: .trailing)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(viewModel.showErrorFlash ? Color.red.opacity(0.1) : Color.clear)
            
            Spacer()
            
            // Keypad
            KeypadView(
                onDigit: { digit in
                    viewModel.processInput(digit)
                },
                onBackspace: {
                    viewModel.backspace()
                },
                onReset: {
                    viewModel.reset()
                },
                onQuit: {
                    viewModel.endSession()
                    dismiss()
                }
            )
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startSession()
        }
    }
}

#Preview {
    NavigationStack {
        SessionView(viewModel: SessionViewModel(statsStore: StatsStore()))
    }
}
