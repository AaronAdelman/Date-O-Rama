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


public class ASAFrenchRepublicanCalendar:  ASACalendar, ASACalendarSupportingBlankMonths, ASACalendarSupportingWeeks {
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
    
    var transitionType: ASATransitionType = .midnight
    
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
    
    func dateStringTimeString(now: Date, FRCDate: FrenchRepublicanDate, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String) {
        var dateString: String
        switch dateFormat {
        case .none:
            dateString = ""
            
        case .short, .shortWithRomanYear, .shortWithWeekday:
            dateString = FRCDate.toShortenedString()
            
        case .long, .longWithRomanYear:
            dateString = FRCDate.toLongString()
            
        case .longWithoutYear:
            dateString = FRCDate.toLongStringNoYear()
            
        case .mediumWithoutYear:
            dateString = FRCDate.toShortString()

        default:
            dateString = FRCDate.toVeryLongString()
        } // switch dateFormat
        
        var timeString: String
        switch timeFormat {
        case .none:
            timeString = ""
        case .medium:
            self.dateFormatter.locale = Locale.desiredLocale(localeIdentifier)
            let timeZone = locationData.timeZone
            self.dateFormatter.timeZone = timeZone
            self.dateFormatter.timeStyle = .medium
            self.dateFormatter.dateStyle = .none
            timeString = self.dateFormatter.string(from: now)

        case .decimal:
            let decimalTime = DecimalTime(base: now, timeZone: locationData.timeZone)
            timeString = decimalTime.hourMinuteSecondsFormatted

            default:
            timeString = ""
        } // switch timeFormat
        
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
//                let day = FRCDate.components.day ?? -1
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
    
    
    // MARK:  -
    
    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
       return ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
    }
    
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        [5, 10]
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat {
        return .system
    } // func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat
    
    
    // MARK: - ASACalendarSupportingBlankMonths
    
    var blankMonths: Array<Int> = [13]
    
    var blankWeekdaySymbol: String = "∅"
} // class ASAFrenchRepublicanCalendar
