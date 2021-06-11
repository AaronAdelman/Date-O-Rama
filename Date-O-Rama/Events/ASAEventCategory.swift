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
        default:
            return nil
        } // switch self
    } // var emoji
} // extension ASAEventCategory
