//
//  ASAEventCategory.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

enum ASAEventCategory: String, Codable {
    case generic
    case birthday
    case deathAnniversary
    case weddingAnniversary
    case remembrance
    
    // Sun
    case day   = "d"
    case night = "n"
    case Sunrise
    case Sunset
    case civilDawn
    case civilDusk
    case nauticalDawn
    case nauticalDusk
    case astronomicalDawn
    case astronomicalDusk

    // Western Zodiac signs
    case Aries
    case Taurus
    case Gemini
    case Cancer
    case Leo
    case Virgo
    case Libra
    case Ophiuchus
    case Scorpio
    case Sagittarius
    case Capricorn
    case Aquarius
    case Pisces
    
    // Classical planets
    case Sun     = "zsu"
    case Moon    = "zmo"
    case Mercury = "zme"
    case Venus   = "zve"
    case Mars    = "zma"
    case Jupiter = "zju"
    case Saturn  = "zsa"
    
    // Chinese Zodiac signs
    case Rat
    case Ox
    case Tiger
    case Rabbit
    case Dragon
    case Snake
    case Horse
    case Goat
    case Monkey
    case Rooster
    case Dog
    case Pig
    
    case candleLightingBeforeSunset
    case candleLightingAfterSunset
    case Shabbath
} // enum ASAEventCategory


extension ASAEventCategory {
    var emoji: String? {
        switch self {
        case .birthday:
            return "🎂"
        case .deathAnniversary:
            return "🪦"
        case .weddingAnniversary:
            return "💍"
        case .remembrance:
            return "🕓"
            
        case .Sunrise:
            return "🌅"
        case .Sunset:
            return "🌇"
            
        case .Aries:
            return "♈️"
        case .Taurus:
            return "♉️"
        case .Gemini:
            return "♊️"
        case .Cancer:
            return "♋️"
        case .Leo:
            return "♌️"
        case .Virgo:
            return "♍️"
        case .Libra:
            return "♎️"
        case .Ophiuchus:
            return "⛎"
        case .Scorpio:
            return "♏️"
        case .Sagittarius:
            return "♐️"
        case .Capricorn:
            return "♑️"
        case .Aquarius:
            return "♒️"
        case .Pisces:
            return "♓️"
            
        case .Sun:
            return "☉"
        case .Moon:
            return "☾"
        case .Mercury:
            return "☿"
        case .Venus:
            return "♀︎"
        case .Mars:
            return "♂︎"
        case .Jupiter:
            return "♃"
        case .Saturn:
            return "♄"
            
        case .Rat:
            return "🐀"
        case .Ox:
            return "🐂"
        case .Tiger:
            return "🐅"
        case .Rabbit:
            return "🐇"
        case .Dragon:
            return "🐉"
        case .Snake:
            return "🐍"
        case .Horse:
            return "🐎"
        case .Goat:
            return "🐐"
        case .Monkey:
            return "🐒"
        case .Rooster:
            return "🐓"
        case .Dog:
            return "🐕"
        case .Pig:
            return "🐖"
            
        case .candleLightingBeforeSunset, .candleLightingAfterSunset:
            return "🕯"
        case .Shabbath:
            return "🍷"
        
        default:
            return nil
        } // switch self
    } // var emoji
    
//    var isDarkMode: Bool {
//        switch self {
//        case .night, .civilDusk, .nauticalDusk, .astronomicalDusk,
//             .civilDawn, .nauticalDawn, .astronomicalDawn,
//             .Aries,
//             .Taurus,
//             .Gemini,
//             .Cancer,
//             .Leo,
//             .Virgo,
//             .Libra,
//             .Ophiuchus,
//             .Scorpio,
//             .Sagittarius,
//             .Capricorn,
//             .Aquarius,
//             .Pisces,
//             .Sun,
//             .Moon,
//             .Mercury,
//             .Venus,
//             .Mars,
//             .Jupiter,
//             .Saturn,
//             .Rat,
//             .Ox,
//             .Tiger,
//             .Rabbit,
//             .Dragon,
//             .Snake,
//             .Horse,
//             .Goat,
//             .Monkey,
//             .Rooster,
//             .Dog,
//             .Pig,
//             .candleLightingAfterSunset:
//            return true
//            
//        default:
//            return false
//        } // switch self
//    } // var isDarkMode
//    
//    var foregroundColor: Color {
//        switch self {
//        case .day, .candleLightingBeforeSunset, .Sunrise, .Sunset:
//            return Color("dayForeground")
//        case .night, .candleLightingAfterSunset, .civilDawn, .civilDusk, .nauticalDawn, .nauticalDusk, .astronomicalDawn, .astronomicalDusk:
//            return Color("nightForeground")
//        
//        default:
//            if self.isDarkMode {
//                return .white
//            } else {
//                return .black
//            }
//        }
//    }
//    
//    var backgroundColor: Color {
//        switch self {
//        case .day, .candleLightingBeforeSunset:
//            return Color("eventDayBackground")
//        case .night, .candleLightingAfterSunset:
//            return Color("eventNightBackground")
//        case .civilDusk, .civilDawn:
//            return Color("eventCivilBackground")
//        case .nauticalDusk, .nauticalDawn:
//            return Color("eventNauticalBackground")
//        case .astronomicalDusk, .astronomicalDawn:
//            return Color("eventAstronomicalBackground")
//        case .Sunrise, .Sunset:
//            return Color("eventRiseSetBackground")
//        
//        default:
//            if self.isDarkMode {
//                return .black
//            } else {
//                return .white
//            }
//        }
//        
//    }
} // extension ASAEventCategory
