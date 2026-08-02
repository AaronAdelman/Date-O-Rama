//
//  ASAMiscellaneous.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftAA

enum ASAMiscellaneous:  String, Codable {
    case none             = "none"
    
    case MarchEquinox     = "Mar"
    case JuneSolstice     = "Jun"
    case SeptemberEquinox = "Sep"
    case DecemberSolstice = "Dec"
    
    case newMoon          = "new"
    case firstQuarter     = "1stQ"
    case fullMoon         = "full"
    case lastQuarter      = "lastQ"
    case firstFullMoon    = "full1" // Requires a month
    case secondFullMoon   = "full2" // Requires a month
    
    case Easter           = "E"
    
    case timeChange       = "tChg"
} // enum ASAMiscellaneous

extension ASAMiscellaneous {
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
            
        default:
            return .newMoon // Should NEVER occur!
        } // switch self
    }
} // extension ASAMiscellaneous

extension ASAMiscellaneous {
    var isEquinoxOrSolstice: Bool {
        switch self {
        case .MarchEquinox, .JuneSolstice, .SeptemberEquinox, .DecemberSolstice:
            return true
            
        default:
            return false
        }
    }
    
    var isMoonPhase: Bool {
        switch self {
        case .newMoon, .firstQuarter, .fullMoon, .lastQuarter, .firstFullMoon, .secondFullMoon:
            return true
            
        default:
            return false
        }
    }
    
    var isEaster: Bool {
        return self == .Easter
    }
    
    var isTimeChange: Bool {
        return self == .timeChange
    }
}

extension ASAMiscellaneous? {
    var isNone: Bool {
        if self == nil {
            return true
        } else {
            return self! == .none
        }
    }
    
    var isMoonPhase: Bool {
        if self == nil {
            return false
        } else {
            return self!.isMoonPhase
        }
    }

    var isEquinoxOrSolstice: Bool {
        if self == nil {
            return false
        } else {
            return self!.isEquinoxOrSolstice
        }
    }
    
    var isEaster: Bool {
        if self == nil {
            return false
        } else {
            return self!.isEaster
        }
    }
    
    var isTimeChange: Bool {
        if self == nil {
            return false
        } else {
            return self!.isTimeChange
        }
    }
}
