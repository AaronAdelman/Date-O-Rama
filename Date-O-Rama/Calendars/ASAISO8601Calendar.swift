//
//  ASAISO8601Calendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

class ASAISO8601Calendar:  ASACalendar {
    var calendarCode: ASACalendarCode = .ISO8601
        
    lazy var dateFormatter = DateFormatter()
    lazy var ISODateFormatter = ISO8601DateFormatter()
    
    init() {
        self.ISODateFormatter.timeZone = TimeZone.current
    } // init()
    
    func defaultDateGeekCode(majorDateFormat:  ASAMajorFormat) -> String {
        return "yyyy-MM-dd"
    } // func defaultDateGeekCode(majorDateFormat:  ASAMajorFormat) -> String
    
    func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        var dateString:  String
        
        let options = dateGeekFormat.chop()
        var formatterOptions:  ISO8601DateFormatter.Options = []
        for o in options {
            switch o {
            case "yyyy":  formatterOptions.insert(.withYear)
                
            case "MM":  formatterOptions.insert(.withMonth)
                
            case "dd":  formatterOptions.insert(.withDay)
                
            case "ww":  formatterOptions.insert(.withWeekOfYear)
                
            case "-":  formatterOptions.insert(.withDashSeparatorInDate)
                
            default:  do {}
            } // switch o
        }
        self.ISODateFormatter.formatOptions = formatterOptions
        
        if timeZone == nil {
            self.ISODateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.ISODateFormatter.timeZone = timeZone
        }

        dateString = self.ISODateFormatter.string(from: now)
        return dateString
    } // func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        self.dateFormatter.locale = Locale(identifier: "en_US")
        
        self.dateFormatter.dateFormat = LDMLString
        
        if timeZone == nil {
            self.ISODateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.ISODateFormatter.timeZone = timeZone
        }

        let result = self.dateFormatter.string(from: now)
        
        return result
    } // func dateString(now:  Date, localeIdentifier:  String, LDMLString:  String, location:  CLLocation?) -> String
    
    
    // MARK: -
    
    public func LDMLDetails() -> Array<ASALDMLDetail> {
        return [
            ASALDMLDetail(name: "HEADER_y", geekCode: "yyyy"),
            ASALDMLDetail(name: "HEADER_M", geekCode: "MM"),
            ASALDMLDetail(name: "HEADER_d", geekCode: "dd"),
            ASALDMLDetail(name: "HEADER_Y", geekCode: "Y"),
            ASALDMLDetail(name: "HEADER_w", geekCode: "ww"),
            ASALDMLDetail(name: "HEADER_E", geekCode: "e"),
            ASALDMLDetail(name: "HEADER_D", geekCode: "D")
//            ,
//            ASADetail(name: "HEADER_g", geekCode: "g")
        ]
    } // public func details() -> Array<ASADetail>
    
    func eventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail> {
        return []
    } // func eventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail>
    
    public func supportsLocales() -> Bool {
        return false
    } // func supportsLocales() -> Bool
    
    func transitionToNextDay(now:  Date, location:  CLLocation) -> Date {
        return now.nextMidnight(timeZone:  TimeZone.autoupdatingCurrent)
    } // func nextTransitionToNextDay(now:  Date, location:  CLLocation) -> Date

    func supportsDateFormats() -> Bool {
        return true
    } // func supportsDateFormats() -> Bool
    
    func supportsTimeZones() -> Bool {
        return true
    } // func supportsTimeZones() -> Bool
    
    func supportsLocations() -> Bool {
        return false
    } // func supportsLocations() -> Bool
    
    func supportsEventDetails() -> Bool {
        return false
    } // func supportsEventDetails() -> Bool
    
    func timeZone(location:  CLLocation?) -> TimeZone {
        return TimeZone.autoupdatingCurrent
    } // func timeZone(location:  CLLocation?) -> TimeZone
} // class ASAISO8601Calendar
