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
    case fixedTime                           = "fixedTime"
    case degreesBelowHorizon                 = "degreesBelowHorizon" // Event is when the center of the Sun is a specific number of degrees below the horizon
    case solarTimeSunriseSunset              = "solarTimeSunriseSunset" // Solar time, day lasts from sunrise to sunset
    case solarTimeDawn72MinutesDusk72Minutes = "solarTimeDawn72MinutesDusk72Minutes" // Solar time, day lasts from dawn (sunrise - 72 minutes) to dusk (sunset + 72 minutes)
    case timeChange                          = "timeChange" // Change from standard to daylight savings time or vice versa
    case IslamicPrayerTime                   = "IslamicPrayerTime"
    
    case newMoon                             = "newMoon"
    case firstQuarter                        = "firstQuarter"
    case fullMoon                            = "fullMoon"
    case lastQuarter                         = "lastQuarter"
    
    case firstFullMoonDay                    = "1stFullMoonDay" // Requires a month
    case secondFullMoonDay                   = "2ndFullMoonDay" // Requires a month
    
    case MarchEquinox                        = "MarEquinox"
    case JuneSolstice                        = "JunSolstice"
    case SeptemberEquinox                    = "SepEquinox"
    case DecemberSolstice                    = "DecSolstice"
    
    case rise                                = "rise"
    case set                                 = "set"
    
    case Easter                              = "Easter"
} // enum ASADateSpecificationType

extension ASADateSpecificationType {
    var isAllDay: Bool {
        switch self {
        case .oneDay, .oneMonth, .oneYear, .multiDay, .multiMonth, .multiYear, .firstFullMoonDay, .secondFullMoonDay, .Easter:
            return true
            
        default:
            return false
        } // switch self
    } // var isAllDay
    
    var isOneCalendarDayOrLess: Bool {
        return self.isOneCalendarDay || self.isLessThanOneCalendarDay
    } // var isOneCalendarDayOrLess
    
    var isOneCalendarDay: Bool {
        switch self {
        case .oneDay, .firstFullMoonDay, .secondFullMoonDay, .Easter:
            return true
        default:
            return false
        } // switch self
    } // var isOneCalendarDay
    
    var isLessThanOneCalendarDay: Bool {
        switch self {
        case .fixedTime, .degreesBelowHorizon, .solarTimeSunriseSunset, .solarTimeDawn72MinutesDusk72Minutes, .timeChange, .IslamicPrayerTime, .newMoon, .firstQuarter, .fullMoon, .lastQuarter, .MarchEquinox, .JuneSolstice, .SeptemberEquinox, .DecemberSolstice, .rise, .set:
            return true
        default:
            return false
        } // switch self
    } // var isLessThanOneCalendarDay
} // extension ASADateSpecificationType
