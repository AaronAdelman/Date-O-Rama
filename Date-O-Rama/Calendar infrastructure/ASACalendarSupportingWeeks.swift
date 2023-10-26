//
//  ASACalendarSupportingWeeks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarSupportingWeeks: ASACalendar {
    var daysPerWeek: Int { get }

    // MARK:  - Symbols
    func weekdaySymbols(localeIdentifier: String) -> Array<String>
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK:  - Workdays and weekends
    func weekendDays(for regionCode: String?) -> Array<Int>
} // protocol ASACalendarSupportingWeeks
