//
//  ASASolarCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-22.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Solar event keys

let PREVIOUS_SUNSET_KEY               = "previousSunset"
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

let PREVIOUS_DUSK_KEY                 = "previousDusk"
let DAWN_KEY                          = "dawn"
let RECOGNITION_KEY                   = "recognition"
let HOUR_03_KEY                       = "hour03"
let HOUR_04_KEY                       = "hour04"
let HOUR_06½_KEY                      = "hour06½"
let HOUR_09½_KEY                      = "hour09½"
let HOUR_10¾_KEY                      = "hour10¾"
let CANDLELIGHTING_KEY                = "candlelighting"
let DUSK_KEY                          = "dusk"

let PREVIOUS_OTHER_DUSK_KEY           = "previousOtherDusk"
let OTHER_DAWN_KEY                    = "otherDawn"
let OTHER_HOUR_03_KEY                 = "otherHour03"
let OTHER_HOUR_04_KEY                 = "otherHour04"
let OTHER_HOUR_06½_KEY                = "otherHour06½"
let OTHER_HOUR_09½_KEY                = "otherHour09½"
let OTHER_HOUR_10¾_KEY                = "otherHour10¾"
let OTHER_DUSK_KEY                    = "otherDusk"


// MARK: -

class ASASolarCalendar:  ASACalendar {
//    var calendarIdentifier:  Calendar.Identifier?
    
    var calendarCode: ASACalendarCode
    
    var dateFormatter = DateFormatter()
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        //        self.calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        
        dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
    } // init(calendarCode:  ASACalendarCode)
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String {
        return "eee, d MMM y"
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        if location == nil {
            return ""
        }
        
        let fixedNow = now.solarCorrected(location: location!)
        
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        if majorDateFormat == .localizedLDML {
            let dateFormat = DateFormatter.dateFormat(fromTemplate:dateGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            return self.dateFormatter.string(from: fixedNow)
        }
        
        if majorDateFormat == .full {
            self.dateFormatter.dateStyle = .full
            return self.dateFormatter.string(from: fixedNow)
        }
        
        if majorDateFormat == .long {
            self.dateFormatter.dateStyle = .long
            return self.dateFormatter.string(from: fixedNow)
        }
        
        if majorDateFormat == .medium {
            self.dateFormatter.dateStyle = .medium
            return self.dateFormatter.string(from: fixedNow)
        }
        
        if majorDateFormat == .short {
            self.dateFormatter.dateStyle = .short
            return self.dateFormatter.string(from: fixedNow)
        }
        
        return "Error!"
    } // func dateString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateString(now: Date, localeIdentifier: String, LDMLString: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        if location == nil {
            return ""
        }
        
        let fixedNow = now.solarCorrected(location: location!)
        
        self.dateFormatter.dateFormat = LDMLString
        let result = self.dateFormatter.string(from: fixedNow)
        
        return result
    } // func dateString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
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
    
    func HebrewEventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail> {
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let previousDate = date.addingTimeInterval(-24 * 60 * 60)
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk])
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        let previousDusk      = previousEvents[.dusk]!! // צאת הכוכבים
        let previousOtherDusk = previousSunset.addingTimeInterval(72 * 60) // צאת הכוכבים
        
        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .dawn, .recognition, .dusk])
        
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
            ASAEventDetail(key: PREVIOUS_SUNSET_KEY, value: previousSunset),
            ASAEventDetail(key: PREVIOUS_DUSK_KEY, value: previousDusk),
            ASAEventDetail(key: PREVIOUS_OTHER_DUSK_KEY, value: previousOtherDusk),
            ASAEventDetail(key: MIDNIGHT_KEY, value: midnight),
            ASAEventDetail(key: OTHER_DAWN_KEY, value: otherDawn),
            ASAEventDetail(key: DAWN_KEY, value: dawn),
            ASAEventDetail(key: RECOGNITION_KEY, value: recognition),
            ASAEventDetail(key: SUNRISE_KEY, value: sunrise),
            ASAEventDetail(key: OTHER_HOUR_03_KEY, value: otherHour03),
            ASAEventDetail(key: HOUR_03_KEY, value: hour03),
            ASAEventDetail(key: OTHER_HOUR_04_KEY, value: otherHour04),
            ASAEventDetail(key: HOUR_04_KEY, value: hour04),
            ASAEventDetail(key: NOON_KEY, value: hour06),
            ASAEventDetail(key: HOUR_06½_KEY, value: hour06½),
            ASAEventDetail(key: OTHER_HOUR_06½_KEY, value: otherHour06½),
            ASAEventDetail(key: HOUR_09½_KEY, value: hour09½),
            ASAEventDetail(key: OTHER_HOUR_09½_KEY, value: otherHour09½),
            ASAEventDetail(key: HOUR_10¾_KEY, value: hour10¾),
            ASAEventDetail(key: OTHER_HOUR_10¾_KEY, value: otherHour10¾),
            ASAEventDetail(key: CANDLELIGHTING_KEY, value: candelLighting),
            ASAEventDetail(key: SUNSET_KEY, value: sunset),
            ASAEventDetail(key: DUSK_KEY, value: dusk),
            ASAEventDetail(key: OTHER_DUSK_KEY, value: otherDusk),
        ]
    } // func HebrewEventDetails(date:  Date, location:  CLLocation) -> Array<ASADetail>
    
    func IslamicEventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail> {
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let previousDate = date.addingTimeInterval(-24 * 60 * 60)
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk])
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        
        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset])
        
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        return [
            ASAEventDetail(key: PREVIOUS_SUNSET_KEY, value: previousSunset),
            ASAEventDetail(key: SUNRISE_KEY, value: sunrise),
            ASAEventDetail(key: SUNSET_KEY, value: sunset),
        ]
    } // func IslamicEventDetails(date:  Date, location:  CLLocation) -> Array<ASAEventDetail>
    
    
    func eventDetails(date:  Date, location:  CLLocation?) -> Array<ASAEventDetail> {
        if location == nil {
            return []
        }
        
        switch self.calendarCode {
        case .HebrewSolar:
            return self.HebrewEventDetails(date: date, location: location!)
            
        case .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
            return self.IslamicEventDetails(date: date, location: location!)
            
        default:
            return []
        }
    } // func eventDetails(date:  Date, location:  CLLocation?) -> Array<ASAEventDetail>
    
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
            return now.sixPM()
        }
        
        let fixedNow = now.solarCorrected(location: location!)
        let events = fixedNow.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.sunset])
        return events[.sunset]!!
    } // func transitionToNextDay(now: Date, location: CLLocation?, timeZone:  TimeZone) -> Date
    
    func supportsLocations() -> Bool {
        return true
    } // func supportsLocations() -> Bool
    
    func supportsEventDetails() -> Bool {
        return true
    } // func supportsEventDetails() -> Bool
    
    
//    func timeZone(location:  CLLocation?) -> TimeZone {
//        return TimeZone.autoupdatingCurrent // FIX THIS
//    } // func timeZone(location:  CLLocation?) -> TimeZone
}
