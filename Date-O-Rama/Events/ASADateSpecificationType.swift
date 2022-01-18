//
//  ASADateSpecificationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/08/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASADateSpecificationType:  String, Codable {
    case multiYear  = "nY"
    case oneYear    = "1Y"
    case multiMonth = "nM"
    case oneMonth   = "1M"
    case multiDay   = "nD"
    case oneDay     = "1D"
    case span       = "span"
    case point      = "pt"
} // enum ASADateSpecificationType

extension ASADateSpecificationType {
    var isAllDay: Bool {
        switch self {
        case .oneDay, .oneMonth, .oneYear, .multiDay, .multiMonth, .multiYear:
            return true
            
        default:
            return false
        } // switch self
    } // var isAllDay
    
    var isOneCalendarDayOrLess: Bool {
        return self == .oneDay || self == .point
    } // var isOneCalendarDayOrLess
} // extension ASADateSpecificationType
