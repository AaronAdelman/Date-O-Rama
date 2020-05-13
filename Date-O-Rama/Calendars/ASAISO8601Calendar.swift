//
//  ASAISO8601Calendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ASAISO8601Calendar:  ASACalendar {
    var calendarCode: ASACalendarCode = .ISO8601
    var color: UIColor = .systemGray
    var defaultMajorDateFormat:  ASAMajorDateFormat = .ISO8601YearMonthDay
    
    lazy var dateFormatter = DateFormatter()
    lazy var ISODateFormatter = ISO8601DateFormatter()
    
    init() {
        self.ISODateFormatter.timeZone = TimeZone.current
    } // init()
    
    func defaultDateGeekCode(majorDateFormat:  ASAMajorDateFormat) -> String {
        return "yyyy-MM-dd"
    } // func defaultDateGeekCode(majorDateFormat:  ASAMajorFormat) -> String
    
    func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String {
        return "HH:mm:ss"
    } // func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String
    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        var dateString:  String
        
        var formatterOptions:  ISO8601DateFormatter.Options = []
        switch majorDateFormat {
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
        } // switch majorDateFormat
        
        switch majorTimeFormat {
        case .full:
            formatterOptions.insert(.withFullTime)
        case .long:
            formatterOptions.insert(.withTime)
            formatterOptions.insert(.withColonSeparatorInTime)
            formatterOptions.insert(.withFractionalSeconds)
        case .medium, .short:
            formatterOptions.insert(.withTime)
            formatterOptions.insert(.withColonSeparatorInTime)
        default:
            debugPrint("")
        } // switch majorTimeFormat
        
        self.ISODateFormatter.formatOptions = formatterOptions
        
        if timeZone == nil {
            self.ISODateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.ISODateFormatter.timeZone = timeZone
        }
        
        dateString = self.ISODateFormatter.string(from: now)
        return dateString
    } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        self.dateFormatter.locale = Locale(identifier: "en_UK")
        
        self.dateFormatter.dateFormat = LDMLString
        
        if timeZone == nil {
            self.ISODateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.ISODateFormatter.timeZone = timeZone
        }
        
        let result = self.dateFormatter.string(from: now)
        
        return result
    } // func dateTimeString(now:  Date, localeIdentifier:  String, LDMLString:  String, location:  CLLocation?) -> String
    
    
    // MARK: -
    
    var LDMLDetails: Array<ASALDMLDetail> {
        get {
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
        }
    } // var LDMLDetails: Array<ASALDMLDetail>
    
//    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent> {
//        return []
//    } // func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone?) -> Array<ASAEventDetail>
    
    var supportsLocales: Bool = false
    
    func startOfDay(for date: Date, location: CLLocation?, timeZone: TimeZone) -> Date {
        return date.previousMidnight(timeZone:  timeZone)
    } // func startOfDay(for date: Date, location: CLLocation?, timeZone: TimeZone) -> Date
    
    func startOfNextDay(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
        return date.nextMidnight(timeZone:  timeZone)
    } // func nextTransitionToNextDay(now:  Date, location:  CLLocation, timeZone:  TimeZone) -> Date
    
    var supportsDateFormats: Bool = true
    
    var supportsTimeZones: Bool = true
    
    var supportsLocations: Bool = false
    
    var supportsEventDetails: Bool = false
    
    var supportsTimes: Bool = true
    
    var supportedMajorDateFormats: Array<ASAMajorDateFormat> = [
        .full,
        .ISO8601YearMonthDay,
        .ISO8601YearWeekDay,
        .ISO8601YearDay
    ]
    
    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [.full, .long, .medium, .short]
    
    var supportsTimeFormats: Bool = true
    
    var canSplitTimeFromDate:  Bool = true
    
    var defaultMajorTimeFormat:  ASAMajorTimeFormat = .medium
} // class ASAISO8601Calendar
