//
//  ASAFrenchRepublicanCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import FrenchRepublicanCalendarCore

fileprivate let DAYS_PER_WEEK                       =  10
fileprivate let DAYS_PER_MONTH                      =  30
fileprivate let DAYS_IN_SANSCULOTTIDES              =   5
fileprivate let DAYS_IN_SANSCULOTTIDES_IN_LEAP_YEAR =   6
fileprivate let DAYS_IN_YEAR                        = 365
fileprivate let DAYS_IN_YEAR_IN_LEAP_YEAR           = 366

fileprivate let MONTHS_PER_YEAR = 13


public class ASAFrenchRepublicanCalendar:  ASACalendar, ASACalendarWithWeeks, ASACalendarWithMonths, ASACalendarWithBlankMonths, ASACalendarWithEras {
    var calendarCode: ASACalendarCode
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
    } // init(calendarCode:  ASACalendarCode)
    
    var canSplitTimeFromDate: Bool = true
    
    var defaultDateFormat: ASADateFormat = .fullWithRomanYear
    
    var defaultTimeFormat: ASATimeFormat = .decimal
    
    var supportedDateFormats: Array<ASADateFormat> = [.full, .fullWithRomanYear, .long, .longWithRomanYear, .short, .shortWithRomanYear]
    
    var supportedWatchDateFormats: Array<ASADateFormat> = [.full, .fullWithRomanYear, .long, .longWithRomanYear, .short, .shortWithRomanYear, .longWithoutYear, .mediumWithoutYear]
    
    var supportedTimeFormats: Array<ASATimeFormat> = [.decimal, .medium]
    
    var supportsLocales: Bool = true
        
    var supportsLocations: Bool = true
        
    var supportsTimes: Bool = true
    
    var supportsTimeZones: Bool = true
    
//    var transitionType: ASATransitionType = .midnight
    
    var usesISOTime: Bool = true
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        let FRCDate = FrenchRepublicanDate(date: now, dateFormat: dateFormat, timeZone: locationData.timeZone, calendarCode: self.calendarCode)
        
        let (dateString, timeString) = dateStringTimeString(now: now, FRCDate: FRCDate, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        return dateString + " " + timeString
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String
    
    var genericOptions: FrenchRepublicanDateOptions {
        let variant: FrenchRepublicanDateOptions.Variant = self.calendarCode == .FrenchRepublicanRomme ? .romme : .original
        return FrenchRepublicanDateOptions(romanYear: true, variant: variant, treatSansculottidesAsAMonth: true)
    }
    
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        let FRCDate = FrenchRepublicanDate(date: date, timeZone: locationData.timeZone)
        let components = FRCDate.components
        let FRCDateMidnight = FrenchRepublicanDate(dayInYear: FRCDate.dayInYear, year: components!.year!, hour: 0, minute: 0, second: 0, nanosecond: 0, options: nil, timeZone: locationData.timeZone)
        return FRCDateMidnight.date
    } // func startOfDay(for date: Date, locationData: ASALocation) -> Date
    
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        let startOfDay = self.startOfDay(for: date, locationData: locationData)
        return startOfDay.oneDayAfter
    } // func startOfNextDay(date: Date, locationData: ASALocation) -> Date
    
    func supports(calendarComponent: ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era:
            return false
        case .year:
            return true
        case .yearForWeekOfYear:
            return false
        case .quarter:
            return true
        case .month:
            return true
        case .weekOfYear:
            return false
        case .weekOfMonth:
            return true
        case .weekday:
            return true
        case .weekdayOrdinal:
            return false
        case .day, .hour, .minute, .second, .nanosecond:
            return true
        case .fractionalHour, .dayHalf:
            return false
        case .calendar, .timeZone:
            return true
        } // switch calendarComponent
    } // func supports(calendarComponent: ASACalendarComponent) -> Bool
    
    private var dateFormatter = DateFormatter()
    private var formatter = NumberFormatter()

    fileprivate func stringFromInteger(_ integerValue: Int, minimumIntegerDigits: Int, isRoman: Bool) -> String {
        if isRoman {
            return integerValue.RomanNumeral
        }
        
        formatter.minimumIntegerDigits = minimumIntegerDigits
        let symbol = self.formatter.string(from: NSNumber(value: integerValue))!
        return symbol
    }
    
    let datePatternComponentCache = NSCache<NSString, NSArray>()
    
    fileprivate func dateString(FRCDate: FrenchRepublicanDate, localeIdentifier: String, dateFormat: ASADateFormat) -> String {
        var dateFormatPattern: String
        let languageCode = localeIdentifier.localeLanguageCode
        
        if languageCode == "fr" || languageCode == nil {
            switch dateFormat {
            case .none:
                dateFormatPattern = ""
                
            case .short, .shortWithRomanYear, .shortWithWeekday:
                dateFormatPattern = FRCDate.toShortenedString()
                
            case .long, .longWithRomanYear:
                dateFormatPattern = FRCDate.toLongString()
                
            case .longWithoutYear:
                dateFormatPattern = FRCDate.toLongStringNoYear()
                
            case .mediumWithoutYear:
                dateFormatPattern = FRCDate.toShortString()
                
            default:
                dateFormatPattern = FRCDate.toVeryLongString()
            }  // switch dateFormat
            
            return dateFormatPattern
        } else {
            self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: .none, timeZone: TimeZone.current)
            self.dateFormatter.apply(dateFormat: dateFormat)
            dateFormatPattern = self.dateFormatter.dateFormat ?? ""
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
                    let year = FRCDate.components.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 1, isRoman: dateFormat.isRomanYear)
                    
                case "yy", "YY", "uu", "UU":
                    let year = FRCDate.components.year!
                    let revisedYear = year % 100
                    symbol = stringFromInteger(revisedYear, minimumIntegerDigits: 2, isRoman: dateFormat.isRomanYear)

                case "yyy", "YYY", "uuu", "UUU":
                    let year = FRCDate.components.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 3, isRoman: dateFormat.isRomanYear)
                    
                case "yyyy", "YYYY", "uuuu", "UUUU":
                    let year = FRCDate.components.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 4, isRoman: dateFormat.isRomanYear)

                case "yyyyy", "YYYYY", "uuuuu", "UUUUU":
                    let year = FRCDate.components.year!
                    symbol = stringFromInteger(year, minimumIntegerDigits: 5, isRoman: dateFormat.isRomanYear)
                    
                case "Q", "QQ", "q", "qq", "QQQQQ", "qqqqq":
                    let quarter = FRCDate.components.quarter!
                    symbol = stringFromInteger(quarter, minimumIntegerDigits: 2, isRoman: false)
                    
                case "QQQ":
                    let quarter = FRCDate.components.quarter!
                    let symbols = self.shortQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]

                case "QQQQ":
                    let quarter = FRCDate.components.quarter!
                    let symbols = self.quarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]

                case "qqq":
                    let quarter = FRCDate.components.quarter!
                    let symbols = self.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]

                case "qqqq":
                    let quarter = FRCDate.components.quarter!
                    let symbols = self.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]

                case "M", "MM":
                    let month = FRCDate.components.month!
                    symbol = stringFromInteger(month, minimumIntegerDigits: 2, isRoman: false)
                    
                case "MMM":
                    let symbols = self.shortMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.month! - 1]

                case "MMMM":
                    let symbols = self.monthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.month! - 1]

                case "MMMMM":
                    let symbols = self.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.month! - 1]
                    
                case "L", "LL":
                    let month = FRCDate.components.month!
                    symbol = stringFromInteger(month, minimumIntegerDigits: 2, isRoman: false)
                    
                case "LLL":
                    let symbols = self.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.month! - 1]

                case "LLLL":
                    let symbols = self.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.month! - 1]

                case "LLLLL":
                    let symbols = self.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.month! - 1]
                    
                case "l":
                    symbol = "" // Really.  That’s what the spec says.
                    
                case "d":
                    let day = FRCDate.components.day!
                    symbol = stringFromInteger(day, minimumIntegerDigits: 1, isRoman: false)

                case "dd":
                    let day = FRCDate.components.day!
                    symbol = stringFromInteger(day, minimumIntegerDigits: 2, isRoman: false)
                    
                case "D":
                    let dayInYear = FRCDate.dayInYear
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 1, isRoman: false)

                case "DD":
                    let dayInYear = FRCDate.dayInYear
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 2, isRoman: false)

                case "DDD":
                    let dayInYear = FRCDate.dayInYear
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 3, isRoman: false)

                case "E", "EE", "EEE", "eee":
                    let symbols = self.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.weekday! - 1]

                case "EEEE", "eeee":
                    let symbols = self.weekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.weekday! - 1]

                case "EEEEE", "eeeee":
                    let symbols = self.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.weekday! - 1]
                    
                case "e", "c":
                    let dayOfWeek = FRCDate.components.weekday!
                    symbol = stringFromInteger(dayOfWeek, minimumIntegerDigits: 1, isRoman: false)

                case "ee", "cc":
                    let dayOfWeek = FRCDate.components.weekday!
                    symbol = stringFromInteger(dayOfWeek, minimumIntegerDigits: 2, isRoman: false)
                    
                case "ccc":
                    let symbols = self.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.weekday! - 1]

                case "cccc":
                    let symbols = self.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.weekday! - 1]

                case "ccccc":
                    let symbols = self.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[FRCDate.components.weekday! - 1]

                case "w", "ww", "W", "WW", "F", "g", "gg", "ggg", "gggg", "ggggg", "r", "rr", "rrr", "rrrr", "rrrrr": // TODO:  Implement these!
                    symbol = "<\(component.string)>"
                    
                default:
                    symbol = "<\(component.string)>"
                }
                result.append(symbol)
            } // switch component.type
        } // for component in components
        
        return result
    } // func dateString(FRCDate: FrenchRepublicanDate, localeIdentifier: String, dateFormat: ASADateFormat) -> String
    
    fileprivate func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        var timeString: String
        switch timeFormat {
        case .none:
            timeString = ""
        case .medium:
            let timeZone = locationData.timeZone
            self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: timeFormat, timeZone: timeZone)
            self.dateFormatter.dateStyle = .none
            timeString = self.dateFormatter.string(from: now)

        case .decimal:
            let decimalTime = DecimalTime(base: now, timeZone: locationData.timeZone)
            let languageCode = localeIdentifier.localeLanguageCode
            if languageCode == "fr" || languageCode == nil {
                timeString = decimalTime.hourMinuteSecondsFormatted
            } else {
                self.dateFormatter.timeStyle = .medium // As of this writing, only the medium time style (more or less) is supported.
                self.dateFormatter.dateStyle = .none
                let timeFormatPattern = self.dateFormatter.dateFormat ?? ""
                let components = timeFormatPattern.dateFormatPatternComponents
                        var result = ""
                        formatter.locale = Locale(identifier: localeIdentifier)

                for component in components {
                    switch component.type {
                    case .literal:
                        result.append(component.string)
                        
                    case .symbol:
                        var symbol = ""
                        switch component.string {
                        case "a", "aa", "aaa", "aaaa", "aaaaa", "b", "bb", "bbb", "bbbb", "bbbbb", "B", "BB", "BBB", "BBBB", "BBBBB":
                            symbol = "" // The French Republican Calendar does not divide the day into two periods.
                            
                        case "h", "hh", "H", "HH", "k", "kk", "K", "KK", "j", "jj", "jjj", "jjjj", "jjjjj", "jjjjjj", "J", "JJ", "C", "CC", "CCC", "CCCC", "CCCCC", "CCCCCC":
                            let hour = decimalTime.hour
                            symbol = stringFromInteger(hour, minimumIntegerDigits: 1, isRoman: false)
                            
                        case "m":
                            let minute = decimalTime.minute
                            symbol = stringFromInteger(minute, minimumIntegerDigits: 1, isRoman: false)

                        case "mm":
                            let minute = decimalTime.minute
                            symbol = stringFromInteger(minute, minimumIntegerDigits: 2, isRoman: false)

                        case "s":
                            let second = decimalTime.second
                            symbol = stringFromInteger(second, minimumIntegerDigits: 1, isRoman: false)

                        case "ss":
                            let second = decimalTime.second
                            symbol = stringFromInteger(second, minimumIntegerDigits: 2, isRoman: false)
                            
                        case "S", "SS", "SSS", "SSSS", "A", "AA", "AAA", "AAAA":
                            symbol = component.string // TODO:  Implement these?
                            
                        case "z", "zz", "zzz", "zzzz", "Z", "ZZ", "ZZZ", "ZZZZ", "ZZZZZ", "O", "OOOO", "v", "vvvv", "V", "VV", "VVV", "VVVV", "X", "XX", "XXX", "XXXX", "XXXXX", "x", "xx", "xxx", "xxxx", "xxxxx":
                            symbol = "" // Time zone is not handled here.

                        default:
                            symbol = component.string
                        }
                        result.append(symbol)
                    } // switch component.type
                } // for component in components
                
                return result
            }

            default:
            timeString = ""
        } // switch timeFormat
        
        return timeString
    } // func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData: ASALocation) -> String
    
    func dateStringTimeString(now: Date, FRCDate: FrenchRepublicanDate, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String) {
        let dateString: String = dateString(FRCDate: FRCDate, localeIdentifier: localeIdentifier, dateFormat: dateFormat)
        let timeString: String = timeString(now: now, localeIdentifier: localeIdentifier, timeFormat: timeFormat, locationData: locationData)
        
        return (dateString, timeString)
    } // func dateStringTimeStringDate(now: Date, FRCDate: FrenchRepublicanDate, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String)

    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let FRCDate = FrenchRepublicanDate(date: now, dateFormat: dateFormat, timeZone: locationData.timeZone, calendarCode: self.calendarCode)

        let components = FRCDate.dateComponents(locationData: locationData, calendar: self)
        
        let (dateString, timeString) = dateStringTimeString(now: now, FRCDate: FRCDate, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        
        return (dateString, timeString, components)
    } // func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let month = dateComponents.month ?? -1
        if month < 1 || month > MONTHS_PER_YEAR {
            return false
        }
        
        let day = dateComponents.day ?? -1
        switch month {
        case 1...12:
            if day < 1 || day > DAYS_PER_MONTH {
                return false
            }
            
        case 13:
            let dayInYear = (dateComponents.month! - 1) * DAYS_PER_MONTH + (dateComponents.day! - 1)
            let FRCDate = FrenchRepublicanDate(dayInYear: dayInYear, year: dateComponents.year!, hour: 0, minute: 0, second: 0, nanosecond: 0, options: genericOptions, timeZone: nil)
            let isSextilYear = FRCDate.isYearSextil
            
            if day < 1 || day > (isSextilYear ? DAYS_IN_SANSCULOTTIDES_IN_LEAP_YEAR : DAYS_IN_SANSCULOTTIDES) {
                return false
            }
            
        default:
            return false
        } // switch month
        
        // TODO:  Worry about time components.
        
        return true
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        guard let year = dateComponents.year else {
            return nil
        }
        guard let month = dateComponents.month else {
            return nil
        }
        guard let day = dateComponents.day else {
            return nil
        }
        let dayInYear = (month - 1) * DAYS_PER_MONTH + (day - 1)
        
        let FRCDate = FrenchRepublicanDate(dayInYear: dayInYear, year: year, hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second, nanosecond: dateComponents.nanosecond, options: genericOptions, timeZone: dateComponents.locationData.timeZone)
        return FRCDate.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
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
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        let FRCDate = FrenchRepublicanDate(date: date, options: genericOptions, timeZone: locationData.timeZone)
        let components = FRCDate.dateComponents(locationData: locationData, calendar: self)
        return components // TODO:  Cleanup!
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents
    
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        switch component {
        case .era:
            return Range(0...0)
        case .year:
            return Range(15300...15300)
        case .yearForWeekOfYear:
            return Range(15300...15300)
        case .quarter:
            return Range(5...5)
        case .month:
            return Range(MONTHS_PER_YEAR...MONTHS_PER_YEAR)
        case .weekOfYear:
            return Range(53...53)
        case .weekOfMonth:
            return Range(4...4)
        case .weekday:
            return Range(DAYS_PER_WEEK...DAYS_PER_WEEK)
        case .weekdayOrdinal:
            return Range(9...9)
        case .day:
            return Range(DAYS_PER_MONTH...DAYS_PER_MONTH)
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
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
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
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        return nil // TODO:  Fill in!
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        let FRCDate = FrenchRepublicanDate(date: date, options: genericOptions, timeZone: nil)
        let isSextilYear = FRCDate.isYearSextil
        switch larger {
        case .year:
            switch smaller {
            case .month:
                return Range(1...MONTHS_PER_YEAR)
                
            case .day:
                return isSextilYear ? Range(1...DAYS_IN_YEAR_IN_LEAP_YEAR) : Range(1...DAYS_IN_YEAR)

            default:
                return nil
            } // switch smaller
            
        case .month:
            switch smaller {
            case .day:
                let month = FRCDate.components.month ?? -1
                if 1 <= month && month <= 12 {
                    return Range(1...DAYS_PER_MONTH)
                } else if month == 13 {
                    return isSextilYear ? Range(1...DAYS_IN_SANSCULOTTIDES_IN_LEAP_YEAR) : Range(1...DAYS_IN_SANSCULOTTIDES)
                } else {
                    return nil
                }
                
            default:
                return nil
            } // switch smaller
            
        default:
            return nil
        } // switch larger
    }
    
    var daysPerWeek: Int = DAYS_PER_WEEK
    
    
    // MARK:  - Time zone-dependent modified Julian day
    
    func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int {
        let timeZone = locationData.timeZone
        return date.localModifiedJulianDay(timeZone: timeZone)
        
        // TODO:  May need to modify this
    } // func localModifiedJulianDay(date: Date, timeZone: TimeZone) -> Int
    
    
    // MARK:  - ASACalendarWithWeeks
    
    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["יום ראשון", "יום שני", "יום שלישי", "יום רביעי", "יום חמישי", "יום שישי", "יום שביעי", "יום שמיני", "יום תשעי", "יום עשירי"]

        case "ar":
            return ["بريميد", "توديدي", "تريدي", "كارتيدي", "كارتيدي", "سكستيدي", "ستيدي", "أوكتيدي", "نونيدي", "ديكادي"]

        default:
            return ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
        } // switch localeIdentifier.localeLanguageCode
    }
    
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["יום א׳", "יום ב׳", "יום ג׳", "יום ד׳", "יום ה׳", "יום ו׳", "יום ז׳", "יום ח׳", "יום ט׳", "יום י׳"]
            
        case "ar":
            return ["بريميد", "توديدي", "تريدي", "كارتيدي", "كارتيدي", "سكستيدي", "ستيدي", "أوكتيدي", "نونيدي", "ديكادي"]

            
        default:
            return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
        } // switch localeIdentifier.localeLanguageCode
    }
    
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["א׳", "ב׳", "ג׳", "ד׳", "ה׳", "ו׳", "ז׳", "ח׳", "ט׳", "י׳"]
            
        default:
//            return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
            return self.weekdaySymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
        } // switch localeIdentifier.localeLanguageCode
    }
    
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        [5, 10]
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK:  -
    
    func miniCalendarNumberFormat(locale: Locale) -> ASANumberFormat {
        return .system
    } // func miniCalendarNumberFormat(locale: Locale) -> ASANumberFormat
    
    
    // MARK:  - ASACalendarWithMonths
    
    func monthSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["ונדמייר", "בּרויּמֶר", "פרִימֶר", "ניבוז", "פּלויּביוז", "ונטוז", "ז׳רמינאל", "פלוראל", "פּרריאל", "מסידור", "תרמידור", "פרוקטידור", "עיבור השנה"]
            
        case "ar":
            return ["فنديميير", "برومير", "فريمير", "نيفوز", "بلوفيوز", "فنتوز", "جرمينال", "فلوريال", "بريريال", "ميسيدور", "تيرميدور", "فروكتيدور", "الأيام الستة في نهاية السنة"]

        default:
            return ["Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse", "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor", "Sansculottides"]
        } // case localeIdentifier.localeLanguageCode
    }
    
    func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["ונד׳", "בּרו׳", "פרִי׳", "ניב׳", "פּלו׳", "ונט׳", "ז׳רמ׳", "פלו׳", "פּרר׳", "מסי׳", "תרמ׳", "פרו׳", "עה״ש"]

        default:
            return ["Vend.r", "Brum.r", "Frim.r", "Niv.ô", "Pluv.ô", "Vent.ô", "Germ.l", "Flo.l", "Prai.l", "Mes.or", "Ther.or", "Fru.or", "Ss.cu"]
        } // case localeIdentifier.localeLanguageCode
    }
    
    func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
    }
    
    func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.monthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.shortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK:  - ASACalendarWithQuarters
    
    func quarterSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "he":
            return ["סתיו", "חורף", "אביב", "קיץ", "עיבור השנה"]
          
        case "ar":
            return ["الخريف", "الشتاء", "الربيع", "الصيف", "الأيام الستة في نهاية السنة"]

        case "en":
            return ["Autumn", "Winter", "Spring", "Summer", "Sansculottides"]
        
        default:
        return ["Automne", "Hiver", "Printemps", "Été", "Sansculottides"]
        } // switch localeIdentifier.localeLanguageCode
    }
    
    func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4", "Q5"]
    }
    
    func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.quarterSymbols(localeIdentifier: localeIdentifier)    }
    
    func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK:  - ASACalendarWithEras
    
    func eraSymbols(localeIdentifier: String) -> Array<String> {
        return [""]
    }
    
    func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return [""]
    }

 
    
    // MARK:  - ASACalendarWithBlankMonths
    
    var blankMonths: Array<Int> = [13]
    
    var blankWeekdaySymbol: String = "∅"
    
    
    // MARK: - Cycles
    
    func cycleNumberFormat(locale: Locale) -> ASANumberFormat {
        return .system
    } // func cycleNumberFormat(locale: Locale) -> ASANumberFormat
} // class ASAFrenchRepublicanCalendar
