//
//  ASADateSpecificationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/08/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASADateSpecificationType:  String, Codable {
    case multiYear                           = "nY"
    case oneYear                             = "1Y"
    case multiMonth                          = "nM"
    case oneMonth                            = "1M"
    case multiDay                            = "nD"
    case oneDay                              = "1D"
    case point                               = "pt"
    case solarTimeSunriseSunset              = "SunriseToSunsetTime" // Solar time, day lasts from sunrise to sunset
    case solarTimeDawn72MinutesDusk72Minutes = "dawnToDuskTime" // Solar time, day lasts from dawn (sunrise - 72 minutes) to dusk (sunset + 72 minutes)
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
        return self == .oneDay || self.isLessThanOneCalendarDay
    } // var isOneCalendarDayOrLess
    
    var isLessThanOneCalendarDay: Bool {
        switch self {
        case .point,
                .solarTimeSunriseSunset, .solarTimeDawn72MinutesDusk72Minutes:
            return true
        default:
            return false
        } // switch self
    } // var isLessThanOneCalendarDay
} // extension ASADateSpecificationType
