//
//  ASAAppleCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ASAAppleCalendar:  ASACalendar, ASASupportsWeeks {
    var defaultDateFormat:  ASADateFormat = .full
    
    var calendarCode:  ASACalendarCode
    
    var dateFormatter = DateFormatter()
    lazy var ISODateFormatter = ISO8601DateFormatter()


    private var ApplesCalendar:  Calendar
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        let title = self.calendarCode.equivalentCalendarIdentifier
        ApplesCalendar = Calendar(identifier: title)
        dateFormatter.calendar = ApplesCalendar
    } // init(calendarCode:  ASACalendarCode)

    func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let dateString = self.dateTimeString(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: locationData)
        let timeString = self.dateTimeString(now: now, localeIdentifier: localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: locationData)
        let dateComponents = self.dateComponents([.day, .weekday, .hour, .minute, .second], from: now, locationData: locationData)
        return (dateString, timeString, dateComponents)
    } // func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        self.dateFormatter.locale = Locale.desiredLocale(localeIdentifier)

        let timeZone = locationData.timeZone
        self.dateFormatter.timeZone = timeZone

        switch timeFormat {
        case .none:
            self.dateFormatter.timeStyle = .none
            
        case .medium:
            self.dateFormatter.timeStyle = .medium

        default:
            self.dateFormatter.timeStyle = .medium
        } // switch timeFormat
        
        switch dateFormat {
        case .ISO8601YearDay, .ISO8601YearMonthDay, .ISO8601YearWeekDay:
            return ISODateTimeString(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        
        case .none:
            self.dateFormatter.dateStyle = .none
            
        case .full, .fullWithRomanYear:
            self.dateFormatter.dateStyle = .full
            
        case .long, .longWithRomanYear:
            self.dateFormatter.dateStyle = .long
            
        case .medium:
            self.dateFormatter.dateStyle = .medium
            
        case .short, .shortWithRomanYear:
            self.dateFormatter.dateStyle = .short

        case .shortWithWeekday:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "eee")

        case .mediumWithWeekday:
            self.dateFormatter.apply(dateStyle: .medium, LDMLExtension: "eee")

        case .abbreviatedWeekday:
            self.dateFormatter.apply(dateStyle: .short, template: "eee")

        case .dayOfMonth:
            self.dateFormatter.apply(dateStyle: .short, template: "d")

        case .abbreviatedWeekdayWithDayOfMonth:
            self.dateFormatter.apply(dateStyle: .short, template: "eeed")

        case .shortWithWeekdayWithoutYear:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "E", removing:  DateFormatter.yearCodes)

        case .mediumWithWeekdayWithoutYear:
            self.dateFormatter.apply(dateStyle: .medium, LDMLExtension: "E", removing:  DateFormatter.yearCodes)

        case .fullWithoutYear:
            self.dateFormatter.apply(dateStyle: .full, LDMLExtension: "", removing:  DateFormatter.yearCodes)
            
        case .shortYearOnly:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "", removing: DateFormatter.nonYearCodes)
            
        case .shortYearAndMonthOnly:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "", removing: DateFormatter.nonYearNonMonthCodes)
        case .longWithoutYear:
            self.dateFormatter.apply(dateStyle: .long, LDMLExtension: "", removing:  DateFormatter.yearCodes)
            
        case .mediumWithoutYear:
            self.dateFormatter.apply(dateStyle: .medium, LDMLExtension: "", removing:  DateFormatter.yearCodes)
            
        case .shortWithoutYear:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "", removing:  DateFormatter.yearCodes)
        } // switch dateFormat
        
        return self.dateFormatter.string(from: now)
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
    
    func ISODateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        var dateString:  String
        
        var formatterOptions:  ISO8601DateFormatter.Options = []
        switch dateFormat {
        case .none:
            formatterOptions = []
        case .full:
            formatterOptions = [.withFullDate]
        case .ISO8601YearMonthDay:
            formatterOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        case .ISO8601YearWeekDay:
            formatterOptions = [.withYear, .withWeekOfYear, .withDay, .withDashSeparatorInDate]
        case .ISO8601YearDay:
            formatterOptions = [.withYear, .withDay, .withDashSeparatorInDate]
        default:
            formatterOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        } // switch dateFormat
        
        if timeFormat != .none {
            formatterOptions.insert(.withTime)
            formatterOptions.insert(.withColonSeparatorInTime)
        }
        
        self.ISODateFormatter.formatOptions = formatterOptions

        let timeZone = locationData.timeZone
        self.ISODateFormatter.timeZone = timeZone

        dateString = self.ISODateFormatter.string(from: now)
        return dateString
    }

    var supportsLocales: Bool = true
    
    func startOfDay(for date: Date, locationData:  ASALocation) -> Date {
        //        return date.previousMidnight(timeZone:  timeZone)
        let timeZone = locationData.timeZone
        self.ApplesCalendar.timeZone = timeZone
        return self.ApplesCalendar.startOfDay(for: date)
    } // func startOfDay(for date: Date, locationData:  ASALocation) -> Date
    
    func startOfNextDay(date:  Date, locationData:  ASALocation) -> Date {
        //        return date.nextMidnight(timeZone:  timeZone)
        self.ApplesCalendar.timeZone = locationData.timeZone
        return self.ApplesCalendar.startOfDay(for: date.oneDayAfter)
    } // func startOfNextDay(now:  Date, locationData:  ASALocation) -> Date
        
    var supportsTimeZones: Bool = true
    
    var supportsLocations: Bool = true

    var supportsTimes: Bool = true
    
    var supportedDateFormats: Array<ASADateFormat> {
        if self.calendarCode == .Gregorian {
            return [
                .full,
                .ISO8601YearMonthDay,
                .ISO8601YearWeekDay,
                .ISO8601YearDay
            ]
        } else {
            return [
                .full
            ]
        }
    }

    var supportedWatchDateFormats: Array<ASADateFormat> {
        if self.calendarCode == .Gregorian {
            return [
                .full,
                .ISO8601YearMonthDay,
                .ISO8601YearWeekDay,
                .ISO8601YearDay,
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
        } else {
            return [
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
        }
    }
    
    var supportedTimeFormats: Array<ASATimeFormat> = [
        .medium
    ]
        
    var canSplitTimeFromDate:  Bool = true
    
    var defaultTimeFormat:  ASATimeFormat = .medium
    
    // MARK: - Date components
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let ApplesDateComponents = dateComponents.ApplesDateComponents()
        return ApplesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        let ApplesDateComponents = dateComponents.ApplesDateComponents()

        return ApplesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    
    // MARK:  - Extracting Components
    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int {
        // Returns the value for one component of a date.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return -1
        }
        
        var calendar = self.ApplesCalendar
        calendar.timeZone = locationData.timeZone 
        return calendar.component(ApplesComponent!, from: date)
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents {
        // Returns all the date components of a date.
        var ApplesComponents = Set<Calendar.Component>()
        for component in components {
            let ApplesCalendarComponent = component.calendarComponent()
            if ApplesCalendarComponent != nil {
                ApplesComponents.insert(ApplesCalendarComponent!)
            }
        } // for component in components
        
        var calendar = self.ApplesCalendar
        calendar.timeZone = locationData.timeZone 
        let ApplesDateComponents = calendar.dateComponents(ApplesComponents, from: date)
        return ASADateComponents.new(with: ApplesDateComponents, calendar: self, locationData: locationData)
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents
    
    // MARK:  - Getting Calendar Information
    
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.ApplesCalendar.maximumRange(of: ApplesComponent!)
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.ApplesCalendar.minimumRange(of: ApplesComponent!)
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        let ApplesSmaller = smaller.calendarComponent()
        let ApplesLarger = larger.calendarComponent()
        if ApplesSmaller == nil || ApplesLarger == nil {
            return nil
        }
        return self.ApplesCalendar.ordinality(of: ApplesSmaller!, in: ApplesLarger!, for: date)
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        let ApplesSmaller = smaller.calendarComponent()
        let ApplesLarger = larger.calendarComponent()
        if ApplesSmaller == nil || ApplesLarger == nil {
            return nil
        }
        return self.ApplesCalendar.range(of: ApplesSmaller!, in: ApplesLarger!, for: date)
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>?
    
    // MARK: -
    
    func supports(calendarComponent:  ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era, .year, .yearForWeekOfYear, .quarter, .month, .weekOfYear, .weekOfMonth, .weekday, .weekdayOrdinal, .day:
            return true
            
        case .hour, .minute, .second, .nanosecond:
            return true
            
        case .calendar, .timeZone:
            return true
        case .fractionalHour, .dayHalf:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool


    // MARK: -

    public var transitionType:  ASATransitionType = .midnight

    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return self.ApplesCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>

    var usesISOTime:  Bool = true

    var daysPerWeek: Int = 7
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        self.ApplesCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat {
        if self.calendarCode.isHebrewCalendar && locale.languageCode == "he" {
            return .shortHebrew
        }
        
        return .system
    } // func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat
    
    
    // MARK:  - Time zone-dependent modified Julian day
    
    func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int {
        let timeZone = locationData.timeZone
        return date.localModifiedJulianDay(timeZone: timeZone)
    } // func localModifiedJulianDay(date: Date, timeZone: TimeZone) -> Int
} // class ASAAppleCalendar
