//
//  ASAMiscellaneousType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASAMiscellaneousType:  String, Codable {
    case none             = "none"
    case MarchEquinox     = "Mar"
    case JuneSolstice     = "Jun"
    case SeptemberEquinox = "Sep"
    case DecemberSolstice = "Dec"
    case Easter           = "Easter"
} // enum ASAMiscellaneousType

extension ASAMiscellaneousType {
    var isEquinoxOrSolstice: Bool {
        switch self {
        case .MarchEquinox, .JuneSolstice,.SeptemberEquinox, .DecemberSolstice:
            return true
            
        default:
            return false
        }
    }
    
    var isEaster: Bool {
        return self == .Easter
    }
}

extension ASAMiscellaneousType? {
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
}
