//
//  ASALocationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 14/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASALocationType: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case earthLocation  = "xl"
    case earthUniversal = "xj"
    case marsUniversal  = "zmaj"
    
    var defaultCalendarCode: ASACalendarCode {
        switch self {
        case .earthLocation:
            return .gregorian
            
        case .earthUniversal:
            return .julianDay
            
        case .marsUniversal:
            return .marsSolDate
        } // switch self
    } // var defaultCalendarCode
    
    var localizedName: String {
        var rawName: String
        switch self {
        case .earthLocation:
            rawName = "Earth (specific location)"
        case .earthUniversal:
            rawName = "Earth (all locations)"
        case .marsUniversal:
            rawName = "Mars (all locations)"
        }
        
        return NSLocalizedString(rawName, comment: "")
    }
} // enum ASALocationType
