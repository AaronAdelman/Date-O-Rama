//
//  ASAEventCategory.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASAEventCategory: String, Codable {
    case generic
    case birthday
    case deathAnniversary
    case weddingAnniversary
    
    // Sun
    case day
    case night
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
    case Sun
    case Moon
    case Mercury
    case Venus
    case Mars
    case Jupiter
    case Saturn
    
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
        
        default:
            return nil
        } // switch self
    } // var emoji
    
    var isDarkMode: Bool {
        switch self {
        case .night, .Sunset, .civilDusk, .nauticalDusk, .astronomicalDusk,
             .Aries,
             .Taurus,
             .Gemini,
             .Cancer,
             .Leo,
             .Virgo,
             .Libra,
             .Ophiuchus,
             .Scorpio,
             .Sagittarius,
             .Capricorn,
             .Aquarius,
             .Pisces,
             .Sun,
             .Moon,
             .Mercury,
             .Venus,
             .Mars,
             .Jupiter,
             .Saturn,
             .Rat,
             .Ox,
             .Tiger,
             .Rabbit,
             .Dragon,
             .Snake,
             .Horse,
             .Goat,
             .Monkey,
             .Rooster,
             .Dog,
             .Pig:
            return true
            
        default:
            return false
        }
    }
} // extension ASAEventCategory
