//
//  ASASunsetTransitionCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-22.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI

// MARK: - Solar event keys

let MIDNIGHT_KEY                      = "midnight"
let SUNRISE_KEY                       = "sunrise"
let NOON_KEY                          = "noon"
let SUNSET_KEY                        = "sunset"
let MORNING_CIVIL_TWILIGHT_KEY        = "morningCivilTwilight"
let EVENING_CIVIL_TWILIGHT_KEY        = "eveningCivilTwilight"
let MORNING_NAUTICAL_TWILIGHT_KEY     = "morningNauticalTwilight"
let EVENING_NAUTICAL_TWILIGHT_KEY     = "eveningNauticalTwilight"
let MORNING_ASTRONOMICAL_TWILIGHT_KEY = "morningAstronomicalTwilight"
let EVENING_ASTRONOMICAL_TWILIGHT_KEY = "eveningAstronomicalTwilight"

let DAWN_KEY                          = "dawn"
let RECOGNITION_KEY                   = "recognition"
let HOUR_03_KEY                       = "hour03"
let HOUR_04_KEY                       = "hour04"
let HOUR_06½_KEY                      = "hour06½"
let HOUR_09½_KEY                      = "hour09½"
let HOUR_10¾_KEY                      = "hour10¾"
let CANDLELIGHTING_KEY                = "candlelighting"
let DUSK_KEY                          = "dusk"

let OTHER_DAWN_KEY                    = "otherDawn"
let OTHER_HOUR_03_KEY                 = "otherHour03"
let OTHER_HOUR_04_KEY                 = "otherHour04"
let OTHER_HOUR_06½_KEY                = "otherHour06½"
let OTHER_HOUR_09½_KEY                = "otherHour09½"
let OTHER_HOUR_10¾_KEY                = "otherHour10¾"
let OTHER_DUSK_KEY                    = "otherDusk"

extension Date {
    // For מגן אברהם
    func sunriseToOtherDawn() -> Date {
        return self.addingTimeInterval(-72 * 60)
    } // func sunriseToOtherDawn() -> Date
    
    func sunsetToOtherDusk() -> Date {
        return self.addingTimeInterval(72 * 60)
    } // // func sunsetToOtherDusk() -> Date
} // extension Date


// MARK: -

class ASASunsetTransitionCalendar:  ASACalendar {
    var calendarCode: ASACalendarCode
    
    var color: UIColor {
        get {
            switch self.calendarCode {
            case .HebrewGRA, .HebrewMA:
                return UIColor.systemBlue
                
            case .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
                return UIColor.systemGreen
                
            default:
                return UIColor.systemGray
            } // switch self.calendarCode
        } // get
    } // var color: UIColor
    
    var defaultMajorDateFormat:  ASAMajorDateFormat = .full  // TODO:  Rethink this when dealing with watchOS
    
    var dateFormatter = DateFormatter()
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        //        self.calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        
        dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
    } // init(calendarCode:  ASACalendarCode)
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorDateFormat) -> String {
        return "eee, d MMM y"
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String {
        return "HH:mm:ss"
    } // func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String
        
    func timeString(now: Date, localeIdentifier: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        let latitude  = location!.coordinate.latitude
        let longitude = location!.coordinate.longitude
        
        let events = now.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
        
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        var dayHalfStart:  Date
        var dayHalfEnd:  Date
        
        switch self.calendarCode {
        case .HebrewMA:
            let otherDawn = sunrise.sunriseToOtherDawn() // עלות השחר
            let otherDusk = sunset.sunsetToOtherDusk() // צאת הכוכבים
            dayHalfStart = otherDawn;
            dayHalfEnd = otherDusk;
            
        default:
            dayHalfStart = sunrise
            dayHalfEnd = sunset
        } // switch self.calendarCode
        
        var hours:  Double
        var symbol:  String
        let NIGHT_SYMBOL = "☽"
        let NUMBER_OF_HOURS = 12.0
        
        if dayHalfStart <= now && now < dayHalfEnd {
            hours = now.fractionalHours(startDate:  dayHalfStart, endDate:  dayHalfEnd, numberOfHoursPerDay:  NUMBER_OF_HOURS)
            symbol = "☼"
        } else if now < dayHalfStart {
            let previousDate = now.oneDayBefore
            let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
            let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
            var previousDayHalfEnd:  Date
            switch self.calendarCode {
            case .HebrewMA:
                let previousOtherDusk = previousSunset.sunsetToOtherDusk() // צאת הכוכבים
                previousDayHalfEnd = previousOtherDusk;
                
            default:
                previousDayHalfEnd = previousSunset
            } // switch self.calendarCode
            hours = now.fractionalHours(startDate:  previousDayHalfEnd, endDate:  dayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
            symbol = NIGHT_SYMBOL
        } else {
            // now >= dayHalfEnd
            let nextDate = now.oneDayAfter
            let nextEvents = nextDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
            let nextSunrise:  Date = nextEvents[.sunrise]!! //  נץ
            var nextDayHalfStart:  Date
            switch self.calendarCode {
            case .HebrewMA:
                let nextOtherDawn = nextSunrise.sunriseToOtherDawn() // עלות השחר
                nextDayHalfStart = nextOtherDawn;
                
            default:
                nextDayHalfStart = nextSunrise
            } // switch self.calendarCode

            hours = now.fractionalHours(startDate:  dayHalfEnd, endDate:  nextDayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
            symbol = NIGHT_SYMBOL
        }
        
        var result = ""
        switch majorTimeFormat {
        case .decimalTwelveHour:
            result = self.fractionalHoursTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

        case .traditionalJewish:
            result = self.traditionalJewishTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)
            
        case .short, .medium, .long, .full:
            result = self.sexagesimalTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)
            
        default:
            result = self.fractionalHoursTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)
        }
        return result
    } // func timeString(now: Date, localeIdentifier: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String
    
    func fractionalHoursTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
        var result = ""
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 4
        numberFormatter.locale = Locale(identifier:  localeIdentifier)
        result = "\(numberFormatter.string(from: NSNumber(value:  hours)) ?? "") \(symbol)"
        return result
    } // func fractionalHoursTimeString(hours:  Double, symbol:  String) -> String
    
    func traditionalJewishTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
        return self.hoursMinutesSecondsTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier, minutesPerHour:  1080.0, secondsPerMinutes:  76.0, minimumHourDigits:  1, minimumMinuteDigits:  4, minimumSecondDigits:  2)
    } // func traditionalJewishTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String
    
    func sexagesimalTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
        return self.hoursMinutesSecondsTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier, minutesPerHour:  60.0, secondsPerMinutes:  60.0, minimumHourDigits:  1, minimumMinuteDigits:  2, minimumSecondDigits:  2)
    } // func sexagesimalTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String
    
    func hoursMinutesSecondsTimeString(hours:  Double, symbol:  String, localeIdentifier:  String, minutesPerHour:  Double, secondsPerMinutes:  Double, minimumHourDigits:  Int, minimumMinuteDigits:  Int, minimumSecondDigits:  Int) -> String {
        let integralHours = floor(hours)
        let fractionalHours = hours - integralHours
        let totalMinutes = fractionalHours * minutesPerHour
        let integralMinutes = floor(totalMinutes)
        let fractionalMinutes = totalMinutes - integralMinutes
        let totalSeconds = fractionalMinutes * secondsPerMinutes
        let integralSeconds = floor(totalSeconds)
        
        var result = ""
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = Locale(identifier:  localeIdentifier)
        numberFormatter.minimumIntegerDigits = minimumHourDigits
        let hourString = numberFormatter.string(from: NSNumber(value:  integralHours))
        numberFormatter.minimumIntegerDigits = minimumMinuteDigits
        let minuteString = numberFormatter.string(from: NSNumber(value:  integralMinutes))
        numberFormatter.minimumIntegerDigits = minimumSecondDigits
        let secondString = numberFormatter.string(from: NSNumber(value:  integralSeconds))
        result = "\(hourString ?? ""):\(minuteString ?? ""):\(secondString ?? "") \(symbol)"
        return result
    } // func traditionalJewishTimeString(hours:  Double, symbol:  String) -> String

    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        if location == nil {
            return ""
        }
        
        let fixedNow = now.solarCorrected(location: location!, timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
        
        var timeString:  String = ""
        if majorTimeFormat != .none {
            timeString = self.timeString(now: now, localeIdentifier:  localeIdentifier, majorTimeFormat:  majorTimeFormat, timeGeekFormat:  timeGeekFormat, location:  location, timeZone:  timeZone) // TO DO:  EXPAND ON THIS!
        }
        
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        switch majorDateFormat {
        case .localizedLDML:
            let dateFormat = DateFormatter.dateFormat(fromTemplate:dateGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            
        case .none:
            self.dateFormatter.dateStyle = .none
            
        case .full:
            self.dateFormatter.dateStyle = .full
            
        case .long:
            self.dateFormatter.dateStyle = .long
            
        case .medium:
            self.dateFormatter.dateStyle = .medium
            
        case .short:
            self.dateFormatter.dateStyle = .short
            
        default:
            self.dateFormatter.dateStyle = .full
        } // switch majorDateFormat
        
        let dateString = self.dateFormatter.string(from: fixedNow)
        if dateString == "" {
            return timeString
        } else if timeString == "" {
            return dateString
        } else {
            let SEPARATOR = " • "
            return dateString + SEPARATOR + timeString
        }
    } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?) -> String
        
    func dateTimeString(now: Date, localeIdentifier: String, LDMLString: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        if location == nil {
            return ""
        }
        
        let fixedNow = now.solarCorrected(location: location!, timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
        
        self.dateFormatter.dateFormat = LDMLString
        let result = self.dateFormatter.string(from: fixedNow)
        
        return result
    } // func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    var LDMLDetails: Array<ASALDMLDetail> = [
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
    
//    class func HebrewEventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Array<ASAEvent> {
//        let latitude  = location.coordinate.latitude
//        let longitude = location.coordinate.longitude
//        let previousDate = date.oneDayBefore
//        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk], timeZone:  timeZone )
//        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
//        let previousDusk      = previousEvents[.dusk]!! // צאת הכוכבים
//        let previousOtherDusk = previousSunset.addingTimeInterval(72 * 60) // צאת הכוכבים
//
//        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .dawn, .recognition, .dusk], timeZone:  timeZone )
//
//        // According to the גר״א
//        let sunrise:  Date = events[.sunrise]!! // נץ
//        let sunset:  Date = events[.sunset]!! // שקיעה
//
//        let nightLength = sunrise.timeIntervalSince(previousSunset)
//        let midnight =  previousSunset.addingTimeInterval(0.5 * nightLength)
//
//        let dayLength = sunset.timeIntervalSince(sunrise)
//        let hourLength = dayLength / 12.0
//
//        let dawn           = events[.dawn]!! // עלות השחר
//        let recognition    = events[.recognition]!! // משיכיר
//        //        let hour01         = sunrise.addingTimeInterval( 1    * hourLength)
//        //        let hour02         = sunrise.addingTimeInterval( 2    * hourLength)
//        let hour03         = sunrise.addingTimeInterval( 3    * hourLength) // סוף זמן קריאת שמע
//        let hour04         = sunrise.addingTimeInterval( 4    * hourLength) // סוף זמן תפילה
//        //        let hour05         = sunrise.addingTimeInterval( 5    * hourLength)
//        let hour06         = sunrise.addingTimeInterval( 6    * hourLength) // חצות
//        let hour06½        = sunrise.addingTimeInterval( 6.5  * hourLength) // מנחה גדולה
//        //        let hour07         = sunrise.addingTimeInterval( 7    * hourLength)
//        //        let hour08         = sunrise.addingTimeInterval( 8    * hourLength)
//        //        let hour09         = sunrise.addingTimeInterval( 9    * hourLength)
//        let hour09½        = sunrise.addingTimeInterval( 9.5  * hourLength) // מנחה קטנה
//        //        let hour10         = sunrise.addingTimeInterval(10    * hourLength)
//        let hour10¾        = sunrise.addingTimeInterval(10.75 * hourLength) // פלג המנחה
//        //        let hour11         = sunrise.addingTimeInterval(11    * hourLength)
//        let candelLighting = sunset.addingTimeInterval(-18 * 60) // הדלקת נרות
//        let dusk           = events[.dusk]!! // צאת הכוכבים
//
//        // According to the מגן אברהם
//        let otherDawn = sunrise.sunriseToOtherDawn() // עלות השחר
//        let otherDusk = sunset.sunsetToOtherDusk() // צאת הכוכבים
//        let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
//        let otherHourLength = otherDayLength / 12.0
//
//        //        let otherHour01  = otherDawn.addingTimeInterval( 1    * otherHourLength)
//        //        let otherHour02  = otherDawn.addingTimeInterval( 2    * otherHourLength)
//        let otherHour03  = otherDawn.addingTimeInterval( 3    * otherHourLength) // סוף זמן קריאת שמע
//        let otherHour04  = otherDawn.addingTimeInterval( 4    * otherHourLength) // סוף זמן תפילה
//        //        let otherHour05  = otherDawn.addingTimeInterval( 5    * otherHourLength)
//        //        let otherHour06  = otherDawn.addingTimeInterval( 6    * otherHourLength) // חצות
//        let otherHour06½ = otherDawn.addingTimeInterval( 6.5  * otherHourLength) // מנחה גדולה
//        //        let otherHour07  = otherDawn.addingTimeInterval( 7    * otherHourLength)
//        //        let otherHour08  = otherDawn.addingTimeInterval( 8    * otherHourLength)
//        //        let otherHour09  = otherDawn.addingTimeInterval( 9    * otherHourLength)
//        let otherHour09½ = otherDawn.addingTimeInterval( 9.5  * otherHourLength) // מנחה קטנה
//        //        let otherHour10  = otherDawn.addingTimeInterval(10    * otherHourLength)
//        let otherHour10¾ = otherDawn.addingTimeInterval(10.75 * otherHourLength) // פלג המנחה
//        //        let otherHour11  = otherDawn.addingTimeInterval(11    * otherHourLength)
//
//        return [
//            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: previousSunset, endDate: previousSunset, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(DUSK_KEY, comment: ""), startDate: previousDusk, endDate: previousDusk, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_DUSK_KEY, comment: ""), startDate: previousOtherDusk, endDate: previousOtherDusk, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(MIDNIGHT_KEY, comment: ""), startDate: midnight, endDate: midnight, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(DAWN_KEY, comment: ""), startDate: dawn, endDate: dawn, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_DAWN_KEY, comment: ""), startDate: otherDawn, endDate: otherDawn, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(RECOGNITION_KEY, comment: ""), startDate: recognition, endDate: recognition, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(SUNRISE_KEY, comment: ""), startDate: sunrise, endDate: sunrise, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_HOUR_03_KEY, comment: ""), startDate: otherHour03, endDate: otherHour03, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(HOUR_03_KEY, comment: ""), startDate: hour03, endDate: hour03, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_HOUR_04_KEY, comment: ""), startDate: otherHour04, endDate: otherHour04, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(HOUR_04_KEY, comment: ""), startDate: hour04, endDate: hour04, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(NOON_KEY, comment: ""), startDate: hour06, endDate: hour06, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(HOUR_06½_KEY, comment: ""), startDate: hour06½, endDate: hour06½, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_HOUR_06½_KEY, comment: ""), startDate: otherHour06½, endDate: otherHour06½, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(HOUR_09½_KEY, comment: ""), startDate: hour09½, endDate: hour09½, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_HOUR_09½_KEY, comment: ""), startDate: otherHour09½, endDate: otherHour09½, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(HOUR_10¾_KEY, comment: ""), startDate: hour10¾, endDate: hour10¾, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_HOUR_10¾_KEY, comment: ""), startDate: otherHour10¾, endDate: otherHour10¾, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(CANDLELIGHTING_KEY, comment: ""), startDate: candelLighting, endDate: candelLighting, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: sunset, endDate: sunset, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(DUSK_KEY, comment: ""), startDate: dusk, endDate: dusk, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//            ASAEvent(title: NSLocalizedString(OTHER_DUSK_KEY, comment: ""), startDate: otherDusk, endDate: otherDusk, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemBlue)),
//        ]
//    } // func HebrewEventDetails(date:  Date, location:  CLLocation) -> Array<ASADetail>
    
//    class func IslamicEventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Array<ASAEvent> {
//        let latitude  = location.coordinate.latitude
//        let longitude = location.coordinate.longitude
//        
//        let previousDate = date.oneDayBefore
//        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk], timeZone: timeZone )
//        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
//        
//        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset], timeZone: timeZone )
//        
//        let sunrise:  Date = events[.sunrise]!! // נץ
//        let sunset:  Date = events[.sunset]!! // שקיעה
//        
//        let result = [
//            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: previousSunset, endDate: previousSunset, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemGreen)),
//            ASAEvent(title: NSLocalizedString(SUNRISE_KEY, comment: ""), startDate: sunrise, endDate: sunrise, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemGreen)),
//            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: sunset, endDate: sunset, isAllDay: false, timeZone: timeZone, color: Color(UIColor.systemGreen)),
//        ]
//        
//        return result
//    } // func IslamicEventDetails(date:  Date, location:  CLLocation) -> Array<ASAEvent>
    
    
//    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent> {
//        if location == nil {
//            return []
//        }
//        
//        switch self.calendarCode {
//        case .HebrewGRA, .HebrewMA:
//            return ASASunsetTransitionCalendar.self.HebrewEventDetails(date: date, location: location!, timeZone: timeZone)
//            
//        case .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
//            return ASASunsetTransitionCalendar.self.IslamicEventDetails(date: date, location: location!, timeZone: timeZone)
//            
//        default:
//            return []
//        }
//    } // func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent>
    
    var supportsLocales: Bool = true
    
    var supportsDateFormats: Bool = true
    
    var supportsTimeZones: Bool = false
    
    func startOfDay(for date: Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
        if location == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }

        let yesterday: Date = date.addingTimeInterval(-24 * 60 * 60)
        let fixedYesterday = yesterday.solarCorrected(location: location!, timeZone: timeZone)
        let events = fixedYesterday.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.sunset], timeZone: timeZone )
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        if self.calendarCode == .HebrewMA {
            let otherDusk = sunset.sunsetToOtherDusk() // צאת הכוכבים
            return otherDusk
        }
        return sunset
    }
    
    func startOfNextDay(date: Date, location: CLLocation?, timeZone:  TimeZone) -> Date {
        if location == nil {
            return date.sixPM(timeZone: timeZone)
        }
        
        let fixedNow = date.solarCorrected(location: location!, timeZone: timeZone)
        let events = fixedNow.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.sunset], timeZone: timeZone )
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        if self.calendarCode == .HebrewMA {
            let otherDusk = sunset.sunsetToOtherDusk() // צאת הכוכבים
            return otherDusk
        }
        return sunset
    } // func transitionToNextDay(now: Date, location: CLLocation?, timeZone:  TimeZone) -> Date
    
    var supportsLocations: Bool = true
    
    var supportsEventDetails: Bool = true
    
    var supportsTimes: Bool = true
    
    var supportedMajorDateFormats: Array<ASAMajorDateFormat> = [
        .full,
        .long,
        .medium,
        .short,
        .localizedLDML
    ]
    
    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [.full, .long, .medium, .short, .decimalTwelveHour, .traditionalJewish]
    
    var supportsTimeFormats: Bool = true
    
    var canSplitTimeFromDate:  Bool = true
    
    var defaultMajorTimeFormat:  ASAMajorTimeFormat = .decimalTwelveHour
} // class ASASunsetTransitionCalendar
