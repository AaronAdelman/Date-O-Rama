//
//  ASADateFormatPatternComponent.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

/// Encoding of a part of a date format string
struct ASADateFormatPatternComponent {
    /// The type of a component of a date format string
    enum ComponentType {
        case symbol
        case literal
    } // enum ComponentType
    
    var type: ComponentType
    var string: String
} // struct ASADateFormatPatternComponent
