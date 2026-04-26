//
//  ASAMoonPhase.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 09/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftAA

enum ASAMoonPhase: String, Codable {
    case none           = "none"
    case newMoon        = "new"
    case firstQuarter   = "1stQ"
    case fullMoon       = "full"
    case lastQuarter    = "lastQ"
    case firstFullMoon  = "full1" // Requires a month
    case secondFullMoon = "full2" // Requires a month
} // enum ASAMoonPhase

extension ASAMoonPhase {
    var swiftAAMoonPhase: MoonPhase {
        switch self {
        case .fullMoon, .firstFullMoon, .secondFullMoon:
            return .fullMoon
            
        case .newMoon:
            return .newMoon
            
        case .firstQuarter:
            return .firstQuarter
            
        case .lastQuarter:
            return .lastQuarter
            
        case .none:
            return .newMoon // Should NEVER occur!
        } // switch self
    }
} // extension ASAMoonPhase
