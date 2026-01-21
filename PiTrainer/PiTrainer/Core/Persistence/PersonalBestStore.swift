import Foundation

@Observable
final class PersonalBestStore {
    static let shared = PersonalBestStore()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var records: [Constant: [PRType: PersonalBestRecord]] = [:]
    
    // Cache memory pour accès rapide (Max score for display)
    var bestScores: [Constant: Int] {
        records.mapValues { typeMap in
            typeMap.values.map { $0.digitCount }.max() ?? 0
        }
    }
    
    private let storageDirectoryName: String
    
    init(storageDirectoryName: String = "PersonalBests") {
        self.storageDirectoryName = storageDirectoryName
        self.encoder.outputFormatting = .prettyPrinted
    }
    
    func getRecord(for constant: Constant, type: PRType = .crown) -> PersonalBestRecord? {
        print("debug: PersonalBestStore.getRecord(\(constant), \(type)) called")
        if let typeMap = records[constant], let cached = typeMap[type] {
            print("debug: PersonalBestStore found \(cached.digitCount) digits in cache for \(type)")
            return cached
        }
        
        // Lazy load single record from disk
        do {
            let record = try loadRecord(for: constant, type: type)
            print("debug: PersonalBestStore loaded \(record.digitCount) digits from disk for \(type)")
            if records[constant] == nil { records[constant] = [:] }
            records[constant]?[type] = record
            return record
        } catch {
            print("debug: PersonalBestStore loadRecord failed for \(type): \(error)")
        }
        
        return nil
    }
    
    func save(record: PersonalBestRecord) async {
        print("debug: PersonalBestStore.save() for \(record.constant) [\(record.type)]: \(record.digitCount) digits")
        
        // Logic de comparaison
        let current = getRecord(for: record.constant, type: record.type)
        var shouldSave = false
        
        switch record.type {
        case .crown:
            // Crown: Distance priority, then time
            if let current = current {
                if record.digitCount > current.digitCount {
                    shouldSave = true
                } else if record.digitCount == current.digitCount && record.totalTime < current.totalTime {
                    shouldSave = true // Tie-break: faster time wins
                }
            } else {
                shouldSave = true
            }
            
        case .lightning:
            // Lightning: Speed priority (only if count > 50)
            if record.digitCount >= 50 {
                if let current = current {
                    if record.digitsPerMinute > current.digitsPerMinute {
                        shouldSave = true
                    }
                } else {
                    shouldSave = true
                }
            }
        }
        
        guard shouldSave else { 
            print("debug: PersonalBestStore skip save - not a PR")
            return 
        }

        if records[record.constant] == nil { records[record.constant] = [:] }
        records[record.constant]?[record.type] = record
        
        // Sauvegarde disque
        do {
            let fileURL = try getFileURL(for: record.constant, type: record.type)
            let data = try encoder.encode(record)
            try data.write(to: fileURL, options: .atomic)
            print("debug: PersonalBestStore saved \(record.type) to \(fileURL.lastPathComponent)")
        } catch {
            print("❌ Failed to save Personal Best: \(error)")
        }
    }
    
    private func loadRecord(for constant: Constant, type: PRType) throws -> PersonalBestRecord {
        let fileURL = try getFileURL(for: constant, type: type)
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(PersonalBestRecord.self, from: data)
    }
    
    // MARK: - Testing Support
    func reset() async {
        records.removeAll()
        do {
            let docs = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let storageDir = docs.appendingPathComponent(storageDirectoryName, isDirectory: true)
            if fileManager.fileExists(atPath: storageDir.path) {
                try fileManager.removeItem(at: storageDir)
                print("debug: PersonalBestStore reset - deleted \(storageDir.path)")
            }
        } catch {
            print("❌ PersonalBestStore reset failed: \(error)")
        }
    }

    // MARK: - File Path Helper
    private func getFileURL(for constant: Constant, type: PRType) throws -> URL {
        let docs = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let storageDir = docs.appendingPathComponent(storageDirectoryName, isDirectory: true)
        
        if !fileManager.fileExists(atPath: storageDir.path) {
            try fileManager.createDirectory(at: storageDir, withIntermediateDirectories: true)
        }
        
        let suffix = type == .crown ? "pb" : type.rawValue
        return storageDir.appendingPathComponent("\(constant.rawValue)_\(suffix).json")
    }
}
