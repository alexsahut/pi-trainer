//
//  KeypadLayout.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation

enum KeypadLayout: String, Codable, CaseIterable, CustomStringConvertible {
    case phone = "phone"
    case pc = "pc"
    
    var digits: [Int] {
        switch self {
        case .phone:
            return [1, 2, 3, 4, 5, 6, 7, 8, 9]
        case .pc:
            return [7, 8, 9, 4, 5, 6, 1, 2, 3]
        }
    }
    
    var localizedName: String {
        switch self {
        case .phone:
            return NSLocalizedString("settings.layout.phone", comment: "Phone layout")
        case .pc:
            return NSLocalizedString("settings.layout.pc", comment: "PC layout")
        }
    }
    
    var description: String { localizedName }
}

