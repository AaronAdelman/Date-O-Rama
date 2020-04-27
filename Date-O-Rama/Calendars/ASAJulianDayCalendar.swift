//
//  ASAJulianDayCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

class ASAJulianDayCalendar:  ASACalendar {
    var calendarCode: ASACalendarCode = .JulianDay
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
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String {
        return ""
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    private func dateString(now:  Date, localeIdentifier: String) -> String {
        let JulianDay = Int(floor(now.JulianDate()) - self.offsetFromJulianDay)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        let result = formatter.string(from: NSNumber(value: JulianDay)) ?? ""
        return result
    } // func dateString(now:  Date, localeIdentifier: String) -> String
    
    func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        return self.dateString(now: now, localeIdentifier: localeIdentifier)
    } // func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        return self.dateString(now: now, localeIdentifier: localeIdentifier)
    } // func dateString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    func LDMLDetails() -> Array<ASALDMLDetail> {
        return []
    } // func details() -> Array<ASADetail>
    
    func eventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail> {
        return []
    } // func eventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail>
    
    func supportsLocales() -> Bool {
        return true
    } // func supportsLocales() -> Bool
    
    func supportsDateFormats() -> Bool {
        return false
    } // func supportsDateFormats() -> Bool
    
    func transitionToNextDay(now: Date, location: CLLocation) -> Date {
        switch self.calendarCode {
        case .JulianDay, .ReducedJulianDay, .DublinJulianDay:
            return now.nextGMTNoon()
            
        case .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
            return now.nextMidnight(timeZone: TimeZone(secondsFromGMT: 0)!)

        default:
            return now.nextGMTNoon()
        }
    } // func nextTransitionToNextDay(now: Date, location: CLLocation) -> Date
    
    func supportsTimeZones() -> Bool {
        return false
    } // func supportsTimeZones() -> Bool
    
    func supportsLocations() -> Bool {
        return false
    } // func supportsLocations() -> Bool
    
    func supportsEventDetails() -> Bool {
        return false
    } // func supportsEventDetails() -> Bool

    func timeZone(location:  CLLocation?) -> TimeZone {
        return TimeZone(secondsFromGMT: 0)!
    } // func timeZone(location:  CLLocation?) -> TimeZone} // class ASAJulianDayCalendar
} // class ASAJulianDayCalendar
