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

class ASAJulianDayCalendar:  ASACalendar {
    var calendarCode: ASACalendarCode = .JulianDay
    var defaultMajorDateFormat:  ASAMajorDateFormat = .full
    
    private var offsetFromJulianDay:  Double {
        get {
            switch calendarCode {
            case .JulianDay:
                return 0.0
                
            case .ReducedJulianDay:
                return 2400000.0
                
            case .ModifiedJulianDay:
                return 2400000.5
                
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
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorDateFormat) -> String {
        return ""
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String {
        return "HH:mm:ss"
    } // func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String
    
    
    private func dateTimeString(now:  Date, localeIdentifier: String, majorTimeFormat: ASAMajorTimeFormat) -> String {
        if self.supportsTimes && majorTimeFormat != .none {
            //            let JulianDay = now.JulianDate() - self.offsetFromJulianDay
            let JulianDay = now.JulianDateWithTime(offsetFromJulianDay: self.offsetFromJulianDay)
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: localeIdentifier)
            formatter.allowsFloats = true
            formatter.minimumFractionDigits = 6
            let result = formatter.string(from: NSNumber(floatLiteral: JulianDay)) ?? ""
            return result
        } else {
            //            let JulianDay = Int(floor(now.JulianDate() - self.offsetFromJulianDay))
            let JulianDay = now.JulianDateWithoutTime(offsetFromJulianDay: self.offsetFromJulianDay)
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: localeIdentifier)
            formatter.allowsFloats = false
            let result = formatter.string(from: NSNumber(value: JulianDay)) ?? ""
            return result
        }
    } // func dateTimeString(now:  Date, localeIdentifier: String) -> String
    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        return self.dateTimeString(now: now, localeIdentifier: localeIdentifier, majorTimeFormat: majorTimeFormat)
    } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        return self.dateTimeString(now: now, localeIdentifier: localeIdentifier, majorTimeFormat: .full)
    } // func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    var LDMLDetails: Array<ASALDMLDetail> = []
    
    var supportsLocales: Bool = true
    
    var supportsDateFormats: Bool = false
    
    func startOfDay(for date: Date, location: CLLocation?, timeZone: TimeZone) -> Date {
        switch self.calendarCode {
        case .JulianDay, .ReducedJulianDay, .DublinJulianDay:
            return date.previousGMTNoon()
            
        case .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
            return date.previousMidnight(timeZone: TimeZone(secondsFromGMT: 0)!)
            
        default:
            return date.previousGMTNoon()
        } // switch self.calendarCode
    } // func startOfDay(for date: Date, location: CLLocation?, timeZone: TimeZone) -> Date
    
    
    func startOfNextDay(date: Date, location: CLLocation?, timeZone:  TimeZone) -> Date {
        switch self.calendarCode {
        case .JulianDay, .ReducedJulianDay, .DublinJulianDay:
            return date.nextGMTNoon()
            
        case .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
            return date.nextMidnight(timeZone: TimeZone(secondsFromGMT: 0)!)
            
        default:
            return date.nextGMTNoon()
        } // switch self.calendarCode
    } // func nextTransitionToNextDay(now: Date, location: CLLocation, timeZone:  TimeZone) -> Date
    
    var supportsTimeZones: Bool = false
    
    var supportsLocations: Bool = false
    
    var supportsEventDetails: Bool = false
    
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
    
    var supportedMajorDateFormats: Array<ASAMajorDateFormat> = [
        .full
    ]
    
    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [.full]
    
    var supportsTimeFormats: Bool = false
    
    var canSplitTimeFromDate:  Bool = false
    
    var defaultMajorTimeFormat:  ASAMajorTimeFormat = .medium
    
    
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
        
        // TODO:  Add something to handle fractional days!
        
        if dateComponents.day != nil {
            return true
        } else {
            return false
        }
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        let day = dateComponents.day
        if day == nil {
            return nil
        }
        
        // TODO:  Add something to handle fractional days!
        return Date.date(JulianDate: Double(dateComponents.day!), offsetFromJulianDay: self.offsetFromJulianDay)
    } // func date(dateComponents: ASADateComponents) -> Date?
    

    // MARK:  - Extracting Components

    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int {
         // Returns the value for one component of a date.
        if component == .day {
            let day = date.JulianDateWithoutTime(offsetFromJulianDay:  self.offsetFromJulianDay)
            return day
        } else {
            return -1
        }
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents {
        let day = date.JulianDateWithoutTime(offsetFromJulianDay:  self.offsetFromJulianDay)
        var result = ASADateComponents(calendar: self, locationData: locationData)
        for component in components {
            if component == .day {
                result.day = day
            }
        } // for component in components
        return result
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents
    
    
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
    
//    func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent? {
//        // Returns which component contains the specified component for specifying a date.  E.g., in many calendars days are contained within months, months are contained within years, and years are contained within eras.
//        return nil
//    } // func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent?
    
    
    // MARK: -
    
    func supports(calendarComponent:  ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .day:
            return true
                        
        case .calendar, .timeZone:
            return true
            
        default:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool
} // class ASAJulianDayCalendar
