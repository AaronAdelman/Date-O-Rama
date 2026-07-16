//
//  ASAPointEventType.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

enum ASAPointEventType: String, Codable {
    case generic = "gen"
    
    /// Event is when the center of the Sun is a specific number of degrees below the horizon
    case twilight = "twi"
    
    /// Solar time, day lasts from sunrise to sunset
    case solarTimeSunriseSunset = "R2ST"
    
    /// Solar time, day lasts from dawn (sunrise - 72 minutes) to dusk (sunset + 72 minutes)
    case solarTimeDawn72MinutesDusk72Minutes = "D2DT"
    
    /// Fajr Islamic prayer time
    case fajrJafari  = "FajrJafari"
    case fajrKarachi = "FajrKarachi"
    case fajrISNA    = "FajrISNA"
    case fajrMWL     = "FajrMWL"
    case fajrMakkah  = "FajrMakkah"
    case fajrEgypt   = "FajrEgypt"
    case fajrTehran  = "FajrTehran"

    /// Dhuhr Islamic prayer time
    case dhuhrJafari  = "DhuhrJafari"
    case dhuhrKarachi = "DhuhrKarachi"
    case dhuhrISNA    = "DhuhrISNA"
    case dhuhrMWL     = "DhuhrMWL"
    case dhuhrMakkah  = "DhuhrMakkah"
    case dhuhrEgypt   = "DhuhrEgypt"
    case dhuhrTehran  = "DhuhrTehran"

    /// Asr Islamic prayer time
    case asrShafiiJafari  = "AsrShafiiJafari"
    case asrHanafiJafari  = "AsrHanafiJafari"
    case asrShafiiKarachi = "AsrShafiiKarachi"
    case asrHanafiKarachi = "AsrHanafiKarachi"
    case asrShafiiISNA    = "AsrShafiiISNA"
    case asrHanafiISNA    = "AsrHanafiISNA"
    case asrShafiiMWL     = "AsrShafiiMWL"
    case asrHanafiMWL     = "AsrHanafiMWL"
    case asrShafiiMakkah  = "AsrShafiiMakkah"
    case asrHanafiMakkah  = "AsrHanafiMakkah"
    case asrShafiiEgypt   = "AsrShafiiEgypt"
    case asrHanafiEgypt   = "AsrHanafiEgypt"
    case asrShafiiTehran  = "AsrShafiiTehran"
    case asrHanafiTehran  = "AsrHanafiTehran"

    /// Maghrib Islamic prayer time
    case maghribJafari  = "MaghribJafari"
    case maghribKarachi = "MaghribKarachi"
    case maghribISNA    = "MaghribISNA"
    case maghribMWL     = "MaghribMWL"
    case maghribMakkah  = "MaghribMakkah"
    case maghribEgypt   = "MaghribEgypt"
    case maghribTehran  = "MaghribTehran"

    /// Isha Islamic prayer time
    case ishaJafari  = "IshaJafari"
    case ishaKarachi = "IshaKarachi"
    case ishaISNA    = "IshaISNA"
    case ishaMWL     = "IshaMWL"
    case ishaMakkah  = "IshaMakkah"
    case ishaEgypt   = "IshaEgypt"
    case ishaTehran  = "IshaTehran"

    /// Rise of the Moon or a planet
    case rise = "rise"
    
    /// Rise of the Moon or a planet
    case set  = "set"
} // enum ASAPointEventType
