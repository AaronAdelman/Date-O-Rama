//
//  ASAPointEventType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASAPointEventType: String, Codable {
    case generic = "generic"
    
    /// Event is when the center of the Sun is a specific number of degrees below the horizon
    case twilight = "twilight"
    
    /// Solar time, day lasts from sunrise to sunset
    case solarTimeSunriseSunset = "R2ST"
    
    /// Solar time, day lasts from dawn (sunrise - 72 minutes) to dusk (sunset + 72 minutes)
    case solarTimeDawn72MinutesDusk72Minutes = "D2DT"
    
    /// Fajr Islamic prayer time
    case fajr = "Fajr"

    /// Dhuhr Islamic prayer time
    case dhuhr = "Dhuhr"

    /// Asr Islamic prayer time
    case asr = "Asr"

    /// Maghrib Islamic prayer time
    case maghrib = "Maghrib"

    /// Isha Islamic prayer time
    case isha = "Isha"
    
    /// Rise of the Moon or a planet
    case rise = "rise"
    
    /// Rise of the Moon or a planet
    case set  = "set"
} // enum ASAPointEventType
