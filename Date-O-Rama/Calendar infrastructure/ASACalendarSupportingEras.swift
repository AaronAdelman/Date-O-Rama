//
//  ASACalendarSupportingEras.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarSupportingEras: ASACalendar {
    // Symbols
    
    mutating func eraSymbols(localeIdentifier: String) -> Array<String>
    mutating func longEraSymbols(localeIdentifier: String) -> Array<String>

}
