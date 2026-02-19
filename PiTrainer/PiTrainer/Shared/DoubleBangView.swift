//
//  DoubleBangView.swift
//  PiTrainer
//
//  Created by Antigravity on 25/01/2026.
//

import SwiftUI

struct DoubleBangView: View {
    
    @State private var particles: [Particle] = []
    @State private var lightningBranches: [LightningBranch] = []
    @State private var isAnimating = false
    
    private let particleCount = 100
    private let lightningCount = 5
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                // Draw particles
                for index in particles.indices {
                    particles[index].update(at: now, in: size)
                    let particle = particles[index]
                    
                    if particle.opacity > 0 {
                        var pContext = context
                        pContext.opacity = particle.opacity
                        pContext.addFilter(.blur(radius: 2))
                        
                        let rect = CGRect(x: particle.position.x, y: particle.position.y, width: particle.size, height: particle.size)
                        pContext.fill(Path(ellipseIn: rect), with: .color(DesignSystem.Colors.cyanElectric))
                    }
                }
                
                // Draw lightning
                for index in lightningBranches.indices {
                    lightningBranches[index].update(at: now)
                    let branch = lightningBranches[index]
                    
                    if branch.opacity > 0 {
                        var lContext = context
                        lContext.opacity = branch.opacity
                        lContext.stroke(branch.path(in: size), with: .color(.white), lineWidth: 2)
                    }
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private let animationDuration: TimeInterval = 3.0
    
    private func startAnimation() {
        let now = Date().timeIntervalSinceReferenceDate
        
        // Initialize particles
        particles = (0..<particleCount).map { _ in
            Particle(at: now)
        }
        
        // Initialize lightning
        lightningBranches = (0..<lightningCount).map { _ in
            LightningBranch(at: now)
        }
        
        isAnimating = true
        
        // Reset after duration using Task for cancellation support (SwiftUI handles task lifecycle)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000))
            if !Task.isCancelled {
                isAnimating = false
                RewardManager.shared.resetDoubleBang()
            }
        }
    }
}

// MARK: - Models

struct Particle {
    var position: CGPoint
    var velocity: CGPoint
    var size: CGFloat
    var opacity: Double = 1.0
    var startTime: TimeInterval
    var lifeSpan: TimeInterval = 2.0
    
    init(at now: TimeInterval) {
        self.startTime = now
        self.position = CGPoint(x: 0, y: 0) // Will be offset to center in Canvas or update
        self.velocity = CGPoint(
            x: CGFloat.random(in: -300...300),
            y: CGFloat.random(in: -300...300)
        )
        self.size = CGFloat.random(in: 2...6)
    }
    
    mutating func update(at now: TimeInterval, in size: CGSize) {
        let elapsed = now - startTime
        let progress = elapsed / lifeSpan
        
        if progress < 1.0 {
            opacity = 1.0 - progress
            position.x = size.width / 2 + velocity.x * CGFloat(elapsed)
            position.y = size.height / 2 + velocity.y * CGFloat(elapsed)
        } else {
            opacity = 0
        }
    }
}

struct LightningBranch {
    var points: [CGPoint] = []
    var startTime: TimeInterval
    var lifeSpan: TimeInterval = 0.5
    var opacity: Double = 0
    
    init(at now: TimeInterval) {
        self.startTime = now
    }
    
    mutating func update(at now: TimeInterval) {
        let elapsed = now - startTime
        let cycle = 0.2 // Flicker speed
        
        if elapsed < lifeSpan {
            // Flicker effect
            opacity = (sin(elapsed * .pi * 2 / cycle) > 0) ? 0.8 : 0.2
        } else {
            opacity = 0
        }
    }
    
    func path(in size: CGSize) -> Path {
        var path = Path()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        path.move(to: center)
        
        var current = center
        let steps = 10
        let angle = Double.random(in: 0...(2 * .pi))
        let totalLength = min(size.width, size.height) * 0.4
        
        for i in 1...steps {
            let progress = CGFloat(i) / CGFloat(steps)
            let segmentX = cos(angle) * totalLength * progress + CGFloat.random(in: -20...20)
            let segmentY = sin(angle) * totalLength * progress + CGFloat.random(in: -20...20)
            let next = CGPoint(x: center.x + segmentX, y: center.y + segmentY)
            path.addLine(to: next)
            current = next
        }
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DoubleBangView()
    }
}
