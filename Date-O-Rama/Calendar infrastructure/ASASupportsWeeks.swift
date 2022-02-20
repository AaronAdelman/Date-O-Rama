//
//  ASASupportsWeeks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/02/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

protocol ASASupportsWeeks: ASACalendar {
    var daysPerWeek: Int { get }

    // MARK:  - Symbols
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK:  - Workdays and weekends
    func weekendDays(for regionCode: String?) -> Array<Int>
} // protocol ASASupportsWeeks
