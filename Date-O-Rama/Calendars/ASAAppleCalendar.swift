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
    var calendarIdentifier:  Calendar.Identifier?
    
    var calendarCode:  ASACalendarCode
    
    lazy var dateFormatter = DateFormatter()
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        self.calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        
        dateFormatter.calendar = Calendar(identifier: calendarIdentifier!)
    }
    
    func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
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
    
    func details() -> Array<ASADetail> {
        if self.calendarCode == .Gregorian {
                    return [
                        ASADetail(name: "HEADER_G", geekCode: "GGGG"),
                        ASADetail(name: "HEADER_y", geekCode: "y"),
                        ASADetail(name: "HEADER_M", geekCode: "MMMM"),
                        ASADetail(name: "HEADER_d", geekCode: "d"),
                        ASADetail(name: "HEADER_E", geekCode: "eeee"),
                        ASADetail(name: "HEADER_Q", geekCode: "QQQQ"),
                        ASADetail(name: "HEADER_Y", geekCode: "Y"),
                        ASADetail(name: "HEADER_w", geekCode: "w"),
                        ASADetail(name: "HEADER_W", geekCode: "W"),
                        ASADetail(name: "HEADER_F", geekCode: "F"),
                        ASADetail(name: "HEADER_D", geekCode: "D"),
            //            ASADetail(name: "HEADER_U", geekCode: "UUUU"),
//                        ASADetail(name: "HEADER_r", geekCode: "r"),
            //            ASADetail(name: "HEADER_g", geekCode: "g")
                    ]
        }
        
        if self.calendarCode == .Chinese {
            return [
                        ASADetail(name: "HEADER_G", geekCode: "GGGG"),
                        ASADetail(name: "HEADER_y", geekCode: "y"),
                        ASADetail(name: "HEADER_M", geekCode: "MMMM"),
                        ASADetail(name: "HEADER_d", geekCode: "d"),
                        ASADetail(name: "HEADER_E", geekCode: "eeee"),
                        ASADetail(name: "HEADER_Q", geekCode: "QQQQ"),
                        ASADetail(name: "HEADER_Y", geekCode: "Y"),
                        ASADetail(name: "HEADER_w", geekCode: "w"),
                        ASADetail(name: "HEADER_W", geekCode: "W"),
                        ASADetail(name: "HEADER_F", geekCode: "F"),
                        ASADetail(name: "HEADER_D", geekCode: "D"),
                        ASADetail(name: "HEADER_U", geekCode: "UUUU"),
                        ASADetail(name: "HEADER_r", geekCode: "r"),
            //            ASADetail(name: "HEADER_g", geekCode: "g")
                    ]
        }
        
        return [
            ASADetail(name: "HEADER_G", geekCode: "GGGG"),
            ASADetail(name: "HEADER_y", geekCode: "y"),
            ASADetail(name: "HEADER_M", geekCode: "MMMM"),
            ASADetail(name: "HEADER_d", geekCode: "d"),
            ASADetail(name: "HEADER_E", geekCode: "eeee"),
            ASADetail(name: "HEADER_Q", geekCode: "QQQQ"),
            ASADetail(name: "HEADER_Y", geekCode: "Y"),
            ASADetail(name: "HEADER_w", geekCode: "w"),
            ASADetail(name: "HEADER_W", geekCode: "W"),
            ASADetail(name: "HEADER_F", geekCode: "F"),
            ASADetail(name: "HEADER_D", geekCode: "D"),
//            ASADetail(name: "HEADER_U", geekCode: "UUUU"),
            ASADetail(name: "HEADER_r", geekCode: "r"),
//            ASADetail(name: "HEADER_g", geekCode: "g")
        ]
    } // func details() -> Array<ASADetail>
    
    func supportsLocales() -> Bool {
        return true
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
} // class ASAAppleCalendar
