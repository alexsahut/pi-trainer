//
//  DigitsProvider.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation

/// Protocol for providing digits for practice
protocol DigitsProvider {
    /// Total number of available digits
    var totalDigits: Int { get }
    
    /// Gets a specific digit at the given index
    /// - Parameter index: Zero-based index (0 = first digit after decimal point)
    /// - Returns: The digit (0-9) at the specified index, or nil if out of bounds
    func getDigit(at index: Int) -> Int?
    
    /// Preloads or prepares the digits for use
    /// - Throws: Error if loading fails
    mutating func loadDigits() throws
}
