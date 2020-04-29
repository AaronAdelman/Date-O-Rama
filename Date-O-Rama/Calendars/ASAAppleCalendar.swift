//
//  ASAAppleCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

class ASAAppleCalendar:  ASACalendar {
//    var calendarIdentifier:  Calendar.Identifier?
    
    var calendarCode:  ASACalendarCode
    
    var dateFormatter = DateFormatter()
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        //        self.calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        
        dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
    }
    
    func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }

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
    } // func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        self.dateFormatter.dateFormat = LDMLString
        if timeZone == nil {
            self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.dateFormatter.timeZone = timeZone
        }

        let result = self.dateFormatter.string(from: now)
        
        return result
    } // func dateString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String {
        return "eee, d MMM y"
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    func LDMLDetails() -> Array<ASALDMLDetail> {
        if self.calendarCode == .Gregorian {
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
//                        ASADetail(name: "HEADER_r", geekCode: "r"),
            //            ASADetail(name: "HEADER_g", geekCode: "g")
                    ]
        }
        
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
    } // func details() -> Array<ASADetail>
    
    func eventDetails(date:  Date, location:  CLLocation?) -> Array<ASAEventDetail> {
        return []
    } // func eventDetails(date:  Date, location:  CLLocation?) -> Array<ASAEventDetail>
    
    func supportsLocales() -> Bool {
        return true
    } // func supportsLocales() -> Bool
    
    func startOfNextDay(now:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
        return now.nextMidnight(timeZone:  timeZone)
    } // func nextTransitionToNextDay(now:  Date, location:  CLLocation, timeZone:  TimeZone) -> Date
    
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
} // class ASAAppleCalendar
