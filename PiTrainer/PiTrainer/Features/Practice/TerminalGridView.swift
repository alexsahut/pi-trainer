//
//  TerminalGridView.swift
//  PiTrainer
//
//  A high-performance display component that shows typed digits
//  in blocks of 10 per line, styled like a terminal/console output.
//  Uses .drawingGroup() for GPU-accelerated rendering to maintain 60 FPS.
//

import SwiftUI

// MARK: - Data Models

/// Represents the visual state of a single digit in the grid
enum DigitState: Equatable {
    case normal      // Successfully typed digit
    case active      // Currently being highlighted (last typed)
    case error       // Incorrect digit flash
}

/// Represents a row of digits in the terminal grid
struct TerminalRow: Identifiable, Equatable {
    let id: Int  // Row index (0, 1, 2, ...)
    let lineNumber: Int  // Human-readable line number (10, 20, 30, ...)
    let digits: [Int]
    let isComplete: Bool
    
    init(index: Int, digits: [Int], startOffset: Int = 0) {
        self.id = index
        self.lineNumber = startOffset + (index + 1) * 10
        self.digits = digits
        self.isComplete = digits.count == 10
    }
}

// MARK: - Terminal Grid View

/// Displays typed digits in a vertical grid with 10 digits per row.
/// Optimized for 60 FPS with GPU acceleration via .drawingGroup().
struct TerminalGridView: View {
    
    // MARK: - Properties
    
    /// All typed digits as a string
    let typedDigits: String
    
    /// The integer part of the constant (e.g., "3" for Pi)
    let integerPart: String
    
    /// Full digits string for ghost reveal (Story 6.1)
    let fullDigits: String
    
    /// Whether the session is in learning mode (Story 6.1)
    var isLearnMode: Bool = false
    
    /// Whether the reveal button (Eye) is allowed (Story 7.1)
    var allowsReveal: Bool = false
    
    /// Offset for the starting index (e.g., 50 if segment starts at 50)
    var startOffset: Int = 0
    
    /// Length of the segment to display (if in Learn Mode)
    var segmentLength: Int? = nil
    
    /// Callback when a row is revealed
    var onReveal: ((Int) -> Void)? = nil
    
    /// Whether to show error reveal on the cursor position
    var showErrorReveal: Bool = false
    
    /// Whether to show error flash on the last digit (Story 9.4)
    var showErrorFlash: Bool = false
    
    /// Wrong digit entered by user (displayed in red at cursor position)
    var wrongInputDigit: Int? = nil
    
    /// Index of the last correctly typed digit (for active highlight)
    var activeIndex: Int? = nil
    
    // MARK: - Computed Properties
    
    private var rows: [TerminalRow] {
        let digits = typedDigits.compactMap { Int(String($0)) }
        var result: [TerminalRow] = []
        
        // In Learn Mode, we show the full segment (using segmentLength if available, else fullDigits)
        // In Practice/Test/Game, we show rows based on typed digits + 1 potential empty row for the "cursor"
        let rowCount: Int
        
        if isLearnMode {
            // Learn Mode: Fixed size based on segment
            let sourceCount = segmentLength ?? fullDigits.count
            let effectiveCount = max(sourceCount, 1)
            rowCount = (effectiveCount + 9) / 10
        } else {
            // Practice Mode: Dynamic growth
            // We always want to show the row where the next digit will be typed.
            // If digits.count is 10, next digit is at index 10 (Row 1).
            // Formula: (count / 10) + 1
            // e.g. 0 -> 1, 9 -> 1, 10 -> 2, 11 -> 2
            rowCount = (digits.count / 10) + 1
        }
        
        for i in 0..<rowCount {
            let startIndex = i * 10
            let endIndex = min(startIndex + 10, digits.count)
            
            let rowDigits: [Int]
            if startIndex < digits.count {
                rowDigits = Array(digits[startIndex..<endIndex])
            } else {
                rowDigits = []
            }
            
            // Pass the startOffset to the row for correct line numbering
            result.append(TerminalRow(index: i, digits: rowDigits, startOffset: startOffset))
        }
        
        return result
    }
    
    
    @State private var revealedDigitsPerRow: [Int: Int] = [:]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Integer part (e.g., "3.") - Only show if starting from 0
                    if startOffset == 0 {
                        HStack(spacing: 0) {
                            Color.clear.frame(width: 58, height: 1) // 50 + 8 offset
                            Text(integerPart + ".")
                                .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .id("integerPart")
                        }
                        .accessibilityHidden(true)
                    }
                    
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: 0) {
                            // Line number and indicator
                            HStack(spacing: 0) {
                                if row.isComplete || !allowsReveal {
                                    Text(String(format: "%03d", row.lineNumber))
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .frame(width: 30, alignment: .trailing)
                                    Text(">")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundColor(row.isComplete ? .gray.opacity(0.5) : DesignSystem.Colors.cyanElectric.opacity(0.8))
                                        .frame(width: 20, height: 24)
                                } else if allowsReveal {
                                    // Story 7.1 Refined: Reveal Eye at the start of the row
                                    Button {
                                        revealNextDigit(in: row)
                                    } label: {
                                        Image(systemName: "eye.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(DesignSystem.Colors.cyanElectric.opacity(0.8))
                                            .frame(width: 50, height: 24)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                        revealFullRow(in: row)
                                    })
                                } else {
                                    Color.clear.frame(width: 30, height: 24)
                                    Text(">")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundColor(DesignSystem.Colors.cyanElectric.opacity(0.8))
                                        .frame(width: 20, height: 24)
                                }
                            }
                            .frame(width: 50, alignment: .trailing)
                            .accessibilityHidden(true)
                            
                            Color.clear.frame(width: 8, height: 1)
                            
                            // Digits
                            HStack(spacing: 0) {
                                ForEach(0..<10) { i in
                                    if i < row.digits.count {
                                        let digit = row.digits[i]
                                        let isLastDigitInRow = (row.id == rows.last?.id && i == row.digits.count - 1)
                                        digitView(digit: digit, state: digitState(localIndex: i, isLast: isLastDigitInRow))
                                    } else if i < (revealedDigitsPerRow[row.id] ?? 0) || isLearnMode || (showErrorReveal && startOffset + (row.id * 10) + i == typedDigits.count) {
                                        let globalIndex = startOffset + (row.id * 10) + i
                                        if globalIndex < fullDigits.count {
                                            let ghostDigit = Int(String(fullDigits[fullDigits.index(fullDigits.startIndex, offsetBy: globalIndex)])) ?? 0
                                            digitView(digit: ghostDigit, state: .normal)
                                                .opacity(DesignSystem.Animations.ghostRevealOpacity)
                                        } else {
                                            placeholderView
                                        }
                                    } else {
                                        placeholderView
                                    }
                                }
                            }
                            .id(row.id)
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(row.isComplete)
                        .focusable(false)
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .focusable(false)
            }
            .focusable(false)
            .accessibilityHidden(true)
            .background(DesignSystem.Colors.blackOLED)
            .onChange(of: typedDigits.count) { oldValue, newValue in
                // Scroll to active row when typing to track progress
                // Formula: count / 10 gives the current visible row index (0, 1, 2...)
                let activeRowIndex = typedDigits.count / 10
                withAnimation(.easeOut(duration: 0.15)) {
                    proxy.scrollTo(activeRowIndex, anchor: .center)
                }
            }
        }
    }
    
    /// Single digit view with state-based styling
    private func digitView(digit: Int, state: DigitState) -> some View {
        Text("\(digit)")
            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
            .foregroundColor(foregroundColor(for: state))
            .frame(width: 22, height: 32)
            .background(backgroundColor(for: state))
            .cornerRadius(4)
    }
    
    /// Placeholder for unfilled digit slots
    private var placeholderView: some View {
        Text("·")
            .font(DesignSystem.Fonts.monospaced(size: 24, weight: .light))
            .foregroundColor(.gray.opacity(0.3))
            .frame(width: 22, height: 32)
    }
    
    private func revealNextDigit(in row: TerminalRow) {
        let currentRevealed = revealedDigitsPerRow[row.id] ?? 0
        if currentRevealed < 10 {
            withAnimation(.spring()) {
                revealedDigitsPerRow[row.id] = currentRevealed + 1
            }
            onReveal?(1)
        }
    }
    
    private func revealFullRow(in row: TerminalRow) {
        let currentRevealed = revealedDigitsPerRow[row.id] ?? 0
        let remainingOnRow = 10 - currentRevealed
        if remainingOnRow > 0 {
            withAnimation(.spring()) {
                revealedDigitsPerRow[row.id] = 10
            }
            onReveal?(remainingOnRow)
        }
    }
    
    private func digitState(localIndex: Int, isLast: Bool) -> DigitState {
        if isLast && showErrorFlash {
            return .error
        } else if isLast || localIndex == activeIndex {
            return .active
        }
        return .normal
    }
    
    private func foregroundColor(for state: DigitState) -> Color {
        switch state {
        case .normal:
            return .white
        case .active:
            return DesignSystem.Colors.cyanElectric
        case .error:
            return .red
        }
    }
    
    private func backgroundColor(for state: DigitState) -> Color {
        switch state {
        case .normal:
            return .clear
        case .active:
            return DesignSystem.Colors.cyanElectric.opacity(0.15)
        case .error:
            return .red.opacity(0.3)
        }
    }
}

// MARK: - Previews

#Preview("Empty") {
    TerminalGridView(
        typedDigits: "",
        integerPart: "3",
        fullDigits: "1415",
        isLearnMode: true
    )
}

#Preview("10 Digits") {
    TerminalGridView(
        typedDigits: "1415926535",
        integerPart: "3",
        fullDigits: "1415926535"
    )
}

#Preview("50 Digits") {
    TerminalGridView(
        typedDigits: "14159265358979323846264338327950288419716939937510",
        integerPart: "3",
        fullDigits: "14159265358979323846264338327950288419716939937510"
    )
}

#Preview("200 Digits") {
    let digits = "14159265358979323846264338327950288419716939937510" +
                 "58209749445923078164062862089986280348253421170679" +
                 "82148086513282306647093844609550582231725359408128" +
                 "48111745028410270193852110555964462294895493038196"
    TerminalGridView(
        typedDigits: digits,
        integerPart: "3",
        fullDigits: digits
    )
}

#Preview("With Error") {
    TerminalGridView(
        typedDigits: "141592653",
        integerPart: "3",
        fullDigits: "1415926535",
        showErrorReveal: true
    )
}
