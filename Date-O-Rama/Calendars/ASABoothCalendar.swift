//
//  ASABoothCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import JulianDayNumber

public class ASABoothCalendar:  ASACalendar, ASACalendarWithWeeks, ASACalendarWithMonths, ASACalendarWithEras {
    var calendarCode: ASACalendarCode
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
    } // init(calendarCode:  ASACalendarCode)
    
    var canSplitTimeFromDate: Bool = true
    
    var defaultDateFormat: ASADateFormat = .full
    
    var defaultTimeFormat: ASATimeFormat = .medium
    
    var supportedDateFormats: Array<ASADateFormat> = [.full]
    
    var supportedWatchDateFormats: Array<ASADateFormat> = [
        .full,
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
    
    var supportedTimeFormats: Array<ASATimeFormat> = [.medium]
    
    var supportsLocales: Bool = true
    
    var supportsLocations: Bool = true
    
    var supportsTimes: Bool = true
    
    var supportsTimeZones: Bool = true
    
    var transitionType: ASATransitionType = .midnight
    
    var usesISOTime: Bool = true
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        let (dateString, timeString, _) = dateStringTimeStringDateComponents(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        if dateString.isEmpty {
            return timeString
        }
        if timeString.isEmpty {
            return dateString
        }
        return dateString + " · " + timeString
    }
    
    private var dateFormatter = DateFormatter()
    private var formatter = NumberFormatter()
    
    fileprivate func stringFromInteger(_ integerValue: Int, minimumIntegerDigits: Int) -> String {
        
        formatter.minimumIntegerDigits = minimumIntegerDigits
        let symbol = self.formatter.string(from: NSNumber(value: integerValue))!
        return symbol
    }
    
    let datePatternComponentCache = NSCache<NSString, NSArray>()
    
    fileprivate func dateString(dateComponents: ASADateComponents, localeIdentifier: String, dateFormat: ASADateFormat) -> String {
        var dateFormatPattern: String
        
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: .none, timeZone: TimeZone.current)
        self.dateFormatter.apply(dateFormat: dateFormat)
        dateFormatPattern = self.dateFormatter.dateFormat ?? ""
        
        if dateComponents.weekday == 0 {
            // Handle “blank” days not part of any week
            dateFormatPattern = dateFormatPattern.removingWeekdayFromLDML
        }
        
        var components: Array<ASADateFormatPatternComponent>
        let candidateComponents = self.datePatternComponentCache.object(forKey: dateFormatPattern as NSString)
        if candidateComponents == nil {
            components = dateFormatPattern.dateFormatPatternComponents
            datePatternComponentCache.setObject(components as NSArray, forKey: dateFormatPattern as NSString)
        } else {
            components = candidateComponents as! Array<ASADateFormatPatternComponent>
        }
        
        var result = ""
        formatter.locale = Locale(identifier: localeIdentifier)
        
        for component in components {
            switch component.type {
            case .literal:
                result.append(component.string)
                
            case .symbol:
                var symbol = ""
                switch component.string {
                case "G", "GG", "GGG":
                    let symbols = self.eraSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[0]
                    
                case "GGGG":
                    let symbols = self.longEraSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[0]
                    
                case "GGGGG":
                    let symbols = self.eraSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[0]
                    
                case "y", "Y", "u", "U":
                    let year = dateComponents.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 1)
                    
                case "yy", "YY", "uu", "UU":
                    let year = dateComponents.year!
                    let revisedYear = year % 100
                    symbol = stringFromInteger(revisedYear, minimumIntegerDigits: 2)
                    
                case "yyy", "YYY", "uuu", "UUU":
                    let year = dateComponents.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 3)
                    
                case "yyyy", "YYYY", "uuuu", "UUUU":
                    let year = dateComponents.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 4)
                    
                case "yyyyy", "YYYYY", "uuuuu", "UUUUU":
                    let year = dateComponents.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 5)
                    
                case "Q", "QQ", "q", "qq", "QQQQQ", "qqqqq":
                    let quarter = dateComponents.quarter!
                    symbol = stringFromInteger(quarter, minimumIntegerDigits: 2)
                    
                case "QQQ":
                    let quarter = dateComponents.quarter!
                    let symbols = self.shortQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "QQQQ":
                    let quarter = dateComponents.quarter!
                    let symbols = self.quarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "qqq":
                    let quarter = dateComponents.quarter!
                    let symbols = self.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "qqqq":
                    let quarter = dateComponents.quarter!
                    let symbols = self.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "M", "MM":
                    let month = dateComponents.month!
                    symbol = stringFromInteger(month, minimumIntegerDigits: 2)
                    
                case "MMM":
                    let symbols = self.shortMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "MMMM":
                    let symbols = self.monthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "MMMMM":
                    let symbols = self.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "L", "LL":
                    let month = dateComponents.month!
                    symbol = stringFromInteger(month, minimumIntegerDigits: 2)
                    
                case "LLL":
                    let symbols = self.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "LLLL":
                    let symbols = self.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "LLLLL":
                    let symbols = self.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "l":
                    symbol = "" // Really.  That’s what the spec says.
                    
                case "d":
                    let day = dateComponents.day!
                    symbol = stringFromInteger(day, minimumIntegerDigits: 1)
                    
                case "dd":
                    let day = dateComponents.day!
                    symbol = stringFromInteger(day, minimumIntegerDigits: 2)
                    
                case "D":
                    let era = dateComponents.era!
                    let dayInYear = dayOfYear(calendarCode: dateComponents.calendar.calendarCode, era: era, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 1)
                    
                case "DD":
                    let era = dateComponents.era!
                    let dayInYear = dayOfYear(calendarCode: dateComponents.calendar.calendarCode, era: era, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 2)
                    
                case "DDD":
                    let era = dateComponents.era!
                    let dayInYear = dayOfYear(calendarCode: dateComponents.calendar.calendarCode, era: era, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 3)
                    
                case "E", "EE", "EEE", "eee":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = self.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "EEEE", "eeee":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = self.weekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "EEEEE", "eeeee":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = self.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "e", "c":
                    let dayOfWeek = dateComponents.weekday!
                    symbol = stringFromInteger(dayOfWeek, minimumIntegerDigits: 1)
                    
                case "ee", "cc":
                    let dayOfWeek = dateComponents.weekday!
                    symbol = stringFromInteger(dayOfWeek, minimumIntegerDigits: 2)
                    
                case "ccc":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = self.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "cccc":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = self.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "ccccc":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = self.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "w", "ww", "W", "WW", "F", "g", "gg", "ggg", "gggg", "ggggg", "r", "rr", "rrr", "rrrr", "rrrrr": // TODO:  Implement these!
                    symbol = "<\(component.string)>"
                    
                default:
                    symbol = "<\(component.string)>"
                }
                result.append(symbol)
            } // switch component.type
        } // for component in components
        
        return result
    } // func dateString(dateComponents: ASADateComponents, localeIdentifier: String, dateFormat: ASADateFormat) -> String
    
    fileprivate func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        self.dateFormatter.calendar = gregorianCalendar
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: timeFormat, timeZone: locationData.timeZone)
        self.dateFormatter.apply(dateFormat: .none)
        return self.dateFormatter.string(from: now)
    } // func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
    
    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let rawComponents = boothComponents(calendarCode: self.calendarCode, date: now, timeZone: locationData.timeZone)
        
        let era: Int     = rawComponents.era
        let year: Int    = rawComponents.year
        let month: Int   = rawComponents.month
        let day: Int     = rawComponents.day
        let weekday: Int = rawComponents.weekday
        let isLeapMonth  = isLeapMonth(era: era, year: year, month: month)
        var quarter: Int?
        switch month {
        case 1, 2, 3:
            quarter = 1
            
        case 4, 5, 6:
            quarter = 2
            
        case 7, 8, 9:
            quarter = 3
            
        case 10, 11, 12, 13:
            quarter = 4
            
        default:
            quarter = nil
        }
        let hour       = rawComponents.hour  // TODO:  Fix the time components
        let minute     = rawComponents.minute
        let second     = rawComponents.second
        let nanosecond = rawComponents.nanosecond
        let components: ASADateComponents = ASADateComponents(calendar: self, locationData: locationData, era: rawComponents.era, year: year, quarter: quarter, month: month, isLeapMonth: isLeapMonth, weekday: weekday, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        let dateString = dateString(dateComponents: components, localeIdentifier: localeIdentifier, dateFormat: dateFormat)
        let timeString = timeString(now: now, localeIdentifier: localeIdentifier, timeFormat: timeFormat, locationData: locationData)
        return (dateString, timeString, components)
    } // func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    lazy var gregorianCalendar = Foundation.Calendar(identifier: .gregorian)
    
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        gregorianCalendar.timeZone = locationData.timeZone
        return gregorianCalendar.startOfDay(for: date)
    } // func startOfDay(for date: Date, locationData: ASALocation) -> Date
    
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        gregorianCalendar.timeZone = locationData.timeZone
        return gregorianCalendar.startOfDay(for: date.oneDayAfter)
    } // func startOfNextDay(date: Date, locationData: ASALocation) -> Date
    
    func supports(calendarComponent: ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era, .year,.month, .weekday, .day, .quarter:
            return true
            
        case  .yearForWeekOfYear, .weekOfYear, .weekOfMonth, .weekdayOrdinal:
            return false
            
        case .hour, .minute, .second, .nanosecond:
            return true
            
        case .calendar, .timeZone:
            return true
            
        case .fractionalHour, .dayHalf:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        guard let era = dateComponents.era, let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else { return false }
        
        return isValidBoothCalendarDate(calendarCode: dateComponents.calendar.calendarCode, era: era, year: year, month: month, day: day)
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        guard let era = dateComponents.era, let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else {
            return nil
        }
        let timeZone = dateComponents.locationData.timeZone
        let result = dateFromBoothComponents(calendarCode: calendarCode, era: era, year: year, month: month, day: day, hour: dateComponents.hour ?? 0, minute: dateComponents.minute ?? 0, second: dateComponents.second ?? 0, nanosecond: dateComponents.nanosecond ?? 0, timeZone: timeZone)
        return result
    }
    
    func component(_ component: ASACalendarComponent, from date: Date, locationData: ASALocation) -> Int {
        let components: ASADateComponents = self.dateComponents([component], from: date, locationData: locationData)
        
        switch component {
        case .era:
            return components.era ?? -1
            
        case .year:
            return components.year ?? -1
            
        case .yearForWeekOfYear:
            return components.yearForWeekOfYear ?? -1
            
        case .quarter:
            return components.quarter ?? -1
            
        case .month:
            return components.month ?? -1
            
        case .weekOfYear:
            return components.weekOfYear ?? -1
            
        case .weekOfMonth:
            return components.weekOfMonth ?? -1
            
        case .weekday:
            return components.weekday ?? -1
            
        case .weekdayOrdinal:
            return components.weekdayOrdinal ?? -1
            
        case .day:
            return components.day ?? -1
            
        case .hour:
            return components.hour ?? -1
            
        case .minute:
            return components.minute ?? -1
            
        case .second:
            return components.second ?? -1
            
        case .nanosecond:
            return components.nanosecond ?? -1
            
        case .fractionalHour, .dayHalf, .calendar, .timeZone:
            return -1
        } // switch component
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData: ASALocation) -> Int
    
    func isLeapMonth(era: Int, year: Int, month: Int) -> Bool {
        // TODO:  Must override when subclassing
        return false
    } // func isLeapMonth(era: Int, year: Int, month: Int) -> Bool
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        let timeZone = locationData.timeZone
        let components = boothComponents(calendarCode: self.calendarCode, date: date, timeZone: timeZone)
        let era = components.era
        let year = components.year
        let month: Int = components.month
        let weekday = components.weekday
        let isLeapMonth = isLeapMonth(era: era, year: year, month: month)
        let day: Int = components.day
        let result = ASADateComponents(calendar: self, locationData: locationData, era: era, year: year, month: components.month, isLeapMonth: isLeapMonth, weekday: weekday, day: day, hour: nil, minute: nil, second: nil, nanosecond: nil)
        return result
    }
    
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        switch component {
        case .era:
            return Range(1...1)
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
            return Range(53...53)
        case .weekOfMonth:
            return Range(5...5)
        case .weekday:
            let daysPerWeek = self.daysPerWeek
            return Range(daysPerWeek...daysPerWeek)
        case .weekdayOrdinal:
            let ordinalDaysPerWeek = self.daysPerWeek - 1
            return Range(ordinalDaysPerWeek...ordinalDaysPerWeek)
        case .day:
            return Range(31...31)
            
            // TODO: Need to change to support decimal time
        case .hour:
            return Range(23...23)
        case .minute:
            return Range(59...59)
        case .second:
            return Range(59...59)
        case .nanosecond:
            return Range(999999...999999)
            
        case .fractionalHour, .dayHalf, .calendar, .timeZone:
            return nil
        } // switch component
    }
    
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
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
    }
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        return nil // TODO:  Fill in!
    }
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        let components = dateComponents([], from: date, locationData: ASALocation.NullIsland)
        
        switch larger {
        case .year:
            switch smaller {
            case .month:
                return Range(1...self.numberOfMonthsInYear)
                
            case .day:
                let era = components.era
                let year = components.year
                let isLeapYear = era != nil && year != nil ?  isLeapYear(calendarCode: self.calendarCode, era: era!, year: year!) : false
                // TODO: This will need to be changed if implementing a calendar which has years which are not 365 or 366 days long.
                let DAYS_IN_YEAR_IN_LEAP_YEAR = 366
                let DAYS_IN_YEAR = 365
                return isLeapYear ? Range(1...DAYS_IN_YEAR_IN_LEAP_YEAR) : Range(1...DAYS_IN_YEAR)
                
            default:
                return nil
            } // switch smaller
            
        case .month:
            switch smaller {
            case .day:
                let month = components.month ?? -1
                let year  = components.year ?? -1
                let era   = components.era ?? -1
                return Range(1...daysInMonth(era: era, year: year, month: month))
                
            default:
                return nil
            } // switch smaller
            
        default:
            return nil
        } // switch larger
    }
    
    func localModifiedJulianDay(date: Date, locationData: ASALocation) -> Int {
        let timeZone = locationData.timeZone
        return date.localModifiedJulianDay(timeZone: timeZone)
        
        // TODO:  May need to modify this
    }
    
    func miniCalendarNumberFormat(locale: Locale) -> ASANumberFormat {
        .system
    }
    
    // TODO:  Override when implementing a new calendar.
    var daysPerWeek: Int { return -1 }
    
    // TODO:  Override when implementing a new calendar.
    var numberOfMonthsInYear: Int { return -1 }
    
    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    }
    
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    }
    
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    }
    
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    }
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return []
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        return         self.gregorianCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    func monthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func monthSymbols(localeIdentifier: String) -> Array<String>
    
    func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    func eraSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func eraSymbols(localeIdentifier: String) -> Array<String>
    
    func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } //func longEraSymbols(localeIdentifier: String) -> Array<String>
    
    func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.quarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.gregorianCalendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK: - Cycles
    
    func cycleNumberFormat(locale: Locale) -> ASANumberFormat {
        return .system
    } // func cycleNumberFormat(locale: Locale) -> ASANumberFormat
    
    // MARK: -
    
    // TODO:  Override when implementing a new calendar
    func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool {
        return false
    } // func isLeapYear(calendarCode: ASACalendarCode, era: Int, year: Int) -> Bool

    // TODO:  Override when implementing new calendars
    func dayOfWeek(dateAsJulianDate: Double, month: Int, day: Int) -> Int {
        return -1
    }
    
    // TODO:  Override when implementing new calendars
    func boothYMD(gregorianComponents: DateComponents) -> (year: Int, month: Int, day: Int) {
        return (-1, -1, -1)
    }
    
    func boothComponents(calendarCode: ASACalendarCode, date: Date, timeZone: TimeZone) -> (era: Int, year: Int, month: Int, day: Int, weekday: Int, hour: Int, minute: Int, second: Int, nanosecond: Int) {
        var dateAsJulianDate = date.addingTimeInterval(-18.0 * 60.0 * 60.0 - Double(timeZone.secondsFromGMT(for: date))).julianDate
        
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone
        let gregorianComponents = gregorian.dateComponents([.hour, .minute, .second, .nanosecond, .era, .year, .month, .day, .weekday], from: date)
        if gregorianComponents.hour == 0 && gregorianComponents.minute == 0 && gregorianComponents.second == 0 && gregorianComponents.nanosecond == 0 {
            dateAsJulianDate += 1
        }
        
        let boothYMD: (year: Int, month: Int, day: Int) = boothYMD(gregorianComponents: gregorianComponents)
        
        let day = boothYMD.day
        let month: Int = boothYMD.month
        let boothYear: Int = boothYMD.year
        let weekday = dayOfWeek(dateAsJulianDate: dateAsJulianDate, month: month, day: day)
        
        let (era, year) = {
            if calendarCode.shouldUseAstronomicalYears {
                return boothYear.eraAndYearFromAstronomicalYear
            } else {
                return (0, boothYear)
            }
        }()
        
        //    assert(isValidBoothCalendarDate(era: era, year: year, month: month, day: day))
        return (era, year, month, day, weekday, gregorianComponents.hour!, gregorianComponents.minute!, gregorianComponents.second!, gregorianComponents.nanosecond!)
    } // func boothComponents(calendarCode: ASACalendarCode, date: Date, timeZone: TimeZone) -> (era: Int, year: Int, month: Int, day: Int, weekday: Int, hour: Int, minute: Int, second: Int, nanosecond: Int)

    // TODO: Override when implementing a new calendar
    func daysInMonth(era: Int, year: Int, month: Int) -> Int {
        return -1
    } // func daysInMonth(era: Int, year: Int, month: Int)

    func isValidBoothCalendarDate(calendarCode: ASACalendarCode, era: Int, year: Int, month: Int, day: Int) -> Bool {
        guard era >= 0 else { return false }
        //    guard era <= 1 else { return false }
        
        guard month >=  1 else { return false }
        //    guard month <= 12 else { return false }
        
        if day < 1 {
            return false
        }
        
        let daysInMonth = daysInMonth(era: era, year: year, month: month)
        if day > daysInMonth {
            return false
        }
        
        return true
    } // func isValidBoothCalendarDate(calendarCode: ASACalendarCode, era: Int, year: Int, month: Int, day: Int) -> Bool

    // TODO: Override when implementing new calendars
    func julianDateFrom(era: Int, year: Int, month: Int, day: Int) -> JulianDate {
        return JulianDate.nan
    }
    
    func dateFromBoothComponents(calendarCode: ASACalendarCode, era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, timeZone: TimeZone) -> Date? {
        guard isValidBoothCalendarDate(calendarCode: calendarCode, era: era, year: year, month: month, day: day) else { return nil }
        
        let julianDate: JulianDate = julianDateFrom(era: era, year: year, month: month, day: day)
        
        let secondsFromGMT = timeZone.secondsFromGMT()
        // TODO:  POINT OF INTERVENTION WHEN IMPLEMENTING DECIMAL TIME
        let secondsFromMidnight: Double = Double(60 * 60 * hour + 60 * minute + second) + Double(nanosecond) / 1000000000.0
        let date = Date.date(julianDate: julianDate).addingTimeInterval(TimeInterval(secondsFromGMT) + secondsFromMidnight)
        return date
    } // func dateFromJulianComponents(era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, timeZone: TimeZone) -> Date?

    fileprivate func dayOfYear(calendarCode: ASACalendarCode, era: Int, year: Int, month: Int, day: Int) -> Int {
        var dayOfYear = day
        if month > 1 {
            for m in 1..<month {
                let daysInMonth = daysInMonth(era: era, year: year, month: m)
                dayOfYear += daysInMonth
            }
        }
        return dayOfYear
    } // func dayOfYear(calendarCode: ASACalendarCode, era: Int, year: Int, month: Int, day: Int) -> Int

} // class ASABoothCalendar


// MARK: - Stuff I wrote above and beyond these

func astronomicalYear(era: Int, year: Int) -> Int? {
    switch era {
    case 0:
        return -(year - 1)
        
    case 1:
        return year
        
    default:
        return nil
    }
}


extension ASACalendarCode {
    var shouldUseAstronomicalYears: Bool {
        switch self {
        case .julian, .gregorian:
            return true
            
        default:
            return false
        } // switch self
    } // var shouldUseAstronomicalYears
} // extension ASACalendarCode

extension Int {
    var eraAndYearFromAstronomicalYear: (era: Int, year: Int) {
        if self > 0 {
            return (1, self)
        } else {
            return (0, 1 - self)
        }
    }
}

extension String {
    /// Removes weekday fields (E/e/c series) from an LDML date pattern,
    /// along with any immediately trailing punctuation or whitespace.
    /// Preserves LDML quoting rules and leaves all other fields intact.
    var removingWeekdayFromLDML: String {
        // Regex explanation:
        // 1. (?<!')'(?:''|[^'])*'  → Match a quoted literal; we keep it unchanged.
        // 2. (E{1,6}|e{1,6}|c{1,6}) → Any weekday field token.
        // 3. [\\p{P}\\s\\u202F]*     → Trailing punctuation/whitespace/NBSP.
        //
        // We process via a regex that alternates between literals and tokens.
        
        let regex = try! NSRegularExpression(
            pattern: "(?<!')'(?:''|[^'])*'|(E{1,6}|e{1,6}|c{1,6})[\\p{P}\\s\\u202F]*",
            options: []
        )
        
        let ns = self as NSString
        var result = ""
        var lastIndex = 0
        
        for match in regex.matches(in: self, range: NSRange(location: 0, length: ns.length)) {
            let range = match.range
            let token = ns.substring(with: range)
            
            // Append any gap between previous match and this one.
            if range.location > lastIndex {
                result += ns.substring(with: NSRange(location: lastIndex, length: range.location - lastIndex))
            }
            
            if token.hasPrefix("'") {
                // Quoted literal → copy verbatim
                result += token
            } else {
                // Weekday token + punctuation → remove entirely (append nothing)
            }
            
            lastIndex = range.location + range.length
        }
        
        // Append any trailing remainder
        if lastIndex < ns.length {
            result += ns.substring(with: NSRange(location: lastIndex, length: ns.length - lastIndex))
        }
        
        return result
    }
}
