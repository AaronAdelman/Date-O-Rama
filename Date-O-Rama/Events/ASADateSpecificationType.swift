//
//  ASADateSpecificationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/08/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASADateSpecificationType:  String, Codable {
    case multiYear                           = "multiYear"
    case oneYear                             = "1Year"
    case multiMonth                          = "multiMonth"
    case oneMonth                            = "1Month"
    case multiDay                            = "multiDay"
    case oneDay                              = "1Day"
    case point                               = "pt"
//    case degreesBelowHorizon                 = "degreesBelowHorizon" // Event is when the center of the Sun is a specific number of degrees below the horizon
    case solarTimeSunriseSunset              = "solarTimeSunriseSunset" // Solar time, day lasts from sunrise to sunset
    case solarTimeDawn72MinutesDusk72Minutes = "solarTimeDawn72MinutesDusk72Minutes" // Solar time, day lasts from dawn (sunrise - 72 minutes) to dusk (sunset + 72 minutes)
    case IslamicPrayerTime                   = "IslamicPrayerTime"
    
    case rise                                = "rise"
    case set                                 = "set"
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
//                .degreesBelowHorizon,
                .solarTimeSunriseSunset, .solarTimeDawn72MinutesDusk72Minutes,
                .IslamicPrayerTime,
                .rise, .set:
            return true
        default:
            return false
        } // switch self
    } // var isLessThanOneCalendarDay
} // extension ASADateSpecificationType
