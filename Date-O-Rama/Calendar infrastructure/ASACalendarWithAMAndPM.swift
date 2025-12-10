//
//  ASACalendarWithAMAndPM.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/12/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

protocol ASACalendarWithAMAndPM: ASACalendar {
    func amSymbol(localeIdentifier: String) -> String
    // The symbol used to represent “AM”, localized to the Calendar’s locale.
    func pmSymbol(localeIdentifier: String) -> String
    // The symbol used to represent “PM”, localized to the Calendar’s locale.
}
