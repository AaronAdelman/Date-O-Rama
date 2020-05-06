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
    var color: UIColor = .systemGray
    
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
    
    private func dateTimeString(now:  Date, localeIdentifier: String, majorTimeFormat: ASAMajorFormat) -> String {
        if self.supportsTimes() && majorTimeFormat != .none {
            let JulianDay = now.JulianDate() - self.offsetFromJulianDay
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: localeIdentifier)
            formatter.allowsFloats = true
            formatter.minimumFractionDigits = 6
            let result = formatter.string(from: NSNumber(floatLiteral: JulianDay)) ?? ""
            return result
        } else {
            let JulianDay = Int(floor(now.JulianDate() - self.offsetFromJulianDay))
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: localeIdentifier)
            formatter.allowsFloats = false
            let result = formatter.string(from: NSNumber(value: JulianDay)) ?? ""
            return result
        }
    } // func dateTimeString(now:  Date, localeIdentifier: String) -> String
    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        return self.dateTimeString(now: now, localeIdentifier: localeIdentifier, majorTimeFormat: majorTimeFormat)
    } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        return self.dateTimeString(now: now, localeIdentifier: localeIdentifier, majorTimeFormat: .full)
    } // func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    func LDMLDetails() -> Array<ASALDMLDetail> {
        return []
    } // func details() -> Array<ASADetail>
    
    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent> {
        return []
    } // func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone?) -> Array<ASAEventDetail>
    
    func supportsLocales() -> Bool {
        return true
    } // func supportsLocales() -> Bool
    
    func supportsDateFormats() -> Bool {
        return false
    } // func supportsDateFormats() -> Bool
    
    func startOfNextDay(now: Date, location: CLLocation?, timeZone:  TimeZone) -> Date {
        switch self.calendarCode {
        case .JulianDay, .ReducedJulianDay, .DublinJulianDay:
            return now.nextGMTNoon()
            
        case .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
            return now.nextMidnight(timeZone: TimeZone(secondsFromGMT: 0)!)

        default:
            return now.nextGMTNoon()
        }
    } // func nextTransitionToNextDay(now: Date, location: CLLocation, timeZone:  TimeZone) -> Date
    
    func supportsTimeZones() -> Bool {
        return false
    } // func supportsTimeZones() -> Bool
    
    func supportsLocations() -> Bool {
        return false
    } // func supportsLocations() -> Bool
    
    func supportsEventDetails() -> Bool {
        return false
    } // func supportsEventDetails() -> Bool

    func supportsTimes() -> Bool {
        switch self.calendarCode {
        case .TruncatedJulianDay, .LilianDate, .RataDie:
            return false

        default:
            return true
        } // switch self.calendarCode
    } // func supportsTimes() -> Bool
} // class ASAJulianDayCalendar
