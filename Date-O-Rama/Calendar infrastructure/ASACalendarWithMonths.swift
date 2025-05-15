//
//  ASACalendarWithMonths.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 21/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarWithMonths: ASACalendar {
    // Symbols
    
    mutating func monthSymbols(localeIdentifier: String) -> Array<String>
    mutating func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    mutating func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    mutating func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    mutating func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    mutating func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
} // protocol ASACalendarWithMonths
