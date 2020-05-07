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

class ASAAppleCalendar:  ASACalendar {
    var color: UIColor = .systemGray
    var defaultMajorDateFormat:  ASAMajorDateFormat = .full  // TODO:  Rethink this when dealing with watchOS
        
    var calendarCode:  ASACalendarCode
    
    var dateFormatter = DateFormatter()
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        //        self.calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        
        dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
    }
    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        if timeZone == nil {
            self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.dateFormatter.timeZone = timeZone
        }
        
        switch majorTimeFormat {
        case .none:
            self.dateFormatter.timeStyle = .none
            
        case .full:
            self.dateFormatter.timeStyle = .full
            
        case .long:
            self.dateFormatter.timeStyle = .long
            
        case .medium:
            self.dateFormatter.timeStyle = .medium
            
        case .short:
            self.dateFormatter.timeStyle = .short
            
        default:
            self.dateFormatter.timeStyle = .medium // TODO:  EXPAND ON THIS!
        } // switch majorTimeFormat
        
        if majorDateFormat == .localizedLDML {
            let dateFormat = DateFormatter.dateFormat(fromTemplate:dateGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            return self.dateFormatter.string(from: now)
        }
        
        if majorDateFormat == .full {
            self.dateFormatter.dateStyle = .full
            return self.dateFormatter.string(from: now)
        }
        
        if majorDateFormat == .long {
            self.dateFormatter.dateStyle = .long
            return self.dateFormatter.string(from: now)
        }
        
        if majorDateFormat == .medium {
            self.dateFormatter.dateStyle = .medium
            return self.dateFormatter.string(from: now)
        }
        
        if majorDateFormat == .short {
            self.dateFormatter.dateStyle = .short
            return self.dateFormatter.string(from: now)
        }
        
        return "Error!"
    } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        self.dateFormatter.dateFormat = LDMLString
        if timeZone == nil {
            self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.dateFormatter.timeZone = timeZone
        }
        
        let result = self.dateFormatter.string(from: now)
        
        return result
    } // func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorDateFormat) -> String {
        return "eee, d MMM y"
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    var LDMLDetails: Array<ASALDMLDetail> {
        get {
            if self.calendarCode == .Chinese {
                return [
                    ASALDMLDetail(name: "HEADER_G", geekCode: "GGGG"),
                    ASALDMLDetail(name: "HEADER_y", geekCode: "y"),
                    ASALDMLDetail(name: "HEADER_M", geekCode: "MMMM"),
                    ASALDMLDetail(name: "HEADER_d", geekCode: "d"),
                    ASALDMLDetail(name: "HEADER_E", geekCode: "eeee"),
                    ASALDMLDetail(name: "HEADER_Q", geekCode: "QQQQ"),
                    ASALDMLDetail(name: "HEADER_Y", geekCode: "Y"),
                    ASALDMLDetail(name: "HEADER_w", geekCode: "w"),
                    ASALDMLDetail(name: "HEADER_W", geekCode: "W"),
                    ASALDMLDetail(name: "HEADER_F", geekCode: "F"),
                    ASALDMLDetail(name: "HEADER_D", geekCode: "D"),
                    ASALDMLDetail(name: "HEADER_U", geekCode: "UUUU"),
                    //                        ASALDMLDetail(name: "HEADER_r", geekCode: "r"),
                    //            ASADetail(name: "HEADER_g", geekCode: "g")
                ]
            }
            
            return [
                ASALDMLDetail(name: "HEADER_G", geekCode: "GGGG"),
                ASALDMLDetail(name: "HEADER_y", geekCode: "y"),
                ASALDMLDetail(name: "HEADER_M", geekCode: "MMMM"),
                ASALDMLDetail(name: "HEADER_d", geekCode: "d"),
                ASALDMLDetail(name: "HEADER_E", geekCode: "eeee"),
                ASALDMLDetail(name: "HEADER_Q", geekCode: "QQQQ"),
                ASALDMLDetail(name: "HEADER_Y", geekCode: "Y"),
                ASALDMLDetail(name: "HEADER_w", geekCode: "w"),
                ASALDMLDetail(name: "HEADER_W", geekCode: "W"),
                ASALDMLDetail(name: "HEADER_F", geekCode: "F"),
                ASALDMLDetail(name: "HEADER_D", geekCode: "D"),
                //            ASADetail(name: "HEADER_U", geekCode: "UUUU"),
                //            ASALDMLDetail(name: "HEADER_r", geekCode: "r"),
                //            ASADetail(name: "HEADER_g", geekCode: "g")
            ]
        } // get
    } // var LDMLDetails: Array<ASALDMLDetail>
    
    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent> {
        return []
    } // func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone?) -> Array<ASAEventDetail>
    
    var supportsLocales: Bool = true
    
    func startOfNextDay(now:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
        return now.nextMidnight(timeZone:  timeZone)
    } // func nextTransitionToNextDay(now:  Date, location:  CLLocation, timeZone:  TimeZone) -> Date
    
    var supportsDateFormats: Bool = true
    
    var supportsTimeZones: Bool = true
    
    var supportsLocations: Bool = false
    
    var supportsEventDetails: Bool = false
    
    var supportsTimes: Bool = true
    
    var supportedMajorDateFormats: Array<ASAMajorDateFormat> = [
        .full,
        .long,
        .medium,
        .short,
        .localizedLDML
    ]
    
    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [.full, .long, .medium, .short]
    
    var supportsTimeFormats: Bool = true
} // class ASAAppleCalendar
