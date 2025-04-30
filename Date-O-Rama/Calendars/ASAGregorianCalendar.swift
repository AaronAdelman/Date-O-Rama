//
//  ASAGregorianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 30/04/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

class ASAGregorianCalendar: ASAAppleCalendar {
    init() {
        super.init(calendarCode: .Gregorian)
    } // init(calendarCode:  ASACalendarCode)
    
    override var supportedDateFormats: Array<ASADateFormat> {
        return [
            .full,
            .ISO8601YearMonthDay,
            .ISO8601YearWeekDay,
            .ISO8601YearDay
        ]
    }
    
    override var supportedWatchDateFormats: Array<ASADateFormat> {
        return [
            .full,
            .ISO8601YearMonthDay,
            .ISO8601YearWeekDay,
            .ISO8601YearDay,
            .long,
            .medium,
            .mediumWithWeekday,
            .short,
            .shortWithWeekday,
            .abbreviatedWeekday,
            .dayOfMonth,
            .abbreviatedWeekdayWithDayOfMonth,
            .shortWithWeekdayWithoutYear,
            .mediumWithWeekdayWithoutYear,
            .fullWithoutYear,
            .longWithoutYear,
            .mediumWithoutYear,
            .shortWithoutYear
        ]
    }
    
}
