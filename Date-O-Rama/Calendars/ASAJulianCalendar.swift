//
//  ASAJulianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

public class ASAJulianCalendar:  ASACalendar, ASACalendarSupportingWeeks, ASACalendarSupportingMonths, ASACalendarSupportingEras {
    init() {
        self.calendarCode = .Julian
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
                    let dayInYear = dayOfYear(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 1)

                case "DD":
                    let dayInYear = dayOfYear(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 2)

                case "DDD":
                    let dayInYear = dayOfYear(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 3)

                case "E", "EE", "EEE", "eee":
                    let symbols = self.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.weekday! - 1]

                case "EEEE", "eeee":
                    let symbols = self.weekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.weekday! - 1]

                case "EEEEE", "eeeee":
                    let symbols = self.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.weekday! - 1]
                    
                case "e", "c":
                    let dayOfWeek = dateComponents.weekday!
                    symbol = stringFromInteger(dayOfWeek, minimumIntegerDigits: 1)

                case "ee", "cc":
                    let dayOfWeek = dateComponents.weekday!
                    symbol = stringFromInteger(dayOfWeek, minimumIntegerDigits: 2)
                    
                case "ccc":
                    let symbols = self.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.weekday! - 1]

                case "cccc":
                    let symbols = self.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.weekday! - 1]

                case "ccccc":
                    let symbols = self.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.weekday! - 1]

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
        self.dateFormatter.calendar = GregorianCalendar
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: timeFormat, timeZone: locationData.timeZone)
        self.dateFormatter.apply(dateFormat: .none)
        return self.dateFormatter.string(from: now)
    } // func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
    
    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let rawComponents = JulianComponents(date: now, timeZone: locationData.timeZone)
        
        let year: Int    = rawComponents.year
        let month: Int   = rawComponents.month
        let day: Int     = rawComponents.day
        let weekday: Int = rawComponents.weekday
        let isLeapMonth  = isLeapMonth(month: month, year: year)
        var quarter: Int?
        switch month {
        case 1, 2, 3:
            quarter = 1
            
        case 4, 5, 6:
            quarter = 2
            
        case 7, 8, 9:
            quarter = 3
            
        case 10, 11, 12:
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
    
    private lazy var GregorianCalendar = Calendar.gregorian
    
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        GregorianCalendar.timeZone = locationData.timeZone
        return GregorianCalendar.startOfDay(for: date)
    } // func startOfDay(for date: Date, locationData: ASALocation) -> Date
    
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        GregorianCalendar.timeZone = locationData.timeZone
        return GregorianCalendar.startOfDay(for: date.oneDayAfter)
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
        
        return isValidJulianDate(era: era, year: year, month: month, day: day)
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        guard let era = dateComponents.era, let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else { return nil }
        let timeZone = dateComponents.locationData.timeZone
        let result = dateFromJulianComponents(era: era, year: year, month: month, day: day, hour: dateComponents.hour ?? 0, minute: dateComponents.minute ?? 0, second: dateComponents.second ?? 0, nanosecond: dateComponents.nanosecond ?? 0, timeZone: timeZone)
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
    
    fileprivate func isLeapMonth(month: Int, year: Int) -> Bool {
        return month == 2 && year.isLeapYear
    }
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        let timeZone = locationData.timeZone
        let JulianComponents = JulianComponents(date: date, timeZone: timeZone)
        let era = JulianComponents.era
        let year = JulianComponents.year
        let month: Int = JulianComponents.month
        let weekday = day_of_week(year: JulianComponents.year, mo: month, day: JulianComponents.day)
        let isLeapMonth = isLeapMonth(month: month, year: year)
        let day: Int = JulianComponents.day
        let components = ASADateComponents(calendar: self, locationData: locationData, era: era, year: year, month: JulianComponents.month, isLeapMonth: isLeapMonth, weekday: weekday, day: day, hour: nil, minute: nil, second: nil, nanosecond: nil)
        return components
    }
    
    let MONTHS_PER_YEAR = 12
    let DAYS_PER_WEEK   =  7
    
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
            return Range(MONTHS_PER_YEAR...MONTHS_PER_YEAR)
        case .weekOfYear:
            return Range(53...53)
        case .weekOfMonth:
            return Range(5...5)
        case .weekday:
            return Range(DAYS_PER_WEEK...DAYS_PER_WEEK)
        case .weekdayOrdinal:
            return Range(6...6)
        case .day:
            return Range(31...31)
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
            return Range(1...1)
        case .minute:
            return Range(1...1)
        case .second:
            return Range(1...1)
        case .nanosecond:
            return Range(1...1)
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
                return Range(1...MONTHS_PER_YEAR)
                
            case .day:
                let isLeapYear = components.year?.isLeapYear ?? false
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
                let year = components.year ?? -1
                return Range(1...daysForMonthInJulianDate(year: year, month: month))
                
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
    
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat {
        .system
    }
    
    var daysPerWeek: Int = 7
    
    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.weekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return self.GregorianCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        self.GregorianCalendar.weekendDays(for: regionCode)
    }
    
    func monthSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.monthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
        
    func eraSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.eraSymbols(localeIdentifier: localeIdentifier)
    }
    
    func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.longEraSymbols(localeIdentifier: localeIdentifier)
    }
    
    var calendarCode: ASACalendarCode
    
    func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.quarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.GregorianCalendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
} // class ASAJulianCalendar


// MARK: - Low-level functions

// Based on “Algorithms for Julian Dates” by Richard L. Branham, Jr. (https://dl.acm.org/doi/pdf/10.1145/219340.219343).
// Comments are left intact to make it easier to figure out what is going on.

/// Routine to calculate a Julian day number for a year, month, and day given on the Julian calendar. Dates B.C. should be expressed in astronomical format (i.e.) dateB.C. = -(date - 1). Thus, 747B.C. = -746. Input to routine are the year, month, and day expressed as integers; output is the Julian day number as a double-precision floating-point number.
/// - Parameters:
///   - year: Year
///   - mo: Month
///   - day: Day
/// - Returns: A Double encoding the Julian date
func julian(year: Int, mo: Int, day: Int) -> Double {
    var jd: Double
    var sum = 0
    var begin_year: Int
    
    /* Correct for difference between astronomical and civil time */
    var dayAsDouble: Double = Double(day)
    dayAsDouble -= 0.5
    /* Calculate Julian day number for the beginning of the year. */
    begin_year = ((1461*(4712 + year) - 1)/4)
    jd = Double(begin_year)
    if (year == -4712) {
        jd -= 1
    }
    /* Add the number of days in the month */
    jd += dayAsDouble
    /* Sum the number of days in the preceding months */
    for i in 1..<mo {
        if (i == 2) {
            sum += 28
        } else {
            if i == 4 || i == 6 || i == 9 || i == 11 {
                sum += 30
            } else {
                sum += 31
            }
        }
    }
    jd += Double(sum)
    
    /* Add one more day if a leap year */
    if (mo > 2 && (4 * (year / 4) - year ) == 0 ) {
        jd += 1
    }
    return jd
} // func julian(year: Int, mo: Int, day: Int) -> Double

/// Function to take a Julian date and convert it to a day, month and year on the Julian calendar. The program or function that calls this routine must pass the addresses of the integer variables yr (year) and mo (month) and the double-precision variable day.
/// - Parameter jd: Julian date
/// - Returns: A tuple containing the equivalent year, month, and day on the Julian calendar
func julian_ymd(jd: Double) -> (yr: Int, mo: Int, day: Double) {
    var begin_year: Int
    var jdhold: Double
    var yr: Int
    var mo: Int
    var day: Double
    
    if (fabs(jd) < 1e-15) { /* Consider JD 0 a special case */
        yr = -4712;
        mo = 1
        day = 0.5
        return (yr, mo, day)
    }
    
    jdhold = jd;
    /* Find number of Julian years in the Julian date */
    var JulianDate = jd
    JulianDate /= 365.25
    JulianDate -= 4712.0 // Subtract origin of Julian date
    /* Calculate the year */
    yr = Int(JulianDate);
    if (JulianDate < 0.0) {
        yr -= 1
    }
    /* Find Julian day number of beginning of year */
    begin_year = (1461 * (4712 + yr) - 1) / 4
    /* Find number of days since beginning of year */
    day = jdhold - Double(begin_year) + 0.5
    mo = 1  /* Calculate the month and day */
    if (day > 31.0) {
        while(day > 31.0) {
            if (mo == 2) {
                if (yr % 4 == 0) {
                    day -= 29.0
                } else {
                    day -= 28.0
                }
            } else {
                if (mo == 4 || mo == 6 || mo == 9 || mo == 11) {
                    day -= 30.0
                } else {
                    day -= 31.0
                }
            }
            mo += 1
        }
    }
    return (yr, mo, day)
} // func julian_ymd(jd: Double) -> (yr: Int, mo: Int, day: Double)

/// Function to calculate the day of the week that corresponds with a day, month, and year on the Julian calendar. The routine returns a pointer to a string. The calling program or function should declare a pointer-to-string variable to receive the value return.
/// - Parameters:
///   - inYear: Year
///   - inMo: Month
///   - day: Day
/// - Returns: Day of the week (1 = Sunday, 2 = Monday, 3 = Tuesday, etc.)
func day_of_week(year inYear: Int, mo inMo: Int, day: Int) -> Int {
    var year = inYear
    var mo   = inMo
    
    var m: Int
    var n: Int
    year += 4732 /* Make all years positive */
    if (mo == 1 || mo == 2) { /* January and February are months 13 and 14 of the preceding year */
        mo += 12
        year -= 1
    }
   /* Calculate a parameter "n" that gives the day of the week */
    m = day + 2 * mo + (3 * mo + 3) / 5 + year + year / 4 + 6
    n = m % 7 + 1
    assert(n >= 1)
    assert(n <= 7)
    return n
} // func day_of_week(year inYear: Int, mo inMo: Int, day: Int) -> Int


// MARK: - Stuff I wrote above and beyond these

extension Int {
    var isLeapYear: Bool {
        return self % 4 == 0
    }
    
    var is30DayMonth: Bool {
        return self == 4 || self == 6 || self == 9 || self == 11
    }
    
    var eraAndYearFromAstronomicalYear: (era: Int, year: Int) {
        if self > 0 {
            return (1, self)
        } else {
            return (0, 1 - self)
        }
    }
}

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

func JulianComponents(date: Date, timeZone: TimeZone) -> (era: Int, year: Int, month: Int, day: Int, weekday: Int, hour: Int, minute: Int, second: Int, nanosecond: Int) {
    var dateAsJulianDate = date.addingTimeInterval(-18.0 * 60.0 * 60.0 - Double(timeZone.secondsFromGMT(for: date))).JulianDate
    
    var GregorianCalendar = Calendar.gregorian
    GregorianCalendar.timeZone = timeZone
    let GregorianComponents = GregorianCalendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
    if GregorianComponents.hour == 0 && GregorianComponents.minute == 0 && GregorianComponents.second == 0 && GregorianComponents.nanosecond == 0 {
        dateAsJulianDate += 1
    }
    
    let JulianComponents = julian_ymd(jd: dateAsJulianDate)
    let day: Int = Int(ceil(JulianComponents.day))
    let astronomicalYear: Int = JulianComponents.yr
    let JulianDayOfWeek = day_of_week(year: astronomicalYear, mo: JulianComponents.mo, day: day)
    let (era, year) = astronomicalYear.eraAndYearFromAstronomicalYear
    return (era, year, JulianComponents.mo, Int(ceil(JulianComponents.day)), JulianDayOfWeek, GregorianComponents.hour!, GregorianComponents.minute!, GregorianComponents.second!, GregorianComponents.nanosecond!)
} // func JulianComponents(date: Date, timeZone: TimeZone) -> (era: Int, year: Int, month: Int, day: Int, weekday: Int)

func daysForMonthInJulianDate(year: Int, month: Int) -> Int {
    if month.is30DayMonth {
        return 30
    } else if month == 2 {
        return year.isLeapYear ? 29 : 28
    } else {
        return 31
    }
}

func isValidJulianDate(era: Int, year: Int, month: Int, day: Int) -> Bool {
    guard era >= 0 else { return false }
    guard era <= 1 else { return false }
    
    guard month >=  1 else { return false }
    guard month <= 12 else { return false }
    
    if day < 1 {
        return false
    }
    
    let daysInMonth = daysForMonthInJulianDate(year: year, month: month)
    if day > daysInMonth {
        return false
    }
    
    return true
}

func dateFromJulianComponents(era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, timeZone: TimeZone) -> Date? {
    guard isValidJulianDate(era: era, year: year, month: month, day: day) else { return nil }
    guard let astronomicalYear = astronomicalYear(era: era, year: year) else { return nil }
    let JulianDate = julian(year: astronomicalYear, mo: month, day: day)
    let secondsFromGMT = timeZone.secondsFromGMT()
    let secondsFromMidnight: Double = Double(60 * 60 * hour + 60 * minute + second) + Double(nanosecond) / 1000000000.0
    let date = Date.date(JulianDate: JulianDate).addingTimeInterval(TimeInterval(secondsFromGMT) + secondsFromMidnight)
    return date
} // func dateFromJulianComponents(era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, timeZone: TimeZone) -> Date?

fileprivate func dayOfYear(year: Int, month: Int, day: Int) -> Int {
    var dayOfYear = day
    if month > 1 {
        for m in 1..<month {
            let daysInMonth = daysForMonthInJulianDate(year: year, month: m)
            dayOfYear += daysInMonth
        }
    }
    return dayOfYear
}
