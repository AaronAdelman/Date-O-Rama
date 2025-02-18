//
//  ASAEventSpecificationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/08/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

// NOTE:  May need updating to support new date specification types!
enum ASAEventSpecificationType:  String, Codable {
    case multiYear  = "nY"
    case oneYear    = "Y"
    case multiMonth = "nM"
    case oneMonth   = "M"
    case oneWeek    = "W"
    case multiDay   = "nD"
    case oneDay     = "D"
    case span       = "span"
    case point      = "pt"
    case cycle      = "c"
} // enum ASAEventSpecificationType

extension ASAEventSpecificationType {
    // NOTE:  May need updating to support new date specification types!
    var isAllDay: Bool {
        switch self {
        case .oneDay, .oneWeek, .oneMonth, .oneYear, .multiDay, .multiMonth, .multiYear, .cycle:
            return true
            
        case .span, .point:
            return false
        } // switch self
    } // var isAllDay
    
    var isOneCalendarDayOrLess: Bool {
        return self == .oneDay || self == .point
    } // var isOneCalendarDayOrLess
} // extension ASAEventSpecificationType
