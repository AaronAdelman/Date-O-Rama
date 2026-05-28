//
//  ASAMiscellaneous.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASAMiscellaneous:  String, Codable {
    case none             = "none"
    
    case MarchEquinox     = "Mar"
    case JuneSolstice     = "Jun"
    case SeptemberEquinox = "Sep"
    case DecemberSolstice = "Dec"
    
    case Easter           = "E"
    
    case timeChange       = "tChg"
} // enum ASAMiscellaneous

extension ASAMiscellaneous {
    var isEquinoxOrSolstice: Bool {
        switch self {
        case .MarchEquinox, .JuneSolstice, .SeptemberEquinox, .DecemberSolstice:
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
