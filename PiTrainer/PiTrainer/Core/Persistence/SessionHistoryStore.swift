//
//  SessionHistoryStore.swift
//  PiTrainer
//
//  Created by Antigravity on 16/01/2026.
//

import Foundation
import Observation

@Observable
final class SessionHistoryStore {
    
    private let fileManager = FileManager.default
    private let maxHistoryCount = 200
    private let storageURL: URL
    
    // Threading: Separated queues for different priorities
    private let writeQueue = DispatchQueue(label: "com.pitrainer.historyStore.write", qos: .utility)
    private let readQueue = DispatchQueue(label: "com.pitrainer.historyStore.read", qos: .userInitiated)
    
    /// Initializes the store with an optional custom directory (useful for testing)
    init(customDirectory: URL? = nil) throws {
        if let custom = customDirectory {
            self.storageURL = custom
        } else {
            guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw PersistenceError.directoryCreationFailed
            }
            self.storageURL = appSupport
        }
        try ensureDirectoryExists()
    }
    
    /// Saves the given records to a JSON file for the specified constant.
    /// This operation is performed asynchronously on a background utility queue.
    func saveHistory(_ records: [SessionRecord], for constant: Constant) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            writeQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: PersistenceError.encodingFailed)
                    return
                }
                self.internalSave(records, for: constant, continuation: continuation)
            }
        }
    }
    
    /// Appends a single record to the history of a constant atomically.
    /// This ensures that rapid successive calls correctly increment the history.
    /// Returns the updated history, newest first.
    func appendRecord(_ record: SessionRecord, for constant: Constant) async throws -> [SessionRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            writeQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: PersistenceError.encodingFailed)
                    return
                }
                
                let url = self.getHistoryFileURL(for: constant)
                var records: [SessionRecord] = []
                
                if self.fileManager.fileExists(atPath: url.path) {
                    do {
                        let data = try Data(contentsOf: url)
                        records = try JSONDecoder().decode([SessionRecord].self, from: data)
                    } catch {
                        // If file exists but is corrupted, we don't want to just wipe it if called atomically.
                        continuation.resume(throwing: PersistenceError.decodingFailed)
                        return
                    }
                }
                
                // Add new record at index 0 (newest first strategy)
                records.insert(record, at: 0)
                
                // Keep only the most recent sessions
                let limitedRecords = Array(records.prefix(self.maxHistoryCount))
                
                // CRITICAL: Propagate errors from internalSave back to the caller
                do {
                    try self.internalSaveSync(limitedRecords, for: constant)
                    continuation.resume(returning: limitedRecords)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func internalSaveSync(_ records: [SessionRecord], for constant: Constant) throws {
        do {
            let limitedRecords = Array(records.prefix(maxHistoryCount))
            let url = getHistoryFileURL(for: constant)
            let data = try JSONEncoder().encode(limitedRecords)
            try data.write(to: url, options: [.atomic])
        } catch {
            throw PersistenceError.encodingFailed
        }
    }
    
    private func internalSave(_ records: [SessionRecord], for constant: Constant, continuation: CheckedContinuation<Void, Error>?) {
        do {
            // Defensive prefixing
            let limitedRecords = Array(records.prefix(maxHistoryCount))
            let url = getHistoryFileURL(for: constant)
            let data = try JSONEncoder().encode(limitedRecords)
            try data.write(to: url, options: [.atomic])
            continuation?.resume()
        } catch {
            continuation?.resume(throwing: PersistenceError.encodingFailed)
        }
    }
    
    /// Loads the session history for the specified constant from its JSON file.
    /// This operation is performed asynchronously on a serial queue.
    /// Result is newest records first.
    func loadHistory(for constant: Constant) async throws -> [SessionRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            readQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: PersistenceError.decodingFailed)
                    return
                }
                
                let url = self.getHistoryFileURL(for: constant)
                
                guard self.fileManager.fileExists(atPath: url.path) else {
                    continuation.resume(returning: [])
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let records = try JSONDecoder().decode([SessionRecord].self, from: data)
                    continuation.resume(returning: records)
                } catch {
                    continuation.resume(throwing: PersistenceError.decodingFailed)
                }
            }
        }
    }
    
    /// Deletes all history files from disk.
    func clearAllHistory() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            writeQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                for constant in Constant.allCases {
                    let url = self.getHistoryFileURL(for: constant)
                    if self.fileManager.fileExists(atPath: url.path) {
                        try? self.fileManager.removeItem(at: url)
                    }
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func getHistoryFileURL(for constant: Constant) -> URL {
        return storageURL.appendingPathComponent("session_history_\(constant.id).json")
    }
    
    private func ensureDirectoryExists() throws {
        if !fileManager.fileExists(atPath: storageURL.path) {
            do {
                try fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
            } catch {
                throw PersistenceError.directoryCreationFailed
            }
        }
    }
}
