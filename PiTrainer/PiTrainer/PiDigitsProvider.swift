//
//  PiDigitsProvider.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import Foundation

private final class BundleToken {}

/// Provides access to Pi digits stored in the app bundle
struct PiDigitsProvider {
    
    // MARK: - Error Types
    
    enum PiDigitsError: Error, LocalizedError {
        case fileNotFound
        case invalidContent(String)
        case indexOutOfBounds
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "Pi digits file not found in bundle"
            case .invalidContent(let reason):
                return "Invalid pi digits content: \(reason)"
            case .indexOutOfBounds:
                return "Requested index is out of bounds"
            }
        }
    }
    
    // MARK: - Properties
    
    private let digits: [UInt8]
    
    /// Total number of available Pi digits
    var totalDigits: Int {
        return digits.count
    }
    
    init(bundle: Bundle = .main) {
        // Load digits during initialization to ensure stability as a value type
        let resourceURL = bundle.url(forResource: "pi_digits", withExtension: "txt") ?? 
                         Bundle(for: BundleToken.self).url(forResource: "pi_digits", withExtension: "txt")
        
        guard let fileURL = resourceURL,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            self.digits = []
            return
        }
        
        // Trim and convert to numeric array safely using UTF8 bytes directly
        let trimmed = content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let utf8 = Array(trimmed.utf8)
        
        // Validate all are ASCII digits (48-57)
        if !utf8.isEmpty && utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }) {
            // Convert to numeric digits (0-9)
            self.digits = utf8.map { $0 - 48 }
        } else {
            self.digits = []
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads Pi digits from the bundle resource file
    /// - Returns: Array containing all Pi digits (0-9 only)
    /// - Throws: PiDigitsError if file not found or content is invalid
    @discardableResult
    func loadDigits() throws -> [UInt8] {
        if digits.isEmpty {
            throw PiDigitsError.fileNotFound
        }
        return digits
    }
    
    /// Gets a specific digit at the given index
    /// - Parameter index: Zero-based index (0 = first digit after decimal point)
    /// - Returns: The digit (0-9) at the specified index, or nil if out of bounds
    func getDigit(at index: Int) -> Int? {
        guard index >= 0 && index < digits.count else {
            return nil
        }
        
        return Int(digits[index])
    }
}
