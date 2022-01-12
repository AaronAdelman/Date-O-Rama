//
//  ASAMoonPhaseType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 09/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASAMoonPhaseType: String, Codable {
    case none           = "none"
    case newMoon        = "new"
    case firstQuarter   = "1stQuarter"
    case fullMoon       = "full"
    case lastQuarter    = "lastQuarter"
    case firstFullMoon  = "1stFull" // Requires a month
    case secondFullMoon = "2ndFull" // Requires a month
} // enum ASAMoonPhaseType
