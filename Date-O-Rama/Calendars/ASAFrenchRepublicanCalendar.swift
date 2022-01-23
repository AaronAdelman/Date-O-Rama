//
//  ASAFrenchRepublicanCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import FrenchRepublicanCalendarCore

public class ASAFrenchRepublicanCalendar:  ASACalendar {
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
    ]
    
    var supportedTimeFormats: Array<ASATimeFormat> = [.medium]
    
    var supportsLocales: Bool = false
    
    var supportsDateFormats: Bool = false
    
    var supportsLocations: Bool = false
    
    var supportsTimeFormats: Bool = false
    
    var supportsTimes: Bool = true
    
    var supportsTimeZones: Bool = false
    
    var transitionType: ASATransitionType = .midnight
    
    var usesISOTime: Bool = true
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        let (dateString, _, _) = dateStringTimeStringDateComponents(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        return dateString
    }
    
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        let FRCDate = FrenchRepublicanDate(date: date)
        let components = FRCDate.components
        let FRCDateMidnight = FrenchRepublicanDate(dayInYear: FRCDate.dayInYear, year: components!.year!, hour: 0, minute: 0, second: 0, nanosecond: 0, options: nil)
        return FRCDateMidnight.date
    } // func startOfDay(for date: Date, locationData: ASALocation) -> Date
    
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        let startOfDay = self.startOfDay(for: date, locationData: locationData)
        return startOfDay.oneDayAfter
    } // func startOfNextDay(date: Date, locationData: ASALocation) -> Date
    
    func supports(calendarComponent: ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era:
            return true
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
    
    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let FRCDate = FrenchRepublicanDate(date: now, options: nil)
        let components = FRCDate.dateComponents(locationData: locationData, calendar: self)
        
        let dateString = FRCDate.toVeryLongString()
        
        let decimalTime = DecimalTime(base: now)
        let timeString = decimalTime.hourMinuteSecondsFormatted
        
        return (dateString, timeString, components)
    } // func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let month = dateComponents.month ?? -1
        if month < 1 || month > 13 {
            return false
        }
        
        let day = dateComponents.day ?? -1
        switch month {
        case 1...12:
            if day < 1 || day > 30 {
                return false
            }
            
        case 13:
            let dayInYear = (dateComponents.month! - 1) * 30 + (dateComponents.day! - 1)
            let FRCDate = FrenchRepublicanDate(dayInYear: dayInYear, year: dateComponents.year!, hour: 0, minute: 0, second: 0, nanosecond: 0, options: nil)
            let isSextilYear = FRCDate.isYearSextil
            
            if day < 1 || day > (isSextilYear ? 6 : 5) {
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
        let dayInYear = (month - 1) * 30 + (day - 1)
        
        let FRCDate = FrenchRepublicanDate(dayInYear: dayInYear, year: year, hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second, nanosecond: dateComponents.nanosecond, options: nil)
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
        let FRCDate = FrenchRepublicanDate(date: date, options: nil)
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
            return Range(13...13)
        case .weekOfYear:
            return Range(53...53)
        case .weekOfMonth:
            return Range(4...4)
        case .weekday:
            return Range(10...10)
        case .weekdayOrdinal:
            return Range(9...9)
        case .day:
            return Range(30...30)
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
         let FRCDate = FrenchRepublicanDate(date: date, options: nil)
        let isSextilYear = FRCDate.isYearSextil
        switch larger {
        case .year:
            switch smaller {
            case .month:
                return Range(1...13)
                
            case .day:
                return isSextilYear ? Range(1...366) : Range(1...365)

                
            default:
                return nil
            } // switch smaller
            
        case .month:
            switch smaller {
            case .day:
                let day = FRCDate.components.day ?? -1
                if 1 <= day && day <= 12 {
                    return Range(1...30)
                } else if day == 13 {
                    return isSextilYear ? Range(1...6) : Range(1...5)
                } else {
                    return nil
                }
                
            default:
                return nil
            } // switch smaller
            
        
            
        default:
            return nil
        } // switch larger
        
        return nil // TODO:  Fill in?
    }
    
    var daysPerWeek: Int? = 10
    
    
    // MARK:  - Time zone-dependent modified Julian day
    
    func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int {
        let timeZone = locationData.timeZone
        return date.localModifiedJulianDay(timeZone: timeZone)
        
        // TODO:  May need to modify this
    } // func localModifiedJulianDay(date: Date, timeZone: TimeZone) -> Int
    
    
    // MARK:  -
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        [5, 10]
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat {
        return .system
    } // func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat
} // class ASAFrenchRepublicanCalendar
