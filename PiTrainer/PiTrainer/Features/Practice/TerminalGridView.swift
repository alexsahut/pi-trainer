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
    
    init(index: Int, digits: [Int]) {
        self.id = index
        self.lineNumber = (index + 1) * 10
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
    
    /// Callback when a row is revealed
    var onReveal: ((Int) -> Void)? = nil
    
    /// Whether to show error flash on the last digit
    var showError: Bool = false
    
    /// Wrong digit entered by user (displayed in red at cursor position)
    var wrongInputDigit: Int? = nil
    
    /// Index of the last correctly typed digit (for active highlight)
    var activeIndex: Int? = nil
    
    // MARK: - Computed Properties
    
    private var rows: [TerminalRow] {
        let digits = typedDigits.compactMap { Int(String($0)) }
        var result: [TerminalRow] = []
        
        let rowCount = (digits.count / 10) + 1
        
        for i in 0..<rowCount {
            let startIndex = i * 10
            let endIndex = min(startIndex + 10, digits.count)
            
            let rowDigits: [Int]
            if startIndex < digits.count {
                rowDigits = Array(digits[startIndex..<endIndex])
            } else {
                rowDigits = []
            }
            
            result.append(TerminalRow(index: i, digits: rowDigits))
        }
        
        return result
    }
    
    
    @State private var revealedDigitsPerRow: [Int: Int] = [:]
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 4) {
                    // Header row with integer part
                    headerRow
                    
                    // Digit rows
                    ForEach(rows) { row in
                        rowView(row: row)
                            .id(row.id)
                    }
                    
                    // Cursor placeholder for auto-scroll target
                    Color.clear
                        .frame(height: 1)
                        .id("cursor")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: typedDigits.count) { oldValue, newValue in
                withAnimation(.easeOut(duration: 0.15)) {
                    proxy.scrollTo("cursor", anchor: .bottom)
                }
            }
        }
        .background(DesignSystem.Colors.blackOLED)
        // GPU-accelerated rendering for 60 FPS
        // .drawingGroup()
    }
    
    // MARK: - Subviews
    
    /// Header row showing the integer part (e.g., "3.")
    private var headerRow: some View {
        HStack(spacing: 0) {
            // Line indicator placeholder (empty for alignment)
            Text("   ")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.gray.opacity(0.5))
                .frame(width: 40, alignment: .trailing)
            
            Text(" ")
                .frame(width: 8)
            
            // Integer part with decimal point
            Text("\(integerPart).")
                .font(DesignSystem.Fonts.monospaced(size: 24, weight: .bold))
                .foregroundColor(.white)
                .accessibilityIdentifier("session.integer_part")
        }
    }
    
    /// A single row of up to 10 digits with line indicator
    private func rowView(row: TerminalRow) -> some View {
        HStack(spacing: 0) {
            // Line indicator (shows after completing 10 digits, e.g., "10 >")
            lineIndicator(for: row)
            
            Text(" ")
                .frame(width: 8)
            
            // Digits in this row
            HStack(spacing: 2) {
                ForEach(0..<10, id: \.self) { digitIndex in
                    let globalIndex = row.id * 10 + digitIndex
                    let revealedInRow = revealedDigitsPerRow[row.id] ?? 0
                    
                    if digitIndex < row.digits.count {
                        let isLast = globalIndex == typedDigits.count - 1
                        let state = digitState(globalIndex: globalIndex, isLast: isLast)
                        digitView(digit: row.digits[digitIndex], state: state)
                    } else if globalIndex == typedDigits.count, let wrongDigit = wrongInputDigit {
                        // Show the wrong input in red at cursor position
                        digitView(digit: wrongDigit, state: .error)
                    } else if digitIndex < revealedInRow {
                        // Ghost Reveal Pattern (Story 6.1)
                        if let ghostChar = fullDigits.count > globalIndex ? fullDigits[fullDigits.index(fullDigits.startIndex, offsetBy: globalIndex)] : nil,
                           let digit = Int(String(ghostChar)) {
                            digitView(digit: digit, state: .normal)
                                .opacity(0.15) // Ghostly transparency
                        } else {
                            placeholderView
                        }
                    } else {
                        placeholderView
                    }
                }
            }
        }
        // VoiceOver: Announce each block of 10 as a logical unit
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: row))
    }
    
    /// Generate VoiceOver label for a row
    private func accessibilityLabel(for row: TerminalRow) -> String {
        let digitsText = row.digits.map { String($0) }.joined(separator: " ")
        if row.isComplete {
            return String(localized: "Décimales \(row.lineNumber - 9) à \(row.lineNumber): \(digitsText)")
        } else {
            let start = row.id * 10 + 1
            let end = start + row.digits.count - 1
            return String(localized: "Décimales \(start) à \(end): \(digitsText)")
        }
    }
    
    /// Line indicator showing the cumulative digit count
    private func lineIndicator(for row: TerminalRow) -> some View {
        Group {
            if row.isComplete {
                Text("\(row.lineNumber) >")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.5))
            } else if isLearnMode && (revealedDigitsPerRow[row.id] ?? 0) < 10 {
                // Reveal Button (Story 6.1)
                Image(systemName: "eye.fill")
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.cyanElectric.opacity(0.6))
                    .frame(width: 24, height: 24)
                    .background(DesignSystem.Colors.cyanElectric.opacity(0.1))
                    .clipShape(Circle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            let current = revealedDigitsPerRow[row.id] ?? row.digits.count
                            let next = min(10, current + 1)
                            if next > current {
                                revealedDigitsPerRow[row.id] = next
                                onReveal?(1) 
                            }
                        }
                    }
                    .onLongPressGesture {
                        withAnimation(.spring()) {
                            let current = revealedDigitsPerRow[row.id] ?? row.digits.count
                            let next = 10
                            if next > current {
                                let newlyRevealed = next - current
                                revealedDigitsPerRow[row.id] = next
                                onReveal?(newlyRevealed)
                            }
                        }
                    }
                    .accessibilityLabel(String(localized: "Révéler la ligne"))
            } else {
                Text("   ")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.clear)
            }
        }
        .frame(width: 40, alignment: .trailing)
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
    
    // MARK: - Helpers
    
    private func digitState(globalIndex: Int, isLast: Bool) -> DigitState {
        if isLast && showError {
            return .error
        } else if isLast || globalIndex == activeIndex {
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
        showError: true
    )
}
