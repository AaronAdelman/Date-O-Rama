//
//  CalendarExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 08/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

extension Calendar {
    // Note:  These could be done a bit more mathematically, but then anyone trying to read the code might get a headache.

    var weekendDays: Array<Int> {
        let firstWeekday: Int = self.firstWeekday
        assert(firstWeekday >= 1)
        assert(firstWeekday <= 7)

        var result: Array<Int> = []
        switch firstWeekday {
        case 1:
            result = [6, 7]

        case 2:
            result = [7, 1]

        case 3:
            result = [1, 2]

        case 4:
            result = [2, 3]

        case 5:
            result = [3, 4]

        case 6:
            result = [4, 5]

        case 7:
            result = [5, 6]

        default:
            result = []
        } // switch firstWeekday

        assert(result.count == 2)
        return result
    } // var weekendDays
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        let canUseApplesWeekendDays: Bool = (regionCode == Locale.current.region?.identifier)

        if canUseApplesWeekendDays {
            return self.weekendDays
        } else {
            return (regionCode ?? REGION_CODE_Earth).backupWeekendDays
        }
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    mutating func weekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.weekdaySymbols
    } // func weekdaySymbols(localeIdentifier:  String) -> Array<String>

    mutating func shortWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.shortWeekdaySymbols
    } // func shortWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func veryShortWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.veryShortWeekdaySymbols
    } // func veryShortWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func standaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.standaloneWeekdaySymbols
    } // func standaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func shortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.shortStandaloneWeekdaySymbols
    } // func shortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.veryShortStandaloneWeekdaySymbols
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func monthSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.monthSymbols
    } // func monthSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func shortMonthSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.shortMonthSymbols
    } // func shortMonthSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func veryShortMonthSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.veryShortMonthSymbols
    } // func veryShortMonthSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func standaloneMonthSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.standaloneMonthSymbols
    } // func standaloneMonthSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func shortStandaloneMonthSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.shortStandaloneMonthSymbols
    } // func shortStandaloneMonthSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func veryShortStandaloneMonthSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.veryShortStandaloneMonthSymbols
    } // func veryShortStandaloneMonthSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func quarterSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.quarterSymbols
    } // func quarterSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func shortQuarterSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.shortQuarterSymbols
    } // func shortQuarterSymbols(localeIdentifier:  String) -> Array<String>
        
    mutating func standaloneQuarterSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.standaloneQuarterSymbols
    } // func standaloneQuarterSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func shortStandaloneQuarterSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.shortStandaloneQuarterSymbols
    } // func shortStandaloneQuarterSymbols(localeIdentifier:  String) -> Array<String>

    mutating func eraSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.eraSymbols
    } // func eraSymbols(localeIdentifier:  String) -> Array<String>
    
    mutating func longEraSymbols(localeIdentifier:  String) -> Array<String> {
        self.locale = Locale.desiredLocale(localeIdentifier)
        return self.longEraSymbols
    } // func longEraSymbols(localeIdentifier:  String) -> Array<String>
} // extension Calendar
