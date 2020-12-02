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

 // MARK: -

 public class ASASunsetTransitionCalendar:  ASACalendar {
    var calendarCode: ASACalendarCode

    #if os(watchOS)
    var defaultMajorDateFormat:  ASAMajorDateFormat = .short
    #else
    var defaultMajorDateFormat:  ASAMajorDateFormat = .full
    #endif

    public var dateFormatter = DateFormatter()

    private var ApplesCalendar:  Calendar

    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        ApplesCalendar = Calendar(identifier: calendarIdentifier)
        dateFormatter.calendar = ApplesCalendar
    } // init(calendarCode:  ASACalendarCode)

    func defaultDateGeekCode(majorDateFormat: ASAMajorDateFormat) -> String {
        return "eee, d MMM y"
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String

    func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String {
        return "HH:mm:ss"
    } // func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String

    var dayStart:  ASASolarEvent {
        get {
            switch self.calendarCode {
            case .HebrewMA:
                return .dawn72Minutes

            default:
                return .sunrise
            } // switch self.calendarCode
        } // get
    } // var dayStart

    var dayEnd:  ASASolarEvent {
        get {
            switch self.calendarCode {
            case .HebrewMA:
                return .dusk72Minutes

            default:
                return .sunset
            } // switch self.calendarCode
        } // get
    } //

    fileprivate func invalidTimeString() -> String {
        return NSLocalizedString("NO_SOLAR_TIME", comment: "")
    }

    func solarTimeComponents(now: Date, location: CLLocation?, timeZone: TimeZone?, transition:  Date??) -> (hours:  Double, daytime:  Bool, valid:  Bool) {
        let latitude  = location!.coordinate.latitude
        let longitude = location!.coordinate.longitude

        var existsSolarTime = true
        if transition == nil {
            existsSolarTime = false
        }
        if transition! == nil {
            existsSolarTime = false
        }
        if !existsSolarTime {
            return (hours:  -1.0, daytime:  false, valid:  false)
        }
        //        debugPrint(#file, #function, "Now:", now, localeIdentifier, majorTimeFormat, timeGeekFormat, location!, timeZone!, "Transition:", transition!!)

        var dayHalfStart:  Date
        //        var dayHalfEnd:  Date

        var hours:  Double
//        var symbol:  String
//        let NIGHT_SYMBOL    = "☽"
//        let DAY_SYMBOL      = "☼"
        var daytime:  Bool
        let NUMBER_OF_HOURS = 12.0

        let deoptionalizedTransition: Date = transition!!
        if deoptionalizedTransition <= now  {
            // Nighttime, transition is at the start of the nighttime
            //            debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Nighttime, transition is at the start of the nighttime")
            //            let nextDate = now.oneDayAfter
            let nextDate = now.noon(timeZone:  timeZone!).oneDayAfter
            var nextDayHalfStart:  Date
            let nextEvents = nextDate.solarEvents(latitude: latitude, longitude: longitude, events: [self.dayStart], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
            nextDayHalfStart = nextEvents[self.dayStart]!!
            assert(nextDayHalfStart > deoptionalizedTransition)

            //            debugPrint(#file, #function, "Now:", now, "Nighttime start:", deoptionalizedTransition, "Nighttime end:", nextDayHalfStart)

            hours = now.fractionalHours(startDate:  deoptionalizedTransition, endDate:  nextDayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
//            symbol = NIGHT_SYMBOL
            daytime = false
        } else {
            // now < deoptionalizedTransition
            let ourTimeZone = timeZone ?? TimeZone.autoupdatingCurrent
            let events = now.noon(timeZone:ourTimeZone).solarEvents(latitude: latitude, longitude: longitude, events: [self.dayStart], timeZone: ourTimeZone)

            let rawDayHalfStart: Date?? = events[self.dayStart]

            if rawDayHalfStart == nil {
                return (hours:  -1.0, daytime:  false, valid:  false)
            }
            if rawDayHalfStart! == nil {
                return (hours:  -1.0, daytime:  false, valid:  false)
            }

            dayHalfStart = rawDayHalfStart!!

            var jiggeredNow = now
            if dayHalfStart > deoptionalizedTransition {
                // Uh-oh.  It found the day half start for the wrong day!
                jiggeredNow = now - 24 * 60 * 60
                let events = jiggeredNow.solarEvents(latitude: latitude, longitude: longitude, events: [self.dayStart], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)

                let rawDayHalfStart: Date?? = events[self.dayStart]

                if rawDayHalfStart == nil {
                    return (hours:  -1.0, daytime:  false, valid:  false)
                }
                if rawDayHalfStart! == nil {
                    return (hours:  -1.0, daytime:  false, valid:  false)
                }

                dayHalfStart = rawDayHalfStart!!
            }

            //            debugPrint(#file, #function, "Day half start:", dayHalfStart)

            if dayHalfStart <= now && now < deoptionalizedTransition {
                // Daytime
                //                debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Daytime")
                assert(deoptionalizedTransition > dayHalfStart)
                hours = now.fractionalHours(startDate:  dayHalfStart, endDate:  deoptionalizedTransition, numberOfHoursPerDay:  NUMBER_OF_HOURS)
//                symbol = DAY_SYMBOL
                daytime = true
            } else {
                // Previous nighttime
                //                debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Previous nighttime")
                var previousDayHalfEnd:  Date
                previousDayHalfEnd = self.startOfDay(for: jiggeredNow, location: location, timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
                assert(dayHalfStart > previousDayHalfEnd)
                //                debugPrint(#file, #function, "Previous day half end:", previousDayHalfEnd, "Day half start:", dayHalfStart)
                hours = now.fractionalHours(startDate:  previousDayHalfEnd, endDate:  dayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
//                symbol = NIGHT_SYMBOL
                daytime = false
            }
        }

        return (hours:  hours, daytime:  daytime, valid:  true)
    } // func solarTimeComponents(now: Date, localeIdentifier: String, location: CLLocation?, timeZone: TimeZone?, transition:  Date??) -> (hours:  Double, daytime:  Bool, valid:  Bool)

    func timeString(now: Date, localeIdentifier: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?, transition:  Date??) -> String {
//        let latitude  = location!.coordinate.latitude
//        let longitude = location!.coordinate.longitude
//
//        var existsSolarTime = true
//        if transition == nil {
//            existsSolarTime = false
//        }
//        if transition! == nil {
//            existsSolarTime = false
//        }
//        if !existsSolarTime {
//            return invalidTimeString()
//        }
////        debugPrint(#file, #function, "Now:", now, localeIdentifier, majorTimeFormat, timeGeekFormat, location!, timeZone!, "Transition:", transition!!)
//
//        var dayHalfStart:  Date
//        //        var dayHalfEnd:  Date
//
//        var hours:  Double
//        var symbol:  String
        let NIGHT_SYMBOL    = "☽"
        let DAY_SYMBOL      = "☼"
//        let NUMBER_OF_HOURS = 12.0
//
//        let deoptionalizedTransition: Date = transition!!
//        if deoptionalizedTransition <= now  {
//            // Nighttime, transition is at the start of the nighttime
////            debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Nighttime, transition is at the start of the nighttime")
//            //            let nextDate = now.oneDayAfter
//            let nextDate = now.noon(timeZone:  timeZone!).oneDayAfter
//            var nextDayHalfStart:  Date
//            let nextEvents = nextDate.solarEvents(latitude: latitude, longitude: longitude, events: [self.dayStart], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
//            nextDayHalfStart = nextEvents[self.dayStart]!!
//            assert(nextDayHalfStart > deoptionalizedTransition)
//
////            debugPrint(#file, #function, "Now:", now, "Nighttime start:", deoptionalizedTransition, "Nighttime end:", nextDayHalfStart)
//
//            hours = now.fractionalHours(startDate:  deoptionalizedTransition, endDate:  nextDayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
//            symbol = NIGHT_SYMBOL
//        } else {
//            // now < deoptionalizedTransition
//            let ourTimeZone = timeZone ?? TimeZone.autoupdatingCurrent
//            let events = now.noon(timeZone:ourTimeZone).solarEvents(latitude: latitude, longitude: longitude, events: [self.dayStart], timeZone: ourTimeZone)
//
//            let rawDayHalfStart: Date?? = events[self.dayStart]
//
//            if rawDayHalfStart == nil {
//                return invalidTimeString()
//            }
//            if rawDayHalfStart! == nil {
//                return invalidTimeString()
//            }
//
//            dayHalfStart = rawDayHalfStart!!
//
//            var jiggeredNow = now
//            if dayHalfStart > deoptionalizedTransition {
//                // Uh-oh.  It found the day half start for the wrong day!
//                jiggeredNow = now - 24 * 60 * 60
//                let events = jiggeredNow.solarEvents(latitude: latitude, longitude: longitude, events: [self.dayStart], timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
//
//                let rawDayHalfStart: Date?? = events[self.dayStart]
//
//                if rawDayHalfStart == nil {
//                    return invalidTimeString()
//                }
//                if rawDayHalfStart! == nil {
//                    return invalidTimeString()
//                }
//
//                dayHalfStart = rawDayHalfStart!!
//            }
//
////            debugPrint(#file, #function, "Day half start:", dayHalfStart)
//
//            if dayHalfStart <= now && now < deoptionalizedTransition {
//                // Daytime
////                debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Daytime")
//                assert(deoptionalizedTransition > dayHalfStart)
//                hours = now.fractionalHours(startDate:  dayHalfStart, endDate:  deoptionalizedTransition, numberOfHoursPerDay:  NUMBER_OF_HOURS)
//                symbol = DAY_SYMBOL
//            } else {
//                // Previous nighttime
////                debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Previous nighttime")
//                var previousDayHalfEnd:  Date
//                previousDayHalfEnd = self.startOfDay(for: jiggeredNow, location: location, timeZone: timeZone ?? TimeZone.autoupdatingCurrent)
//                assert(dayHalfStart > previousDayHalfEnd)
////                debugPrint(#file, #function, "Previous day half end:", previousDayHalfEnd, "Day half start:", dayHalfStart)
//                hours = now.fractionalHours(startDate:  previousDayHalfEnd, endDate:  dayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
//                symbol = NIGHT_SYMBOL
//            }
//        }
//
//        assert(hours >= 0.0)
////        if !(hours >= 0.0) {
////            debugPrint(#file, #function, "Hours:", hours)
////        }
//        assert(hours < 12.0)
////        if !(hours < 12.0) {
////            debugPrint(#file, #function, "Hours:", hours)
////        }
        let (hours, daytime, valid) = self.solarTimeComponents(now: now, location: location, timeZone: timeZone, transition: transition)
        if !valid {
            return invalidTimeString()
        }
        let symbol = daytime ? DAY_SYMBOL : NIGHT_SYMBOL

        var result = ""
        switch majorTimeFormat {
        case .decimalTwelveHour:
            result = self.fractionalHoursTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

//        case .JewishCalendricalCalculation:
//            result = self.JewishCalendricalCalculationTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

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
        //        assert(result != "12.0000 ☼")
        return result
    } // func fractionalHoursTimeString(hours:  Double, symbol:  String) -> String

//    func JewishCalendricalCalculationTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
//        return self.hoursMinutesSecondsTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier, minutesPerHour:  1080.0, secondsPerMinutes:  76.0, minimumHourDigits:  1, minimumMinuteDigits:  4, minimumSecondDigits:  2)
//    } // func JewishCalendricalCalculationTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String

    func sexagesimalTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
        return self.hoursMinutesSecondsTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier, minutesPerHour:  60.0, secondsPerMinute:  60.0, minimumHourDigits:  1, minimumMinuteDigits:  2, minimumSecondDigits:  2)
    } // func sexagesimalTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String

    func hoursMinutesSecondsComponents(hours:  Double, minutesPerHour:  Double, secondsPerMinute:  Double) -> (hour:  Int, minute:  Int, second:  Int, nanosecond:  Int) {
        let integralHours = floor(hours)
        let fractionalHours = hours - integralHours
        let totalMinutes = fractionalHours * minutesPerHour
        let integralMinutes = floor(totalMinutes)
        let fractionalMinutes = totalMinutes - integralMinutes
        let totalSeconds = fractionalMinutes * secondsPerMinute
        let integralSeconds = floor(totalSeconds)
        let nanoseconds = (totalSeconds - integralSeconds) * 1000000000
        return (hour:  Int(integralHours), minute:  Int(integralMinutes), second:  Int(integralSeconds), nanosecond:  Int(nanoseconds))
    }

    func hoursMinutesSecondsTimeString(hours:  Double, symbol:  String, localeIdentifier:  String, minutesPerHour:  Double, secondsPerMinute:  Double, minimumHourDigits:  Int, minimumMinuteDigits:  Int, minimumSecondDigits:  Int) -> String {
//        let integralHours = floor(hours)
//        let fractionalHours = hours - integralHours
//        let totalMinutes = fractionalHours * minutesPerHour
//        let integralMinutes = floor(totalMinutes)
//        let fractionalMinutes = totalMinutes - integralMinutes
//        let totalSeconds = fractionalMinutes * secondsPerMinutes
//        let integralSeconds = floor(totalSeconds)
        let (integralHours, integralMinutes, integralSeconds, _) = self .hoursMinutesSecondsComponents(hours: hours, minutesPerHour: minutesPerHour, secondsPerMinute: secondsPerMinute)

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
    } // func hoursMinutesSecondsTimeString(hours:  Double, symbol:  String, localeIdentifier:  String, minutesPerHour:  Double, secondsPerMinutes:  Double, minimumHourDigits:  Int, minimumMinuteDigits:  Int, minimumSecondDigits:  Int) -> String


    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone: TimeZone?) -> String {
        let (fixedNow, transition) = now.solarCorrected(location: location!, timeZone: timeZone ?? TimeZone.autoupdatingCurrent, transitionEvent: self.dayEnd)
        assert(fixedNow >= now)

        var timeString:  String = ""
        if majorTimeFormat != .none {
            timeString = self.timeString(now: now, localeIdentifier:  localeIdentifier, majorTimeFormat:  majorTimeFormat, timeGeekFormat:  timeGeekFormat, location:  location, timeZone:  timeZone, transition: transition) // TO DO:  EXPAND ON THIS!
        }

        if location == nil {
            return "No location"
        }
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        self.dateFormatter.timeZone = timeZone

        switch majorDateFormat {
        case .localizedLDML:
            self.dateFormatter.dateStyle = .short
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

        case .shortWithWeekday:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "E")

        case .mediumWithWeekday:
            self.dateFormatter.apply(dateStyle: .medium, LDMLExtension: "E")

        case .abbreviatedWeekday:
            self.dateFormatter.apply(dateStyle: .short, template: "eee")

        case .dayOfMonth:
            self.dateFormatter.apply(dateStyle: .short, template: "d")

        case .abbreviatedWeekdayWithDayOfMonth:
            self.dateFormatter.apply(dateStyle: .short, template: "eeed")

        case .shortWithWeekdayWithoutYear:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "E", removing:  DateFormatter.yearCodes)

        case .mediumWithWeekdayWithoutYear:
            self.dateFormatter.apply(dateStyle: .medium, LDMLExtension: "E", removing:  DateFormatter.yearCodes)

        case .fullWithoutYear:
            self.dateFormatter.apply(dateStyle: .full, LDMLExtension: "", removing:  DateFormatter.yearCodes)

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

//    public func dateTimeString(now: Date, localeIdentifier: String, LDMLString: String, location: CLLocation?, timeZone: TimeZone?) -> String {
//        if location == nil {
//            return "No location"
//        }
//
//        if localeIdentifier == "" {
//            self.dateFormatter.locale = Locale.current
//        } else {
//            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
//        }
//        self.dateFormatter.timeZone = timeZone
//
//        let (fixedNow, _) = now.solarCorrected(location: location!, timeZone: timeZone ?? TimeZone.autoupdatingCurrent, transitionEvent: self.dayEnd)
//        assert(fixedNow >= now)
////        debugPrint(#file, #function, "Now:", now, "Fixed now:", fixedNow, "Transition:", transition as Any)
//
//        self.dateFormatter.dateFormat = LDMLString
//        let result = self.dateFormatter.string(from: fixedNow)
//
//        return result
//    } // func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String

//    var LDMLDetails: Array<ASALDMLDetail> = [
//        ASALDMLDetail(name: "HEADER_G", geekCode: "GGGG"),
//        ASALDMLDetail(name: "HEADER_y", geekCode: "y"),
//        ASALDMLDetail(name: "HEADER_M", geekCode: "MMMM"),
//        ASALDMLDetail(name: "HEADER_d", geekCode: "d"),
//        ASALDMLDetail(name: "HEADER_E", geekCode: "eeee"),
//        ASALDMLDetail(name: "HEADER_Q", geekCode: "QQQQ"),
//        ASALDMLDetail(name: "HEADER_Y", geekCode: "Y"),
//        ASALDMLDetail(name: "HEADER_w", geekCode: "w"),
//        ASALDMLDetail(name: "HEADER_W", geekCode: "W"),
//        ASALDMLDetail(name: "HEADER_F", geekCode: "F"),
//        ASALDMLDetail(name: "HEADER_D", geekCode: "D"),
//        //            ASADetail(name: "HEADER_U", geekCode: "UUUU"),
//        //            ASALDMLDetail(name: "HEADER_r", geekCode: "r"),
//        //            ASADetail(name: "HEADER_g", geekCode: "g")
//    ]

    public var supportsLocales: Bool = true

    public var supportsDateFormats: Bool = true

    public var supportsTimeZones: Bool = false

    public func startOfDay(for date: Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
        if location == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }

        let yesterday: Date = date.addingTimeInterval(-24 * 60 * 60)
        let (fixedYesterday, _) = yesterday.solarCorrected(location: location!, timeZone: timeZone, transitionEvent: self.dayEnd)
        let events = fixedYesterday.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [self.dayEnd], timeZone: timeZone )
        let rawDayEnd: Date?? = events[self.dayEnd]
        if rawDayEnd == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }
        if rawDayEnd! == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }
        let dayEnd:  Date = rawDayEnd!! // שקיעה
        return dayEnd
    } // func startOfDay(for date: Date, location:  CLLocation?, timeZone:  TimeZone) -> Date

    public func startOfNextDay(date: Date, location: CLLocation?, timeZone:  TimeZone) -> Date {
        if location == nil {
            return date.sixPM(timeZone: timeZone)
        }

        let (fixedNow, _) = date.solarCorrected(location: location!, timeZone: timeZone, transitionEvent: self.dayEnd)
        let events = fixedNow.solarEvents(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude), events: [self.dayEnd], timeZone: timeZone )
        let rawDayEnd: Date?? = events[self.dayEnd]
        if rawDayEnd == nil {
            return date.sixPM(timeZone: timeZone)
        }
        if rawDayEnd! == nil {
            return date.sixPM(timeZone: timeZone)
        }
        let dayEnd:  Date = rawDayEnd!!
        return dayEnd
    } // func transitionToNextDay(now: Date, location: CLLocation?, timeZone:  TimeZone) -> Date

    public var supportsLocations: Bool = true

    public var supportsTimes: Bool = true

    var supportedMajorDateFormats: Array<ASAMajorDateFormat> = [
        .full,
        .long,
        .medium,
        .mediumWithWeekday,
        .short,
        .shortWithWeekday,
        .abbreviatedWeekday,
        .dayOfMonth,
        .abbreviatedWeekdayWithDayOfMonth,
        .shortWithWeekdayWithoutYear,
        .mediumWithWeekdayWithoutYear,
        .fullWithoutYear,
        .localizedLDML
    ]

    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [
//        .full, .long,
        .medium, .short, .decimalTwelveHour
//                                                                , .JewishCalendricalCalculation
    ]

    public var supportsTimeFormats: Bool = true

    public var canSplitTimeFromDate:  Bool = true

    var defaultMajorTimeFormat:  ASAMajorTimeFormat = .decimalTwelveHour


    // MARK: - Date components

    func isValidDate(dateComponents: ASADateComponents) -> Bool { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let ApplesDateComponents = dateComponents.ApplesDateComponents()
        return ApplesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool

    func date(dateComponents: ASADateComponents) -> Date? { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let ApplesDateComponents = dateComponents.ApplesDateComponents()

        return ApplesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?


    // MARK:  - Extracting Components

    func hoursMinutesSecondsComponents(date: Date, transition:  Date??, locationData:  ASALocationData) -> (hour:  Int, minute:  Int, second:  Int, nanosecond:  Int) {
        let solarTimeComponents = self.solarTimeComponents(now: date, location: locationData.location, timeZone: locationData.timeZone, transition: transition)
        if !solarTimeComponents.valid {
            return (hour:  -1, minute:  -1, second:  -1, nanosecond:  -1)
        }
        let processedFracitonalHours = solarTimeComponents.daytime ? solarTimeComponents.hours + 12.0 : solarTimeComponents.hours
        let HMSComponents = hoursMinutesSecondsComponents(hours: processedFracitonalHours, minutesPerHour: 60.0, secondsPerMinute: 60.0)
        return HMSComponents
    } // func hoursMinutesSecondsComponents(date: Date, transition:  Date, locationData:  ASALocationData) -> (hour:  Int, minute:  Int, second:  Int, nanosecond:  Int)

    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int {
        // Returns the value for one component of a date.

        var calendar = self.ApplesCalendar
        calendar.timeZone = locationData.timeZone ?? TimeZone.current
        let (fixedDate, transition) = date.solarCorrected(location: locationData.location!, timeZone: locationData.timeZone!, transitionEvent: self.dayEnd)

        if [ASACalendarComponent.hour, ASACalendarComponent.minute, ASACalendarComponent.second, ASACalendarComponent.nanosecond].contains(component) {
            let HMSComponents = self.hoursMinutesSecondsComponents(date: date, transition: transition, locationData: locationData)
            switch component {
            case .hour:
                return HMSComponents.hour

            case .minute:
                return HMSComponents.minute

            case .second:
                return HMSComponents.second

            case .nanosecond:
                return HMSComponents.nanosecond

            default:
                return -1
            }
        } // switch component

        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return -1
        }

        return calendar.component(ApplesComponent!, from: fixedDate)
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents {
        // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let (fixedDate, transition) = date.solarCorrected(location: locationData.location!, timeZone: locationData.timeZone!, transitionEvent: self.dayEnd)

        var ApplesComponents = Set<Calendar.Component>()
        for component in components {
            let ApplesCalendarComponent = component.calendarComponent()
            if ApplesCalendarComponent != nil {
                ApplesComponents.insert(ApplesCalendarComponent!)
            }
        } // for component in components

        let ApplesDateComponents = ApplesCalendar.dateComponents(ApplesComponents, from: fixedDate)
        var result = ASADateComponents.new(with: ApplesDateComponents, calendar: self, locationData: locationData)
//                debugPrint(#file, #function, "• Date:", date, "• Fixed date:", fixedDate, "• Result:", result)
        let HMSComponents = self.hoursMinutesSecondsComponents(date: date, transition: transition, locationData: locationData)

        for component in components {
            if [ASACalendarComponent.hour, ASACalendarComponent.minute, ASACalendarComponent.second, ASACalendarComponent.nanosecond].contains(component) {
                switch component {
                case .hour:
                    result.hour = HMSComponents.hour

                case .minute:
                    result.minute = HMSComponents.minute

                case .second:
                    result.second = HMSComponents.second

                case .nanosecond:
                    result.nanosecond = HMSComponents.nanosecond

                default:
                    debugPrint(#file, #function, component)
                } // switch component
            }
        } // for component in components
        return result
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents


    // MARK:  - Getting Calendar Information
    // TODO:  Need to modify these to deal with non-ISO times!

    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.ApplesCalendar.maximumRange(of: ApplesComponent!)
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?

    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.ApplesCalendar.minimumRange(of: ApplesComponent!)
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?

    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        let ApplesSmaller = smaller.calendarComponent()
        let ApplesLarger = larger.calendarComponent()
        if ApplesSmaller == nil || ApplesLarger == nil {
            return nil
        }
        return self.ApplesCalendar.ordinality(of: ApplesSmaller!, in: ApplesLarger!, for: date)
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?

    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        let ApplesSmaller = smaller.calendarComponent()
        let ApplesLarger = larger.calendarComponent()
        if ApplesSmaller == nil || ApplesLarger == nil {
            return nil
        }
        return self.ApplesCalendar.range(of: ApplesSmaller!, in: ApplesLarger!, for: date)
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>?

    //    func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent? {
    //        // Returns which component contains the specified component for specifying a date.  E.g., in many calendars days are contained within months, months are contained within years, and years are contained within eras.
    //        switch component {
    //        case .year:
    //            return .era
    //
    //        case .month:
    //            return .year
    //
    //        case .day:
    //            return .month
    //
    //        default:
    //            return nil
    //        } // switch component
    //    } // func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent?
    

    // MARK: -

    func supports(calendarComponent:  ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era, .year, .yearForWeekOfYear, .quarter, .month, .weekOfYear, .weekOfMonth, .weekday, .weekdayOrdinal, .day:
            return true

        case .calendar, .timeZone:
            return true

        default:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool


    // MARK: -

    public var transitionType:  ASATransitionType {
        get {
            switch self.dayEnd {
            case .sunset:
                return .sunset

            case .dusk72Minutes:
            return .dusk

            default:
                return .midnight
            }
        }
    }
 } // class ASASunsetTransitionCalendar
