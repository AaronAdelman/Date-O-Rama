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
    case Fajr = "Fajr"

    /// Dhuhr Islamic prayer time
    case Dhuhr = "Dhuhr"

    /// Asr Islamic prayer time
    case Asr = "Asr"

    /// Maghrib Islamic prayer time
    case Maghrib = "Maghrib"

    /// Isha Islamic prayer time
    case Isha = "Isha"
    
    /// Rise of the Moon or a planet
    case rise = "rise"
    
    /// Rise of the Moon or a planet
    case set  = "set"
} // enum ASAPointEventType
