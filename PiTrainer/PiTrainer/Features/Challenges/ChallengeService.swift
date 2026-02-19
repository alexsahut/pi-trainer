import Foundation

struct Challenge: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let constant: Constant
    let startIndex: Int
    let referenceSequence: String
    let expectedNextDigits: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Challenge, rhs: Challenge) -> Bool {
        lhs.id == rhs.id
    }
}

protocol ChallengeServiceProtocol {
    func generateDailyChallenge(for constant: Constant, date: Date, grade: Grade) async -> Challenge?
    func generateRandomChallenge(for constant: Constant, grade: Grade) async -> Challenge?
    func isChallengeCompleted(for date: Date) -> Bool
    func markChallengeAsCompleted(for date: Date)
}

@MainActor
class ChallengeService: ChallengeServiceProtocol {
    private let persistence: PracticePersistenceProtocol
    private let digitsProviderFactory: (Constant) -> DigitsProvider
    
    init(persistence: PracticePersistenceProtocol,
         digitsProviderFactory: @escaping (Constant) -> DigitsProvider) {
        self.persistence = persistence
        self.digitsProviderFactory = digitsProviderFactory
    }
    
    // MARK: - MUS Algorithm
    
    /// Calculates the length of the Minimal Unique Sequence starting at the given position.
    /// - Parameters:
    ///   - digits: The full sequence of digits (as UInt8) to search within.
    ///   - pos: The starting index of the sequence candidate.
    /// - Returns: The length of the smallest sequence starting at `pos` that appears only once in `digits`, or -1 if none found.
    static func calculateMUS(in digits: [UInt8], at pos: Int) -> Int {
        let digitsCount = digits.count
        var length = 1
        
        while pos + length <= digitsCount {
            let sequence = digits[pos..<(pos+length)]
            
            if isUnique(sequence: sequence, in: digits) {
                return length
            }
            length += 1
        }
        return -1
    }
    
    private static func isUnique(sequence: ArraySlice<UInt8>, in digits: [UInt8]) -> Bool {
        var count = 0
        let seqCount = sequence.count
        let lastStart = digits.count - seqCount
        
        for i in 0...lastStart {
            if digits[i] == sequence.first! {
                var match = true
                for j in 1..<seqCount {
                    if digits[i+j] != sequence[sequence.startIndex + j] {
                        match = false
                        break
                    }
                }
                if match {
                    count += 1
                    if count > 1 { return false }
                }
            }
        }
        return count == 1
    }

    // MARK: - Daily Challenge Generation
    
    struct LinearCongruentialGenerator: RandomNumberGenerator {
        var state: UInt64
        init(seed: UInt64) { self.state = seed }
        mutating func next() -> UInt64 {
            state = 6364136223846793005 &* state &+ 1442695040888963407
            return state
        }
    }
    
    func isChallengeCompleted(for date: Date) -> Bool {
        guard let lastCompletion = persistence.loadLastChallengeDate() else { return false }
        return Calendar.current.isDate(lastCompletion, inSameDayAs: date)
    }
    
    func markChallengeAsCompleted(for date: Date) {
        persistence.saveLastChallengeDate(date)
    }
    
    func generateDailyChallenge(for constant: Constant, date: Date, grade: Grade) async -> Challenge? {
        // Safe lower bound: ensure at least 10 digits to search, or 0 if totally empty
        let highestIndex = max(1, persistence.getHighestIndex(for: constant.id))
        
        // Load digits (Main Thread OK for load, but logic should be background)
        var provider = digitsProviderFactory(constant)
        do {
            try provider.loadDigits()
        } catch {
            print("Error loading digits for daily challenge: \(error)")
            return nil
        }
        
        let allDigits = Array(provider.allDigitsString.utf8)
        
        return await Task.detached(priority: .userInitiated) {
            // Deterministic RNG based on date and constant
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            guard let seedDate = calendar.date(from: components) else { return nil }
            
            let seed = UInt64(seedDate.timeIntervalSince1970)
            let constantId = constant.id
            let stableConstantHash = constantId.utf8.reduce(0 as UInt64) { (hash, byte) in
                return (hash &* 31) &+ UInt64(byte)
            }
            let finalSeed = seed ^ stableConstantHash
            
            var rng = LinearCongruentialGenerator(seed: finalSeed)
            
            // Random start index bounded by user's highest index (Known Segment)
            let maxStart = max(0, min(highestIndex, allDigits.count) - 1)
            let rangeSize = UInt64(maxStart + 1)
            let initialStartIndex = Int(rng.next() % rangeSize)
            
            // Story 14.2: Adaptive Logic Integrity - Retry loop to ensure scope and MUS success
            for i in 0..<50 {
                let candidateStartIndex = (initialStartIndex + i) % Int(rangeSize)
                if let challenge = ChallengeService.createChallenge(
                    startIndex: candidateStartIndex,
                    allDigits: allDigits,
                    highestIndex: highestIndex,
                    grade: grade,
                    constant: constant,
                    date: seedDate
                ) {
                    return challenge
                }
            }
            return nil
        }.value
    }

    func generateRandomChallenge(for constant: Constant, grade: Grade) async -> Challenge? {
        let highestIndex = max(1, persistence.getHighestIndex(for: constant.id))
        
        var provider = digitsProviderFactory(constant)
        do {
            try provider.loadDigits()
        } catch {
            print("Error loading digits for random challenge: \(error)")
            return nil
        }
        
        let allDigits = Array(provider.allDigitsString.utf8)
        
        return await Task.detached(priority: .userInitiated) {
            var rng = SystemRandomNumberGenerator()
            let maxStart = max(0, min(highestIndex, allDigits.count) - 1)
            let rangeSize = UInt64(maxStart + 1)
            let initialStartIndex = Int(rng.next() % rangeSize)
            
            // Story 14.2: Adaptive Logic Integrity - Retry loop
            for i in 0..<50 {
                let candidateStartIndex = (initialStartIndex + i) % Int(rangeSize)
                if let challenge = ChallengeService.createChallenge(
                    startIndex: candidateStartIndex,
                    allDigits: allDigits,
                    highestIndex: highestIndex,
                    grade: grade,
                    constant: constant,
                    date: Date()
                ) {
                    return challenge
                }
            }
            return nil
        }.value
    }

    private static func createChallenge(
        startIndex: Int,
        allDigits: [UInt8],
        highestIndex: Int,
        grade: Grade,
        constant: Constant,
        date: Date
    ) -> Challenge? {
        guard startIndex < allDigits.count else { return nil }
        
        // Restrict search to user's known segment (0...highestIndex)
        let searchSpace = Array(allDigits.prefix(highestIndex))
        guard startIndex < searchSpace.count else { return nil }
        
        let length = ChallengeService.calculateMUS(in: searchSpace, at: startIndex)
        
        if length == -1 {
            print("ChallengeService: Failed to find MUS at \(startIndex) in range 0..<\(highestIndex)")
            return nil
        }
        
        let subslice = allDigits[startIndex..<(startIndex+length)]
        let refSeq = String(decoding: subslice, as: UTF8.self)
        
        let challengeLength = grade.challengeLength
        let expectedStart = startIndex + length
        
        // Story 14.2 Fix: Resilience for small knowledge bases
        // If the user's Grade requires more digits than they know, clamp to their knowledge.
        // This prevents "nil" results when the user is at the very beginning of their journey.
        let availableSpace = highestIndex - expectedStart
        guard availableSpace >= 0 else {
            print("ChallengeService: Out of scope. expectedStart \(expectedStart) > highestIndex \(highestIndex)")
            return nil
        }
        
        let actualTargetLength = min(challengeLength, availableSpace)
        // We still want a challenge to have at least 1 digit to guess.
        guard actualTargetLength > 0 else {
            print("ChallengeService: Not enough space for target digits at \(expectedStart)")
            return nil
        }
        
        let expectedEnd = expectedStart + actualTargetLength
        
        var expected = ""
        if expectedStart < expectedEnd {
            expected = String(decoding: allDigits[expectedStart..<expectedEnd], as: UTF8.self)
        }
        
        return Challenge(
            id: UUID(),
            date: date,
            constant: constant,
            startIndex: startIndex,
            referenceSequence: refSeq,
            expectedNextDigits: expected
        )
    }
}

