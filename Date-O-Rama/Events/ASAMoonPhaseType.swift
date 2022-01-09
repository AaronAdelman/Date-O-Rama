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
    case newMoon        = "newMoon"
    case firstQuarter   = "firstQuarter"
    case fullMoon       = "fullMoon"
    case lastQuarter    = "lastQuarter"
    case firstFullMoon  = "1stFullMoon" // Requires a month
    case secondFullMoon = "2ndFullMoon" // Requires a month
} // enum ASAMoonPhaseType
