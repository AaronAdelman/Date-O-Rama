//
//  ASALocationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 14/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASALocationType: String {
    case EarthLocation  = "xl"
    case EarthUniversal = "xj"
    case MarsUniversal  = "zmaj"
    
    var defaultCalendarCode: ASACalendarCode {
        switch self {
        case .EarthLocation:
            return .Gregorian
            
        case .EarthUniversal:
            return .JulianDay
            
        case .MarsUniversal:
            return .MarsSolDate
        } // switch self
    } // var defaultCalendarCode
} // enum ASALocationType
