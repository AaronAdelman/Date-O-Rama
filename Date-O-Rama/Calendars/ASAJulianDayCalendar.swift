//
//  ASAJulianDayCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

//let MODIFIED_JULIAN_DAY_OFFSET_FROM_JULIAN_DAY = 2400000.5

class ASAJulianDayCalendar:  ASACalendar {
    var calendarCode: ASACalendarCode = .JulianDay
    var defaultDateFormat:  ASADateFormat = .full
    
    private var offsetFromJulianDay:  Double {
        get {
            switch calendarCode {
            case .JulianDay:
                return 0.0
                
            case .ReducedJulianDay:
                return 2400000.0
                
            case .ModifiedJulianDay:
                return MODIFIED_JULIAN_DAY_OFFSET_FROM_JULIAN_DAY
                
            case .TruncatedJulianDay:
                return 2440000.5
                
            case .DublinJulianDay:
                return 2415020.0
                
            case .CNESJulianDay:
                return 2433282.5
                
            case .CCSDSJulianDay:
                return 2436204.5
                
            case .LilianDate:
                return 2299159.5
                
            case .RataDie:
                return 1721424.5
                
            default:
                return 0.0
            } // switch calendarCode
        } // get
    } // var offsetFromJulianDay
    
    init(calendarCode: ASACalendarCode) {
        self.calendarCode = calendarCode
    } // init(calendarCode: ASACalendarCode)

    let formatter = NumberFormatter()

    func dateString(JulianDate: Double, timeFormat: ASATimeFormat, localeIdentifier:  String) -> String {
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.allowsFloats = (timeFormat != .none) ? true : false
        if timeFormat == .none {
            formatter.roundingMode = .floor
        } else {
            formatter.minimumFractionDigits = 6
        }
        let dateString = formatter.string(from: NSNumber(floatLiteral: JulianDate)) ?? ""
        return dateString
    } // func dateString(JulianDate: Double, timeFormat: ASATimeFormat) -> String

    func dateString(JulianDay: Int, localeIdentifier:  String) -> String {
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.allowsFloats = false
        let dateString = formatter.string(from: NSNumber(value: JulianDay)) ?? ""
        return dateString
    } // func dateString(JulianDay: Int) -> String

    func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        formatter.locale = Locale(identifier: localeIdentifier)
        var components = ASADateComponents(calendar: self, locationData: locationData)

        if self.supportsTimes {
            let (JulianDate, day, fractionOfDay) = now.JulianDateWithComponents(calendarCode: self.calendarCode)
            let dateString = self.dateString(JulianDate: JulianDate, timeFormat: timeFormat, localeIdentifier: localeIdentifier)
            components.day        = day
            components.solarHours = fractionOfDay
            return (dateString, "", components)
        } else {
            let day = now.JulianDateWithoutTime(calendarCode: self.calendarCode)
            let dateString = self.dateString(JulianDay: day, localeIdentifier: localeIdentifier)
            components.day        = 0
            components.solarHours = 0.0
            return (dateString, "", components)
        }
    } // func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        if self.supportsTimes && timeFormat != .none {
            let JulianDate = now.JulianDateWithTime(calendarCode: self.calendarCode)
            let result = self.dateString(JulianDate: JulianDate, timeFormat: timeFormat, localeIdentifier: localeIdentifier)
            return result
        } else {
            let JulianDay = now.JulianDateWithoutTime(calendarCode: self.calendarCode)
            let result = self.dateString(JulianDay: JulianDay, localeIdentifier: localeIdentifier)
            return result
        }
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
    
    var supportsLocales: Bool = true
        
    func startOfDay(for date: Date, locationData:  ASALocation) -> Date {
        let JulianDate = date.JulianDateWithTime(calendarCode: self.calendarCode)
        let startAsJulianDate = floor(JulianDate)
        return Date.date(JulianDate: startAsJulianDate, calendarCode: self.calendarCode)
    } // func startOfDay(for date: Date, locationData:  ASALocation) -> Date
    
    
    func startOfNextDay(date: Date, locationData:  ASALocation) -> Date {
        let JulianDate = date.JulianDateWithTime(calendarCode: self.calendarCode)
        let startAsJulianDate = floor(JulianDate)
        return Date.date(JulianDate: startAsJulianDate + 1.0, calendarCode: self.calendarCode)
    } // func nextTransitionToNextDay(now: Date, location: CLLocation, timeZone:  TimeZone) -> Date
    
    var supportsTimeZones: Bool = false
    
    var supportsLocations: Bool = false
        
    var supportsTimes: Bool {
        get {
            switch self.calendarCode {
            case .TruncatedJulianDay, .LilianDate, .RataDie:
                return false
                
            default:
                return true
            } // switch self.calendarCode
        } // get
    } // var supportsTimes: Bool
    
    var supportedDateFormats: Array<ASADateFormat> = [
        .full
    ]

    var supportedWatchDateFormats: Array<ASADateFormat> = [
        .full
    ]
    
    var supportedTimeFormats: Array<ASATimeFormat> = [.medium]
        
    var canSplitTimeFromDate:  Bool = false
    
    var defaultTimeFormat:  ASATimeFormat = .medium
    
    
    // MARK: - Date components
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        if dateComponents.era != nil
            || dateComponents.year != nil
            || dateComponents.yearForWeekOfYear != nil
            || dateComponents.quarter != nil
            || dateComponents.month != nil
            || dateComponents.weekOfMonth != nil
            || dateComponents.weekOfYear != nil
            || dateComponents.weekday != nil
            || dateComponents.weekdayOrdinal != nil
            || dateComponents.hour != nil
            || dateComponents.minute != nil
            || dateComponents.second != nil
            || dateComponents.nanosecond != nil {
            return false
        }
                
        if dateComponents.day != nil {
            return true
        } else {
            return false
        }
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        guard let day = dateComponents.day else {
            return nil
        }
        guard let fractionOfDay = dateComponents.solarHours else {
            return nil
        }
        
        return Date.date(JulianDate: Double(day) + fractionOfDay, calendarCode: self.calendarCode)
    } // func date(dateComponents: ASADateComponents) -> Date?
    

    // MARK:  - Extracting Components

    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int {
         // Returns the value for one component of a date.
        let components = date.JulianDateComponents(calendarCode: self.calendarCode)

        switch component {
        case .day:
            return components.day
            
        case .fractionalHour:
            return Int(components.fractionOfDay)

        default:
            return -1
        } // switch component
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents {
        let JDComponents = date.JulianDateComponents(calendarCode: self.calendarCode)
        var result = ASADateComponents(calendar: self, locationData: locationData)
        for component in components {
            switch component {
            case .day:
                result.day = JDComponents.day
                
            case .fractionalHour:
                result.solarHours = JDComponents.fractionOfDay

            default:
                debugPrint(#file, #function, component as Any)
            } // switch component
        }
        return result
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents
    
    
    // MARK:  - Getting Calendar Information
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        if component == .day {
            return Int.max..<Int.max
        } else {
            return nil
        }
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        if component == .day {
            return Int.min..<Int.min
        } else {
            return nil
        }
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        return nil
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        return nil
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>?

    
    // MARK: -
    
    func supports(calendarComponent:  ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .day:
            return true
            
        case .fractionalHour:
            return true
                        
        case .calendar:
            return true
            
        default:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool


    // MARK: -

    public var transitionType:  ASATransitionType = .noon

    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return []
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>

    var usesISOTime:  Bool = false
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        return []
    }
    
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat {
        return .system
    } // func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat
        
    func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int {
        return date.localModifiedJulianDay(timeZone: locationData.timeZone)
    } // func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int
} // class ASAJulianDayCalendar
