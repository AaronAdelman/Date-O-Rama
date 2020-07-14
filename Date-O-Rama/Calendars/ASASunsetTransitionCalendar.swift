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

 let MIDNIGHT_KEY          = "midnight"
 let SUNRISE_KEY           = "sunrise"
 let NOON_KEY              = "noon"
 let SUNSET_KEY            = "sunset"
 let CIVIL_DAWN_KEY        = "civilDawn"
 let CIVIL_DUSK_KEY        = "civilDusk"
 let NAUTICAL_DAWN_KEY     = "nauticalDawn"
 let NAUTICAL_DUSK_KEY     = "nauticalDusk"
 let ASTRONOMICAL_DAWN_KEY = "astronomicalDawn"
 let ASTRONOMICAL_DUSK_KEY = "astronomicalDusk"

 let DAWN_KEY              = "dawn"
 let RECOGNITION_KEY       = "recognition"
 let HOUR_03_KEY           = "hour03"
 let HOUR_04_KEY           = "hour04"
 let HOUR_06½_KEY          = "hour06½"
 let HOUR_09½_KEY          = "hour09½"
 let HOUR_10¾_KEY          = "hour10¾"
 let CANDLELIGHTING_KEY    = "candlelighting"
 let DUSK_KEY              = "dusk"

 let OTHER_DAWN_KEY        = "otherDawn"
 let OTHER_HOUR_03_KEY     = "otherHour03"
 let OTHER_HOUR_04_KEY     = "otherHour04"
 let OTHER_HOUR_06½_KEY    = "otherHour06½"
 let OTHER_HOUR_09½_KEY    = "otherHour09½"
 let OTHER_HOUR_10¾_KEY    = "otherHour10¾"
 let OTHER_DUSK_KEY        = "otherDusk"


 // MARK: -

 class ASASunsetTransitionCalendar:  ASACalendar {
     var calendarCode: ASACalendarCode
         
     var defaultMajorDateFormat:  ASAMajorDateFormat = .full  // TODO:  Rethink this when dealing with watchOS
     
     var dateFormatter = DateFormatter()
     
    private func appropriateCalendar() -> Calendar {
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        let calendar = Calendar(identifier: calendarIdentifier)
        return calendar
    } // func appropriateCalendar() -> Calendar

     init(calendarCode:  ASACalendarCode) {
         self.calendarCode = calendarCode
         //        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
         //        let calendar = Calendar(identifier: calendarIdentifier)
                 let calendar = self.appropriateCalendar()
                 dateFormatter.calendar = calendar
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
                 
         var dayHalfStart:  Date
         var dayHalfEnd:  Date
         
         switch self.calendarCode {
         case .HebrewMA:
             let events = now.solarEvents(latitude: latitude, longitude: longitude, events: [.dawn72Minutes, .dusk72Minutes], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)

             let otherDawn = events[.dawn72Minutes]!! // עלות השחר
             let otherDusk = events[.dusk72Minutes]!! // צאת הכוכבים
             dayHalfStart = otherDawn;
             dayHalfEnd = otherDusk;
             
         default:
             let events = now.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
             
             let sunrise:  Date = events[.sunrise]!! // נץ
             let sunset:  Date = events[.sunset]!! // שקיעה

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
             var previousDayHalfEnd:  Date
             switch self.calendarCode {
             case .HebrewMA:
                 let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.dusk72Minutes], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
                 let previousOtherDusk:  Date = previousEvents[.dusk72Minutes]!! // צאת הכוכבים
                 previousDayHalfEnd = previousOtherDusk;
                 
             default:
                 let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
                 let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
                 previousDayHalfEnd = previousSunset
             } // switch self.calendarCode
             hours = now.fractionalHours(startDate:  previousDayHalfEnd, endDate:  dayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
             symbol = NIGHT_SYMBOL
         } else {
             // now >= dayHalfEnd
             let nextDate = now.oneDayAfter
             var nextDayHalfStart:  Date
             switch self.calendarCode {
             case .HebrewMA:
                 let nextEvents = nextDate.solarEvents(latitude: latitude, longitude: longitude, events: [.dawn72Minutes], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
                 let nextOtherDawn:  Date = nextEvents[.dawn72Minutes]!! // עלות השחר
                 nextDayHalfStart = nextOtherDawn;
                 
             default:
                 let nextEvents = nextDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
                 let nextSunrise:  Date = nextEvents[.sunrise]!! //  נץ
                 nextDayHalfStart = nextSunrise
             } // switch self.calendarCode

             hours = now.fractionalHours(startDate:  dayHalfEnd, endDate:  nextDayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
             symbol = NIGHT_SYMBOL
         }
         
         var result = ""
         switch majorTimeFormat {
         case .decimalTwelveHour:
             result = self.fractionalHoursTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

         case .JewishCalendricalCalculation:
             result = self.JewishCalendricalCalculationTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)
             
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
     
     func JewishCalendricalCalculationTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
         return self.hoursMinutesSecondsTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier, minutesPerHour:  1080.0, secondsPerMinutes:  76.0, minimumHourDigits:  1, minimumMinuteDigits:  4, minimumSecondDigits:  2)
     } // func JewishCalendricalCalculationTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String
     
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
     } // func JewishCalendricalCalculationTimeString(hours:  Double, symbol:  String) -> String

     
     func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
         if location == nil {
             return "No location"
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
             let SEPARATOR = ", "
             return dateString + SEPARATOR + timeString
         }
     } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?) -> String
         
     func dateTimeString(now: Date, localeIdentifier: String, LDMLString: String, location: CLLocation?, timeZone: TimeZone?) -> String {
         if location == nil {
             return "No location"
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
     
     var supportsLocales: Bool = true
     
     var supportsDateFormats: Bool = true
     
     var supportsTimeZones: Bool = false
     
     func startOfDay(for date: Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
         if location == nil {
             return date.sixPMYesterday(timeZone: timeZone)
         }

         let yesterday: Date = date.addingTimeInterval(-24 * 60 * 60)
         let fixedYesterday = yesterday.solarCorrected(location: location!, timeZone: timeZone)
         
         if self.calendarCode == .HebrewMA {
             let events = fixedYesterday.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.dusk72Minutes], timeZone: timeZone )
             let otherDusk = events[.dusk72Minutes]!! // צאת הכוכבים
             return otherDusk
         }

         let events = fixedYesterday.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.sunset], timeZone: timeZone )
         let sunset:  Date = events[.sunset]!! // שקיעה
         return sunset
     }
     
     func startOfNextDay(date: Date, location: CLLocation?, timeZone:  TimeZone) -> Date {
         if location == nil {
             return date.sixPM(timeZone: timeZone)
         }
         
         let fixedNow = date.solarCorrected(location: location!, timeZone: timeZone)
         
         if self.calendarCode == .HebrewMA {
             let events = fixedNow.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.dusk72Minutes], timeZone: timeZone )
             let otherDusk = events[.dusk72Minutes]!! // צאת הכוכבים
             return otherDusk
         }
         
         let events = fixedNow.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [.sunset], timeZone: timeZone )
         let sunset:  Date = events[.sunset]!! // שקיעה
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
     
     var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [.full, .long, .medium, .short, .decimalTwelveHour, .JewishCalendricalCalculation]
     
     var supportsTimeFormats: Bool = true
     
     var canSplitTimeFromDate:  Bool = true
     
     var defaultMajorTimeFormat:  ASAMajorTimeFormat = .decimalTwelveHour
    
    
    // MARK: -
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let ApplesDateComponents = dateComponents.ApplesDateComponents()
        return ApplesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let ApplesDateComponents = dateComponents.ApplesDateComponents()

        return ApplesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        var ApplesComponents = Set<Calendar.Component>()
        for component in components {
            let ApplesCalendarComponent = component.calendarComponent()
            if ApplesCalendarComponent != nil {
                ApplesComponents.insert(ApplesCalendarComponent!)
            }
        } // for component in components
        
        let calendar = self.appropriateCalendar()
        let ApplesDateComponents = calendar.dateComponents(ApplesComponents, from: date)
        return ASADateComponents.new(with: ApplesDateComponents, calendar: self, locationData: locationData)
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents
 } // class ASASunsetTransitionCalendar
