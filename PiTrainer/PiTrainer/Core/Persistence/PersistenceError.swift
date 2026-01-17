//
//  PersistenceError.swift
//  PiTrainer
//
//  Created by Antigravity on 16/01/2026.
//

import Foundation

enum PersistenceError: Error, LocalizedError {
    case fileNotFound
    case encodingFailed
    case decodingFailed
    case writePermissionDenied
    case directoryCreationFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The requested history file was not found."
        case .encodingFailed:
            return "Failed to encode session history for saving."
        case .decodingFailed:
            return "Failed to decode session history from disk."
        case .writePermissionDenied:
            return "Permission denied when trying to save session history."
        case .directoryCreationFailed:
            return "Failed to create the Application Support directory."
        case .unknown(let error):
            return "An unknown persistence error occurred: \(error.localizedDescription)"
        }
    }
}
