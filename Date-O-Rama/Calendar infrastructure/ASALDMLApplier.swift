//
//  ASALDMLApplier.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/12/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

struct ASALDMLApplier {
    
    private var dateFormatter = DateFormatter()
    private var formatter     = NumberFormatter()
    
    fileprivate func stringFromInteger(_ integerValue: Int, minimumIntegerDigits: Int) -> String {
        formatter.minimumIntegerDigits = minimumIntegerDigits
        let symbol = self.formatter.string(from: NSNumber(value: integerValue))!
        return symbol
    } // fileprivate func stringFromInteger(_ integerValue: Int, minimumIntegerDigits: Int) -> String
    
    let datePatternComponentCache = NSCache<NSString, NSArray>()
    
    func dateString(ldmlCalendar: ASALDMLCalendar, dateComponents: ASADateComponents, localeIdentifier: String, dateFormat: ASADateFormat) -> String {
        var calendar = ldmlCalendar
        
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
                    let symbols = calendar.eraSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[0]
                    
                case "GGGG":
                    let symbols = calendar.longEraSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[0]
                    
                case "GGGGG":
                    let symbols = calendar.eraSymbols(localeIdentifier: localeIdentifier)
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
                    let symbols = calendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "QQQQ":
                    let quarter = dateComponents.quarter!
                    let symbols = calendar.quarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "qqq":
                    let quarter = dateComponents.quarter!
                    let symbols = calendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "qqqq":
                    let quarter = dateComponents.quarter!
                    let symbols = calendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[quarter - 1]
                    
                case "M", "MM":
                    let month = dateComponents.month!
                    symbol = stringFromInteger(month, minimumIntegerDigits: 2)
                    
                case "MMM":
                    let symbols = calendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "MMMM":
                    let symbols = calendar.monthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "MMMMM":
                    let symbols = calendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "L", "LL":
                    let month = dateComponents.month!
                    symbol = stringFromInteger(month, minimumIntegerDigits: 2)
                    
                case "LLL":
                    let symbols = calendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "LLLL":
                    let symbols = calendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
                    symbol = symbols[dateComponents.month! - 1]
                    
                case "LLLLL":
                    let symbols = calendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
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
                    //                    let era = dateComponents.era!
                    //                    let dayInYear = dayOfYear(calendarCode: dateComponents.calendar.calendarCode, era: era, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    let dayInYear = -1 // TODO:  Day in year
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 1)
                    
                case "DD":
                    //                    let era = dateComponents.era!
                    //                    let dayInYear = dayOfYear(calendarCode: dateComponents.calendar.calendarCode, era: era, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    let dayInYear = -1 // TODO:  Day in year
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 2)
                    
                case "DDD":
                    //                    let era = dateComponents.era!
                    //                    let dayInYear = dayOfYear(calendarCode: dateComponents.calendar.calendarCode, era: era, year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                    let dayInYear = -1 // TODO:  Day in year
                    symbol = stringFromInteger(dayInYear, minimumIntegerDigits: 3)
                    
                case "E", "EE", "EEE", "eee":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = calendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "EEEE", "eeee":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = calendar.weekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "EEEEE", "eeeee":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = calendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
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
                        let symbols = calendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "cccc":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = calendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
                        symbol = symbols[dateComponents.weekday! - 1]
                    }
                    
                case "ccccc":
                    if dateComponents.weekday! == 0 {
                        symbol = "_"
                    } else {
                        let symbols = calendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
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
    } // func dateString(ldmlCalendar: ASALDMLCalendar, dateComponents: ASADateComponents, localeIdentifier: String, dateFormat: ASADateFormat) -> String
    
    func timeString(ldmlCalendar: ASALDMLCalendar, dateComponents: ASADateComponents, localeIdentifier: String, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        var calendar = ldmlCalendar
        
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
                    if ldmlCalendar is ASACalendarWithAMAndPM {
                        let rawHour = dateComponents.hour!
                        if rawHour < 12 {
                            symbol = (ldmlCalendar as! ASACalendarWithAMAndPM).amSymbol(localeIdentifier: localeIdentifier)
                        } else {
                            symbol = (ldmlCalendar as! ASACalendarWithAMAndPM).pmSymbol(localeIdentifier: localeIdentifier)
                        }
                    } else {
                        symbol = ""
                    }
                    
                case "h", "hh":
                    let hour: Int = {
                    let temp = dateComponents.hour!
                        if temp == 0 {
                            return 12
                        } else if temp > 12 {
                            return temp - 12
                        } else {
                            return 12
                        }
                    }()
                    symbol = stringFromInteger(hour, minimumIntegerDigits: component.string.count)
                    
                case "H", "HH":
                    let hour = dateComponents.hour!
                    symbol = stringFromInteger(hour, minimumIntegerDigits: component.string.count)
                
                case "k", "kk", "K", "KK", "j", "jj", "jjj", "jjjj", "jjjjj", "jjjjjj", "J", "JJ", "C", "CC", "CCC", "CCCC", "CCCCC", "CCCCCC":
                    let hour = dateComponents.hour!
                    symbol = stringFromInteger(hour, minimumIntegerDigits: 1) // Skeleton

                case "m":
                    let minute = dateComponents.minute!
                    symbol = stringFromInteger(minute, minimumIntegerDigits: 1)
                    
                case "mm":
                    let minute = dateComponents.minute!
                    symbol = stringFromInteger(minute, minimumIntegerDigits: 2)
                    
                case "s":
                    let second = dateComponents.second!
                    symbol = stringFromInteger(second, minimumIntegerDigits: 1)
                    
                case "ss":
                    let second = dateComponents.second!
                    symbol = stringFromInteger(second, minimumIntegerDigits: 2)
                    
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
        
    } // func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
}
