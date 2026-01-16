//
//  FileDigitsProvider.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation

private final class BundleToken {}

/// Provides access to digits stored in a text file in the app bundle
struct FileDigitsProvider: DigitsProvider {
    
    // MARK: - Error Types
    
    enum ProviderError: Error, LocalizedError {
        case fileNotFound(String)
        case invalidContent(String)
        case indexOutOfBounds
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let name):
                return "Digits file '\(name)' not found in bundle"
            case .invalidContent(let reason):
                return "Invalid digits content: \(reason)"
            case .indexOutOfBounds:
                return "Requested index is out of bounds"
            }
        }
    }
    
    // MARK: - Properties
    
    private let constant: Constant
    private let bundle: Bundle
    private var digits: [UInt8] = []
    
    // MARK: - Initialization
    
    init(constant: Constant, bundle: Bundle = .main) {
        self.constant = constant
        self.bundle = bundle
        
        // Try to load immediately to be ready (fail silently here, explicit load called later)
        try? loadDigits()
    }
    
    // MARK: - DigitsProvider
    
    var totalDigits: Int {
        return digits.count
    }
    
    mutating func loadDigits() throws {
        // If already loaded, return
        if !digits.isEmpty { return }
        
        let resourceName = constant.resourceName
        
        // Attempt to load from file
        guard let url = bundle.url(forResource: resourceName, withExtension: "txt") else {
            throw ProviderError.fileNotFound(resourceName)
        }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        let trimmed = content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let utf8 = Array(trimmed.utf8)
        
        if utf8.isEmpty {
             throw ProviderError.invalidContent("Empty file")
        }
        
        guard utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }) else {
             throw ProviderError.invalidContent("Contains non-digit characters")
        }
        
        self.digits = utf8.map { $0 - 48 }
        print("Successfully loaded \(self.digits.count) digits from \(resourceName)")
    }
    
    func getDigit(at index: Int) -> Int? {
        guard index >= 0 && index < digits.count else {
            return nil
        }
        return Int(digits[index])
    }
}
