//
//  ASAJulianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation
import JulianDayNumber

public class ASAJulianCalendar: ASABoothCalendar, ASACalendarWithEaster {
    public let BCE = 0
    public let CE  = 1
    
    
    // MARK: -
    
    override func isLeapMonth(era: Int, year: Int, month: Int) -> Bool {
        return month == 2 && isLeapYear(calendarCode: .julian, era: era, year: year)
    } // func isLeapMonth(era: Int, year: Int, month: Int) -> Bool
    
    override func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool {
        guard let astronomicalYear = astronomicalYear(era: era, year: year) else { return false }
        
        return JulianCalendar.isLeapYear(astronomicalYear)
    } // func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool
    
    // MARK: -
    
    override func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.weekdaySymbols(localeIdentifier: localeIdentifier)
    } // override func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    override func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    override func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    override func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    override func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return self.gregorianCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // override func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    override func monthSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.monthSymbols(localeIdentifier: localeIdentifier)
    } // override func monthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
    } // override func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    } // override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func eraSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.eraSymbols(localeIdentifier: localeIdentifier)
    } // override func eraSymbols(localeIdentifier: String) -> Array<String>
    
    override func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.longEraSymbols(localeIdentifier: localeIdentifier)
    } // func longEraSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithEaster
    
    func calculateEaster(era: Int, year: Int) -> (month: Int, day: Int)? {
        switch era {
        case BCE:
            return nil
            
        case CE:
            return JulianCalendar.easter(year: year)
            
        default:
            return nil
        } // switch era
    }
}
