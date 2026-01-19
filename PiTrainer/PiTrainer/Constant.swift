//
//  Constant.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation

enum Constant: String, CaseIterable, Identifiable, Codable, CustomStringConvertible {
    case pi
    case e
    case sqrt2
    case phi
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .pi: return "π"
        case .e: return "e"
        case .sqrt2: return "√2"
        case .phi: return "φ"
        }
    }
    
    var description: String { symbol }
    
    var localizedNameKey: String {
        switch self {
        case .pi: return "constant.pi"
        case .e: return "constant.e"
        case .sqrt2: return "constant.sqrt2"
        case .phi: return "constant.phi"
        }
    }
    
    var integerPart: String {
        switch self {
        case .pi: return "3"
        case .e: return "2"
        case .sqrt2: return "1"
        case .phi: return "1"
        }
    }
    
    var resourceName: String {
        switch self {
        case .pi: return "pi_digits"
        case .e: return "e_digits"
        case .sqrt2: return "sqrt2_digits"
        case .phi: return "phi_digits"
        }
    }
}
