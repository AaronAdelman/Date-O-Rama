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
    
    // Zodiac signs
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
        
        default:
            return nil
        } // switch self
    } // var emoji
} // extension ASAEventCategory
