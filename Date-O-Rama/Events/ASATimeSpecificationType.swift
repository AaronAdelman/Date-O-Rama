//
//  ASATimeSpecificationType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/08/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASATimeSpecificationType:  String, Codable {
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
} // enum ASATimeSpecificationType
