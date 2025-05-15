//
//  ASACalendarWithQuarters.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarWithQuarters: ASACalendar {
    // Symbols
    
    mutating func quarterSymbols(localeIdentifier: String) -> Array<String>
    mutating func shortQuarterSymbols(localeIdentifier: String) -> Array<String>
   mutating func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    mutating func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
} // protocol ASACalendarWithQuarters
