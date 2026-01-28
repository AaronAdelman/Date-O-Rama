//
//  ASAGregorianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 30/04/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation
import JulianDayNumber

class ASAGregorianCalendar: ASAAppleCalendar, ASACalendarWithEaster {
    public let BCE = 0
    public let CE  = 1
    
    func calculateEaster(era: Int, year: Int) -> (month: Int, day: Int)? {
        switch era {
        case BCE:
            return nil
            
        case CE:
            return GregorianCalendar.easter(year: year)
            
        default:
            return nil
        } // switch era
    }
    
    init() {
        super.init(calendarCode: .gregorian)
    } // init(calendarCode:  ASACalendarCode)
    
    override var supportedDateFormats: Array<ASADateFormat> {
        return [
            .full,
            .iso8601YearMonthDay,
            .iso8601YearWeekDay,
            .iso8601YearDay
        ]
    }
    
    override var supportedWatchDateFormats: Array<ASADateFormat> {
        return [
            .full,
            .iso8601YearMonthDay,
            .iso8601YearWeekDay,
            .iso8601YearDay,
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
