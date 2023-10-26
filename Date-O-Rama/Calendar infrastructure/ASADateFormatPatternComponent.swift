//
//  ASADateFormatPatternComponent.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

/// The type of a component of a date format string
enum ASADateFormatPatternComponentType {
    case symbol
    case literal
} // enum ASADateFormatPatternComponentType

/// Encoding of a part of a date format string
struct ASADateFormatPatternComponent {
    var type: ASADateFormatPatternComponentType
    var string: String
} // struct ASADateFormatPatternComponent
