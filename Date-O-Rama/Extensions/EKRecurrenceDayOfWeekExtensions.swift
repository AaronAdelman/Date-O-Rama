//
//  EKRecurrenceDayOfWeekExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

extension EKRecurrenceDayOfWeek {
    func localizedString(calendar: Calendar) -> String {
        let weekNumber: Int = self.weekNumber
        let dayOfTheWeekSymbol: String = self.dayOfTheWeek.standaloneSymbol(calendar: calendar)
        if weekNumber == 0 {
            return dayOfTheWeekSymbol
        } else if weekNumber > 0 {
            return String(format: NSLocalizedString("%@ (week number:  %i)", comment: ""), dayOfTheWeekSymbol, weekNumber)
        } else {
            assert(weekNumber < 0)
            return String(format: NSLocalizedString("%@ (week number from the end:  %i)", comment: ""), dayOfTheWeekSymbol, -weekNumber)

        }
    } // func localizedString(calendar: Calendar) -> String
} // extension EKRecurrenceDayOfWeek
