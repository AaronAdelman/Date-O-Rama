//
//  ASABahaiCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/12/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation
import JulianDayNumber

class ASABahaiCalendar: ASASolarTimeCalendar {
    override func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat) -> String {
        return ""
    } // func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat) -> String
    
    // MARK: -
    
    override func isValidDate(dateComponents: ASADateComponents) -> Bool {
        guard let era = dateComponents.era else { return false }
        
        guard era == 0 else { return false }
        
        guard let year = dateComponents.year else { return false }
        
        guard let month = dateComponents.month else { return false }
        guard month >=  1 else { return false }
        guard month <= 20 else { return false }
        
        guard let day = dateComponents.day else { return false }
        if day < 1 {
            return false
        }
        
        let daysInMonth = daysInMonth(era: era, year: year, month: month)
        if day > daysInMonth {
            return false
        }
        
        return true
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    override func date(dateComponents: ASADateComponents) -> Date? {
        guard isValidDate(dateComponents: dateComponents) else { return nil }
        
        guard let era   = dateComponents.era else { return nil }
        guard era == 0 else { return nil }
        guard let year  = dateComponents.year else { return nil }
        guard let month = dateComponents.month else { return nil }
        guard let day   = dateComponents.day else { return nil }
        
        let julianDate: JulianDate = BahaiCalendar.julianDateFrom(year: year, month: month, day: day)
        
        let secondsFromGMT = dateComponents.locationData.timeZone.secondsFromGMT()
        let secondsFromMidnight: Double = 12.0 * Date.SECONDS_PER_HOUR
        let date = Date.date(julianDate: julianDate).addingTimeInterval(TimeInterval(secondsFromGMT) + secondsFromMidnight)
        return date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    override func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        let gregorianComponents = fixedDate.gregorianDateComponents(timeZone: locationData.timeZone)

        let bahaiComponents = GregorianCalendar.convert(year: gregorianComponents.year!, month: gregorianComponents.month!, day: gregorianComponents.day!, to: BahaiCalendar.self)

        return ASADateComponents(calendar: self, locationData: locationData, era: 0, year: bahaiComponents.year, month: bahaiComponents.month, weekday: gregorianComponents.weekday, day: bahaiComponents.day, hour: gregorianComponents.hour, minute: gregorianComponents.minute, second: gregorianComponents.second, nanosecond: gregorianComponents.nanosecond)
    } // func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents
    
    
    // MARK: -
    
    let numberOfMonthsInYear = 20
    
    override func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        switch component {
        case .era:
            let maxiumEra = self.maximumEra
            return Range(maxiumEra...maxiumEra)
        case .year:
            return Range(15300...15300)
        case .yearForWeekOfYear:
            return Range(15300...15300)
        case .quarter:
            return Range(4...4)
        case .month:
            let monthsPerYear = self.numberOfMonthsInYear
            return Range(monthsPerYear...monthsPerYear)
        case .weekOfYear:
            let maximumNumberOfWeeksInYear = self.maximumNumberOfWeeksInYear
            return Range(maximumNumberOfWeeksInYear...maximumNumberOfWeeksInYear)
        case .weekOfMonth:
            let maximumNumberOfWeeksInMonth = self.maximumNumberOfWeeksInMonth
            return Range(maximumNumberOfWeeksInMonth...maximumNumberOfWeeksInMonth)
        case .weekday:
            let daysPerWeek = self.daysPerWeek
            return Range(daysPerWeek...daysPerWeek)
        case .weekdayOrdinal:
            let ordinalDaysPerWeek = self.daysPerWeek - 1
            return Range(ordinalDaysPerWeek...ordinalDaysPerWeek)
        case .day:
            let maximumNumberOfDaysInMonth = self.maximumNumberOfDaysInMonth
            return Range(maximumNumberOfDaysInMonth...maximumNumberOfDaysInMonth)
            
        case .hour:
            let maximumHour = self.maximumHour
            return Range(maximumHour...maximumHour)
        case .minute:
            let maximumMinute = self.maximumMinute
            return Range(maximumMinute...maximumMinute)
        case .second:
            let maximumSecond = self.maximumSecond
            return Range(maximumSecond...maximumSecond)
        case .nanosecond:
            return Range(999999...999999)
            
        case .fractionalHour, .dayHalf, .calendar, .timeZone:
            return nil
        } // switch component
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    override func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        switch component {
        case .era:
            return Range(0...0)
        case .year:
            return Range(1...1)
        case .yearForWeekOfYear:
            return Range(1...1)
        case .quarter:
            return Range(1...1)
        case .month:
            return Range(1...1)
        case .weekOfYear:
            return Range(1...1)
        case .weekOfMonth:
            return Range(1...1)
        case .weekday:
            return Range(1...1)
        case .weekdayOrdinal:
            return Range(0...0)
        case .day:
            return Range(1...1)
        case .hour:
            return Range(0...0)
        case .minute:
            return Range(0...0)
        case .second:
            return Range(0...0)
        case .nanosecond:
            return Range(0...0)
        case .fractionalHour, .dayHalf, .calendar, .timeZone:
            return nil
        } // switch component
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    override func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        return nil
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?
    
    override func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        return nil
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>?
    
    
    // MARK: -
    
    override func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "ar":
            return [
                "جمال",
                "كمال",
                "فضال",
                "عدال",
                "استجلال",
                "استقلال",
                "جلال"
            ]
            
        default:
            return [
                "Jamál",
                "Kamál",
                "Fiḍál",
                "ʻIdál",
                "Istijlál",
                "Istiqlál",
                "Jalál"
            ]
        }
    } // func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
    } // func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return weekdaySymbols(localeIdentifier: localeIdentifier)
    } // func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
        
    
    // MARK: -
    
    override func monthSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "ar":
            return [
            "بهاء",
            "جلال",
            "جمال",
            "عظمة",
            "نور",
            "رحمة",
            "كلمات",
            "كمال",
            "اسماء",
            "عزة",
            "مشية",
            "علم",
            "قدرة",
            "قول",
            "مسائل",
            "شرف",
            "سلطان",
            "ملك",
            "ايام الهاء",
            "علاء",
        ]
            
        default:
            return [
                "Bahá",
                "Jalál",
                "Jamál",
                "ʻAẓamat",
                "Núr",
                "Raḥmat",
                "Kalimát",
                "Kamál",
                "Asmáʼ",
                "ʻIzzat",
                "Mas͟híyyat",
                "ʻIlm",
                "Qudrat",
                "Qawl",
                "Masáʼil",
                "S͟haraf",
                "Sulṭán",
                "Mulk",
                "Ayyám-i-Há",
                "ʻAláʼ",
            ]
        }
    } // func monthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier)
    } // func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
    } // func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier)
    } // func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return shortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithQuarters
    
    override func quarterSymbols(localeIdentifier: String) -> Array<String> {
    return ["Q1", "Q2", "Q3", "Q4"]
    } // func quarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4"]
    } // func shortQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4"]
    } // func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4"]
    } // func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithEras
    
    override func eraSymbols(localeIdentifier: String) -> Array<String> {
        return ["BE"]
    } // func eraSymbols(localeIdentifier: String) -> Array<String>
    
    override func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return eraSymbols(localeIdentifier: localeIdentifier)
    } // func longEraSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: -
    
    func daysInMonth(era: Int, year: Int, month: Int) -> Int {
        return BahaiCalendar.numberOfDaysIn(month: month, year: year)
    } // func daysInMonth(era: Int, year: Int, month: Int)
    
    func daysInYear(era: Int, year: Int) -> Int {
        guard let astronomicalYear = astronomicalYear(era: era, year: year) else { return -1 }

        return BahaiCalendar.numberOfDays(inYear: astronomicalYear)
    } // func daysInYear(era: Int, year: Int) -> Int
    
    func isLeapMonth(era: Int, year: Int, month: Int) -> Bool {
        return month == 19 && isLeapYear(era: era, year: year)
    } // func isLeapMonth(era: Int, year: Int, month: Int) -> Bool
    
    func isLeapYear(era: Int, year: Int) -> Bool {
        return BahaiCalendar.isLeapYear(year)
    } // func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool
    
    
    // MARK: -
    
    var maximumNumberOfWeeksInYear: Int { return 53 }
 
    var maximumNumberOfWeeksInMonth: Int { return 3 }
    
    var maximumNumberOfDaysInMonth: Int { return 19 }

    var maximumHour: Int { return 23 }

    var maximumMinute: Int { return 59 }

    var maximumSecond: Int { return 59 }
    
    var maximumEra: Int { return 0 }
} // class ASABahaiCalendar
