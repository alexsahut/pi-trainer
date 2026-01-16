//
//  LearningSessionView.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import SwiftUI

struct LearningSessionView: View {
    @ObservedObject var viewModel: LearningSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    // Using the same keypad layout preference
    @StateObject private var statsStore = StatsStore() // Just for preference reading
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding()
                
                Spacer()
                
                Text(viewModel.itemsReviewedCount > 0 ? "\(viewModel.itemsReviewedCount)" : "")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Spacer()
            
            // Content based on Phase
            switch viewModel.phase {
            case .overview:
                // Should not happen as startSession is called immediately? 
                // Logic in LearningHomeView will handle start.
                // But if we are here, show loading or start.
                ProgressView()
                
            case .encoding:
                encodingView
                
            case .testing:
                testingView
                
            case .feedback:
                feedbackView
                
            case .summary:
                summaryView
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var encodingView: some View {
        VStack(spacing: 30) {
            Text("learning.memorize_this")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let item = viewModel.currentItem {
                Text(formatDigits(item.digits))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                viewModel.encodingDone()
            }) {
                Text("learning.ready_button")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(30)
            }
        }
    }
    
    private var testingView: some View {
        VStack(spacing: 20) {
            Text("learning.test_title")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Display typed digits + placeholders or visual cues
            HStack(spacing: 4) {
                if let item = viewModel.currentItem {
                    ForEach(0..<item.digits.count, id: \.self) { index in
                        let char = index < viewModel.currentInput.count
                            ? String(viewModel.currentInput[viewModel.currentInput.index(viewModel.currentInput.startIndex, offsetBy: index)])
                            : "•"
                        
                        Text(char)
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(index < viewModel.currentInput.count ? .primary : .gray.opacity(0.3))
                    }
                }
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.showErrorFlash ? Color.red.opacity(0.3) : Color.clear)
            )
            
            if let revealed = viewModel.revealedDigits {
                Text(revealed)
                    .font(.title)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            Spacer()
            
            KeypadView(
                layout: statsStore.keypadLayout,
                onDigit: { digit in
                    viewModel.processDigitInput(digit)
                },
                onBackspace: {
                    viewModel.backspace()
                },
                onReset: {
                    // Start over current item?
                    // For now, minimal action: just clear input
                    while !viewModel.currentInput.isEmpty {
                        viewModel.backspace()
                    }
                },
                onQuit: {
                    dismiss()
                }
            )
            
            // Hint button?
            Button(action: { viewModel.showHint() }) {
                Text("Hint")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
    }
    
    private var feedbackView: some View {
        VStack(spacing: 30) {
            Text("learning.feedback_title")
                .font(.title2)
                .fontWeight(.bold)
            
            if let item = viewModel.currentItem {
                 Text(formatDigits(item.digits))
                     .font(.system(size: 40, weight: .bold, design: .monospaced))
                     .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                if viewModel.allowedRatings.contains(.again) {
                    ratingButton(rating: .again, color: .red)
                }
                if viewModel.allowedRatings.contains(.hard) {
                    ratingButton(rating: .hard, color: .orange)
                }
                if viewModel.allowedRatings.contains(.good) {
                    ratingButton(rating: .good, color: .blue)
                }
                if viewModel.allowedRatings.contains(.easy) {
                    ratingButton(rating: .easy, color: .green)
                }
            }
            .padding(40)
        }
    }
    
    private var summaryView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("learning.session_complete")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(viewModel.itemsReviewedCount) chunks reviewed")
                .foregroundColor(.secondary)
            
            Button(action: { dismiss() }) {
                Text("home.start") // Or "Close"
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Helpers
    
    private func ratingButton(rating: RecallRating, color: Color) -> some View {
        Button(action: {
            viewModel.submitRating(rating)
        }) {
            VStack {
                Text(LocalizedStringKey("learning." + rating.rawValue))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Interval hint? e.g. "10m", "2d" - logic is in Scheduler, maybe add to VM if needed.
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color)
            .cornerRadius(12)
        }
    }
    
    private func formatDigits(_ digits: String) -> String {
        // Group by 2 or 3? Simple spacing
        return digits.map { String($0) }.joined(separator: " ")
    }
}
