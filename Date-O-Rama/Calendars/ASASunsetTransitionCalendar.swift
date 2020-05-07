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


// MARK: -

class ASASunsetTransitionCalendar:  ASACalendar {
    var calendarCode: ASACalendarCode
    
    var color: UIColor {
        get {
            switch self.calendarCode {
            case .HebrewSolar:
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
    
    func hours(now:  Date, startDate:  Date, endDate:  Date) -> Double {
        let seconds = now.timeIntervalSince(startDate)
        let hourLength = endDate.timeIntervalSince(startDate) / 12.0
        let hours = seconds / hourLength
        return hours
    } // func hours(startDate:  Date, endDate:  Date) -> Double
    
    func timeString(now: Date, localeIdentifier: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        let latitude  = location!.coordinate.latitude
        let longitude = location!.coordinate.longitude
        
        let events = now.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
        
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה

        var hours:  Double
        var symbol:  String
        let NIGHT_SYMBOL = "☽"
        
        if sunrise <= now && now < sunset {
            hours = self.hours(now:  now, startDate:  sunrise, endDate:  sunset)
            symbol = "☼"
        } else if now < sunrise {
            let previousDate = now.addingTimeInterval(-24 * 60 * 60)
            let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
            let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה

            hours = self.hours(now:  now, startDate:  previousSunset, endDate:  sunrise)
            symbol = NIGHT_SYMBOL
        } else {
            // now >= sunset
            let nextDate = now.addingTimeInterval(24 * 60 * 60)
            let nextEvents = nextDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
            let nextSunrise:  Date = nextEvents[.sunrise]!! //  נץ

            hours = self.hours(now:  now, startDate:  sunset, endDate:  nextSunrise)
            symbol = NIGHT_SYMBOL
        }
        
        var result = ""
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 4
        numberFormatter.locale = Locale(identifier:  localeIdentifier)
        result = "\(numberFormatter.string(from: NSNumber(value:  hours)) ?? "") \(symbol)"
        return result
    }
    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        if location == nil {
            return ""
        }
        
        let fixedNow = now.solarCorrected(location: location!, timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
        
        var timeSuffix = ""
        if majorTimeFormat != .none {
            let timeString = self.timeString(now: now, localeIdentifier:  localeIdentifier, majorTimeFormat:  majorTimeFormat, timeGeekFormat:  timeGeekFormat, location:  location, timeZone:  timeZone) // TO DO:  EXPAND ON THIS!
            let SEPARATOR = " • "
            timeSuffix = SEPARATOR + timeString
        }
        
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        
        if majorDateFormat == .localizedLDML {
            let dateFormat = DateFormatter.dateFormat(fromTemplate:dateGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            return self.dateFormatter.string(from: fixedNow) + timeSuffix
        }
        
        if majorDateFormat == .full {
            self.dateFormatter.dateStyle = .full
            return self.dateFormatter.string(from: fixedNow) + timeSuffix
        }
        
        if majorDateFormat == .long {
            self.dateFormatter.dateStyle = .long
            return self.dateFormatter.string(from: fixedNow) + timeSuffix
        }
        
        if majorDateFormat == .medium {
            self.dateFormatter.dateStyle = .medium
            return self.dateFormatter.string(from: fixedNow) + timeSuffix
        }
        
        if majorDateFormat == .short {
            self.dateFormatter.dateStyle = .short
            return self.dateFormatter.string(from: fixedNow) + timeSuffix
        }
        
        return "Error!"
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
    
    func LDMLDetails() -> Array<ASALDMLDetail> {
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
    
    func HebrewEventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Array<ASAEvent> {
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let previousDate = date.addingTimeInterval(-24 * 60 * 60)
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk], timeZone:  timeZone )
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        let previousDusk      = previousEvents[.dusk]!! // צאת הכוכבים
        let previousOtherDusk = previousSunset.addingTimeInterval(72 * 60) // צאת הכוכבים
        
        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .dawn, .recognition, .dusk], timeZone:  timeZone )
        
        // According to the גר״א
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        let nightLength = sunrise.timeIntervalSince(previousSunset)
        let midnight =  previousSunset.addingTimeInterval(0.5 * nightLength)
        
        let dayLength = sunset.timeIntervalSince(sunrise)
        let hourLength = dayLength / 12.0
        
        let dawn           = events[.dawn]!! // עלות השחר
        let recognition    = events[.recognition]!! // משיכיר
        //        let hour01         = sunrise.addingTimeInterval( 1    * hourLength)
        //        let hour02         = sunrise.addingTimeInterval( 2    * hourLength)
        let hour03         = sunrise.addingTimeInterval( 3    * hourLength) // סוף זמן קריאת שמע
        let hour04         = sunrise.addingTimeInterval( 4    * hourLength) // סוף זמן תפילה
        //        let hour05         = sunrise.addingTimeInterval( 5    * hourLength)
        let hour06         = sunrise.addingTimeInterval( 6    * hourLength) // חצות
        let hour06½        = sunrise.addingTimeInterval( 6.5  * hourLength) // מנחה גדולה
        //        let hour07         = sunrise.addingTimeInterval( 7    * hourLength)
        //        let hour08         = sunrise.addingTimeInterval( 8    * hourLength)
        //        let hour09         = sunrise.addingTimeInterval( 9    * hourLength)
        let hour09½        = sunrise.addingTimeInterval( 9.5  * hourLength) // מנחה קטנה
        //        let hour10         = sunrise.addingTimeInterval(10    * hourLength)
        let hour10¾        = sunrise.addingTimeInterval(10.75 * hourLength) // פלג המנחה
        //        let hour11         = sunrise.addingTimeInterval(11    * hourLength)
        let candelLighting = sunset.addingTimeInterval(-18 * 60) // הדלקת נרות
        let dusk           = events[.dusk]!! // צאת הכוכבים
        
        // According to the מגן אברהם
        let otherDawn = sunrise.addingTimeInterval(-72 * 60) // עלות השחר
        let otherDusk = sunset.addingTimeInterval(72 * 60) // צאת הכוכבים
        let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
        let otherHourLength = otherDayLength / 12.0
        
        //        let otherHour01  = otherDawn.addingTimeInterval( 1    * otherHourLength)
        //        let otherHour02  = otherDawn.addingTimeInterval( 2    * otherHourLength)
        let otherHour03  = otherDawn.addingTimeInterval( 3    * otherHourLength) // סוף זמן קריאת שמע
        let otherHour04  = otherDawn.addingTimeInterval( 4    * otherHourLength) // סוף זמן תפילה
        //        let otherHour05  = otherDawn.addingTimeInterval( 5    * otherHourLength)
        //        let otherHour06  = otherDawn.addingTimeInterval( 6    * otherHourLength) // חצות
        let otherHour06½ = otherDawn.addingTimeInterval( 6.5  * otherHourLength) // מנחה גדולה
        //        let otherHour07  = otherDawn.addingTimeInterval( 7    * otherHourLength)
        //        let otherHour08  = otherDawn.addingTimeInterval( 8    * otherHourLength)
        //        let otherHour09  = otherDawn.addingTimeInterval( 9    * otherHourLength)
        let otherHour09½ = otherDawn.addingTimeInterval( 9.5  * otherHourLength) // מנחה קטנה
        //        let otherHour10  = otherDawn.addingTimeInterval(10    * otherHourLength)
        let otherHour10¾ = otherDawn.addingTimeInterval(10.75 * otherHourLength) // פלג המנחה
        //        let otherHour11  = otherDawn.addingTimeInterval(11    * otherHourLength)
        
        return [
            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: previousSunset, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(DUSK_KEY, comment: ""), startDate: previousDusk, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_DUSK_KEY, comment: ""), startDate: previousOtherDusk, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(MIDNIGHT_KEY, comment: ""), startDate: midnight, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(DAWN_KEY, comment: ""), startDate: dawn, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_DAWN_KEY, comment: ""), startDate: otherDawn, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(RECOGNITION_KEY, comment: ""), startDate: recognition, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(SUNRISE_KEY, comment: ""), startDate: sunrise, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_03_KEY, comment: ""), startDate: otherHour03, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(HOUR_03_KEY, comment: ""), startDate: hour03, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_04_KEY, comment: ""), startDate: otherHour04, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(HOUR_04_KEY, comment: ""), startDate: hour04, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(NOON_KEY, comment: ""), startDate: hour06, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(HOUR_06½_KEY, comment: ""), startDate: hour06½, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_06½_KEY, comment: ""), startDate: otherHour06½, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(HOUR_09½_KEY, comment: ""), startDate: hour09½, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_09½_KEY, comment: ""), startDate: otherHour09½, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(HOUR_10¾_KEY, comment: ""), startDate: hour10¾, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_10¾_KEY, comment: ""), startDate: otherHour10¾, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(CANDLELIGHTING_KEY, comment: ""), startDate: candelLighting, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: sunset, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(DUSK_KEY, comment: ""), startDate: dusk, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(OTHER_DUSK_KEY, comment: ""), startDate: otherDusk, calendar: self, timeZone: timeZone),
        ]
    } // func HebrewEventDetails(date:  Date, location:  CLLocation) -> Array<ASADetail>
    
    func IslamicEventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Array<ASAEvent> {
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let previousDate = date.addingTimeInterval(-24 * 60 * 60)
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk], timeZone: timeZone )
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        
        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset], timeZone: timeZone )
        
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        let result = [
            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: previousSunset, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(SUNRISE_KEY, comment: ""), startDate: sunrise, calendar: self, timeZone: timeZone),
            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: sunset, calendar: self, timeZone: timeZone),
        ]
        
        return result
    } // func IslamicEventDetails(date:  Date, location:  CLLocation) -> Array<ASAEvent>
    
    
    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent> {
        if location == nil {
            return []
        }
        
        switch self.calendarCode {
        case .HebrewSolar:
            return self.HebrewEventDetails(date: date, location: location!, timeZone: timeZone)
            
        case .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
            return self.IslamicEventDetails(date: date, location: location!, timeZone: timeZone)
            
        default:
            return []
        }
    } // func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent>
    
    func supportsLocales() -> Bool {
        return true
    } // func supportsLocales() -> Bool
    
    func supportsDateFormats() -> Bool {
        return true
    } // func supportsDateFormats() -> Bool
    
    func supportsTimeZones() -> Bool {
        return false
    } // func supportsTimeZones() -> Bool
    
    func startOfNextDay(now: Date, location: CLLocation?, timeZone:  TimeZone) -> Date {
        if location == nil {
            return now.sixPM(timeZone: timeZone)
        }
        
        let fixedNow = now.solarCorrected(location: location!, timeZone: timeZone)
        let events = fixedNow.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.sunset], timeZone: timeZone )
        return events[.sunset]!!
    } // func transitionToNextDay(now: Date, location: CLLocation?, timeZone:  TimeZone) -> Date
    
    func supportsLocations() -> Bool {
        return true
    } // func supportsLocations() -> Bool
    
    func supportsEventDetails() -> Bool {
        return true
    } // func supportsEventDetails() -> Bool
    
    func supportsTimes() -> Bool {
        return true
    } // func supportsTimes() -> Bool
    
    func supportedMajorDateFormats() -> Array<ASAMajorDateFormat> {
        return [
            .full,
            .long,
            .medium,
            .short,
            .localizedLDML
        ]
    } // func supportedMajorDateFormats() -> Array<ASAMajorDateFormat>
} // class ASASunsetTransitionCalendar
