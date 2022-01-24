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
    var defaultDateFormat:  ASADateFormat = .short
    #else
    var defaultDateFormat:  ASADateFormat = .full
    #endif

    public var dateFormatter = DateFormatter()

    private var ApplesCalendar:  Calendar

    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        let title = self.calendarCode.equivalentCalendarIdentifier
        ApplesCalendar = Calendar(identifier: title)
        dateFormatter.calendar = ApplesCalendar
    } // init(calendarCode:  ASACalendarCode)

    func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let timeZone = locationData.timeZone
        let (fixedNow, transition) = now.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        assert(fixedNow >= now)

        var timeString:  String = ""
        if timeFormat != .none {
            timeString = self.timeString(now: now, localeIdentifier:  localeIdentifier, timeFormat:  timeFormat, locationData: locationData, transition: transition) // TODO:  EXPAND ON THIS!
        }

        let dateString = self.dateString(fixedNow: fixedNow, localeIdentifier: localeIdentifier, timeZone: timeZone, dateFormat: dateFormat)

        let dateComponents = self.dateComponents(fixedDate: fixedNow, transition: transition, components: [.era, .year, .month, .day, .weekday,
//                                                                                                           .hour, .minute, .second,
                                                                                                           .fractionalHour, .dayHalf], from: now, locationData: locationData)
        return (dateString, timeString, dateComponents)
    } // func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
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

    func solarTimeComponents(now: Date, locationData:  ASALocation, transition:  Date??) -> (hours:  Double, daytime:  Bool, valid:  Bool) {
        let location = locationData.location
        let timeZone = locationData.timeZone

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
        //        debugPrint(#file, #function, "Now:", now, localeIdentifier, timeFormat, timeGeekFormat, location!, timeZone!, "Transition:", transition!!)

        var dayHalfStart:  Date

        var hours:  Double
        var daytime:  Bool
        let NUMBER_OF_HOURS = 12.0

        let deoptionalizedTransition: Date = transition!!
        if deoptionalizedTransition <= now  {
            // Nighttime, transition is at the start of the nighttime
            //            debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Nighttime, transition is at the start of the nighttime")
            //            let nextDate = now.oneDayAfter
            let nextDate = now.noon(timeZone:  timeZone).oneDayAfter
            var nextDayHalfStart:  Date
            let nextEvents = nextDate.solarEvents(location: location, events: [self.dayStart], timeZone: timeZone )
            nextDayHalfStart = nextEvents[self.dayStart]!!
            assert(nextDayHalfStart > deoptionalizedTransition)

            //            debugPrint(#file, #function, "Now:", now, "Nighttime start:", deoptionalizedTransition, "Nighttime end:", nextDayHalfStart)

            hours = now.fractionalHours(startDate:  deoptionalizedTransition, endDate:  nextDayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
            daytime = false
        } else {
            // now < deoptionalizedTransition
            let ourTimeZone = timeZone
            let events = now.noon(timeZone:ourTimeZone).solarEvents(location: location, events: [self.dayStart], timeZone: ourTimeZone)

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
                jiggeredNow = now - Date.SECONDS_PER_DAY
                let events = jiggeredNow.solarEvents(location: location, events: [self.dayStart], timeZone: timeZone )

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
                daytime = true
            } else {
                // Previous nighttime
                //                debugPrint(#file, #function, "Now:", now, "Transition:", transition!!, "Previous nighttime")
                var previousDayHalfEnd:  Date
                previousDayHalfEnd = self.startOfDay(for: jiggeredNow, locationData: locationData)
                assert(dayHalfStart > previousDayHalfEnd)
                //                debugPrint(#file, #function, "Previous day half end:", previousDayHalfEnd, "Day half start:", dayHalfStart)
                hours = now.fractionalHours(startDate:  previousDayHalfEnd, endDate:  dayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
                daytime = false
            }
        }

        assert(!(hours == 12.0 && daytime == true))
        return (hours:  hours, daytime:  daytime, valid:  true)
    } // func solarTimeComponents(now: Date, localeIdentifier: String, locationData: ASALocation, transition:  Date??) -> (hours:  Double, daytime:  Bool, valid:  Bool)

    func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData: ASALocation, transition:  Date??) -> String {
        let NIGHT_SYMBOL    = "☽"
        let DAY_SYMBOL      = "☼"

        let (hours, daytime, valid) = self.solarTimeComponents(now: now, locationData: locationData, transition: transition)
        if !valid {
            return invalidTimeString()
        }
        assert(hours >= 0.0)
        assert(hours < 12.0)
        
        let symbol = daytime ? DAY_SYMBOL : NIGHT_SYMBOL

        var result = ""
        switch timeFormat {
        case .decimalTwelveHour:
            result = self.fractionalHoursTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

//        case .JewishCalendricalCalculation:
//            result = self.JewishCalendricalCalculationTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

        case
//            .short,
            .medium
//            , .long, .full
        :
            result = self.sexagesimalTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)

        default:
            result = self.fractionalHoursTimeString(hours:  hours, symbol:  symbol, localeIdentifier:  localeIdentifier)
        }
        return result
    } // func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData: ASALocation, transition:  Date??) -> String

    func fractionalHoursTimeString(hours:  Double, symbol:  String, localeIdentifier:  String) -> String {
        var result = ""
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 4
        numberFormatter.locale = Locale.desiredLocale(localeIdentifier)
        var revisedHours: Double
        let CUTOFF = 11.9999
        if hours > CUTOFF && hours < 12.0 {
            revisedHours = CUTOFF
        } else {
            revisedHours = hours
        }
        result = "\(numberFormatter.string(from: NSNumber(value:  revisedHours)) ?? "") \(symbol)"
        assert(result != "12.0000 ☼")
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
        let (integralHours, integralMinutes, integralSeconds, _) = self .hoursMinutesSecondsComponents(hours: hours, minutesPerHour: minutesPerHour, secondsPerMinute: secondsPerMinute)

        var result = ""
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = Locale.desiredLocale(localeIdentifier)
        numberFormatter.minimumIntegerDigits = minimumHourDigits
        let hourString = numberFormatter.string(from: NSNumber(value:  integralHours))
        numberFormatter.minimumIntegerDigits = minimumMinuteDigits
        let minuteString = numberFormatter.string(from: NSNumber(value:  integralMinutes))
        numberFormatter.minimumIntegerDigits = minimumSecondDigits
        let secondString = numberFormatter.string(from: NSNumber(value:  integralSeconds))
        result = "\(hourString ?? ""):\(minuteString ?? ""):\(secondString ?? "") \(symbol)"
        return result
    } // func hoursMinutesSecondsTimeString(hours:  Double, symbol:  String, localeIdentifier:  String, minutesPerHour:  Double, secondsPerMinutes:  Double, minimumHourDigits:  Int, minimumMinuteDigits:  Int, minimumSecondDigits:  Int) -> String

    func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat) -> String {
        self.dateFormatter.locale = Locale.desiredLocale(localeIdentifier)

        self.dateFormatter.timeZone = timeZone

        self.dateFormatter.timeStyle = .none

        switch dateFormat {
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
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "eee")

        case .mediumWithWeekday:
            self.dateFormatter.apply(dateStyle: .medium, LDMLExtension: "eee")

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
            
        case .shortYearOnly:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "", removing: DateFormatter.nonYearCodes)
            
        case .shortYearAndMonthOnly:
            self.dateFormatter.apply(dateStyle: .short, LDMLExtension: "", removing: DateFormatter.nonYearNonMonthCodes)

        default:
            self.dateFormatter.dateStyle = .full
        } // switch dateFormat

        let dateString = self.dateFormatter.string(from: fixedNow)
        return dateString
    }

    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        let timeZone = locationData.timeZone
        let (fixedNow, transition) = now.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        assert(fixedNow >= now)

        var timeString:  String = ""
        if timeFormat != .none {
            timeString = self.timeString(now: now, localeIdentifier:  localeIdentifier, timeFormat:  timeFormat, locationData: locationData, transition: transition) // TO DO:  EXPAND ON THIS!
        }

        let dateString = self.dateString(fixedNow: fixedNow, localeIdentifier: localeIdentifier, timeZone: timeZone, dateFormat: dateFormat)

        if dateString == "" {
            return timeString
        } else if timeString == "" {
            return dateString
        } else {
            let SEPARATOR = ", "
            return dateString + SEPARATOR + timeString
        }
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String

    public var supportsLocales: Bool = true

    public var supportsTimeZones: Bool = false

    func startOfDay(for date: Date, locationData:  ASALocation) -> Date {
        let location = locationData.location
        let timeZone = locationData.timeZone
        let yesterday: Date = date.oneDayBefore
        let (fixedYesterday, _) = yesterday.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        let events = fixedYesterday.solarEvents(location: location, events: [self.dayEnd], timeZone: timeZone )
        let rawDayEnd: Date?? = events[self.dayEnd]
        if rawDayEnd == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }
        if rawDayEnd! == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }
        let dayEnd:  Date = rawDayEnd!! // שקיעה
        return dayEnd
    } // func startOfDay(for date: Date, locationData:  ASALocation) -> Date

    func startOfNextDay(date: Date, locationData:  ASALocation) -> Date {
        let location = locationData.location
        let timeZone = locationData.timeZone

        let (fixedNow, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        let events = fixedNow.solarEvents(location: location, events: [self.dayEnd], timeZone: timeZone )
        let rawDayEnd: Date?? = events[self.dayEnd]
        if rawDayEnd == nil {
            return date.sixPM(timeZone: timeZone)
        }
        if rawDayEnd! == nil {
            return date.sixPM(timeZone: timeZone)
        }
        let dayEnd:  Date = rawDayEnd!!
        return dayEnd
    } // func transitionToNextDay(now: Date, locationData:  ASALocation) -> Date

    public var supportsLocations: Bool = true

    public var supportsTimes: Bool = true

    var supportedDateFormats: Array<ASADateFormat> = [
        .full
    ]

    var supportedWatchDateFormats: Array<ASADateFormat> = [
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
        .fullWithoutYear
    ]

    var supportedTimeFormats: Array<ASATimeFormat> = [
        .medium,
        .decimalTwelveHour
    ]

    public var canSplitTimeFromDate:  Bool = true

    var defaultTimeFormat:  ASATimeFormat = .decimalTwelveHour


    // MARK: - Date components

    func isValidDate(dateComponents: ASADateComponents) -> Bool { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let ApplesDateComponents = dateComponents.ApplesDateComponents()
        return ApplesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool

    func date(dateComponents: ASADateComponents) -> Date? { // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        var ApplesDateComponents = dateComponents.ApplesDateComponents()
        // The next part is to ensure we get the right day and don't screw up Sunrise/Sunset calculations
        ApplesDateComponents.hour       = 12
        ApplesDateComponents.minute     =  0
        ApplesDateComponents.second     =  0
        ApplesDateComponents.nanosecond =  0

        return ApplesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?


    // MARK:  - Extracting Components

    func timeComponents(date: Date, transition:  Date??, locationData:  ASALocation) -> (
//        hour:  Int, minute:  Int, second:  Int, nanosecond:  Int,
        fractionalHour: Double, dayHalf: ASADayHalf) {
        let solarTimeComponents = self.solarTimeComponents(now: date, locationData: locationData, transition: transition)
        if !solarTimeComponents.valid {
            return (
//                hour:  -1, minute:  -1, second:  -1, nanosecond:  -1,
                fractionalHour: -1.0, dayHalf: ASADayHalf.night)
        }
//        let processedFracitonalHours = solarTimeComponents.daytime ? solarTimeComponents.hours + 12.0 : solarTimeComponents.hours
//        let (hours, minutes, seconds, nanoseconds) = hoursMinutesSecondsComponents(hours: processedFracitonalHours, minutesPerHour: 60.0, secondsPerMinute: 60.0)
        return (
//            hours, minutes, seconds, nanoseconds,
            solarTimeComponents.hours, solarTimeComponents.daytime ? .day : .night)
    } // func hoursMinutesSecondsComponents(date: Date, transition:  Date, locationData:  ASALocation) -> (hour:  Int, minute:  Int, second:  Int, nanosecond:  Int)

    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int {
        // Returns the value for one component of a date.

        var calendar = self.ApplesCalendar
        calendar.timeZone = locationData.timeZone
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)

//        if [ASACalendarComponent.hour, ASACalendarComponent.minute, ASACalendarComponent.second, ASACalendarComponent.nanosecond].contains(component) {
//            let HMSComponents = self.timeComponents(date: date, transition: transition, locationData: locationData)
//            switch component {
//            case .hour:
//                return HMSComponents.hour
//
//            case .minute:
//                return HMSComponents.minute
//
//            case .second:
//                return HMSComponents.second
//
//            case .nanosecond:
//                return HMSComponents.nanosecond

//            default:
//                return -1
//            }
//        } // switch component

        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return -1
        }

        return calendar.component(ApplesComponent!, from: fixedDate)
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int

    fileprivate func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents {
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
        let timeComponents = self.timeComponents(date: date, transition: transition, locationData: locationData)
        
        if components.contains(.fractionalHour) {
            result.solarHours = timeComponents.fractionalHour
        }
        if components.contains(.dayHalf) {
            result.dayHalf = timeComponents.dayHalf
        }
        return result
    } // func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents {
        // TODO:  FIX THIS TO HANDLE DIFFERENT TIME SYSTEMS
        let (fixedDate, transition) = date.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)

        let result = dateComponents(fixedDate: fixedDate, transition: transition, components: components, from: date, locationData: locationData)
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
    

    // MARK: -

    func supports(calendarComponent:  ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era, .year, .yearForWeekOfYear, .quarter, .month, .weekOfYear, .weekOfMonth, .weekday, .weekdayOrdinal, .day:
            return true

        case .calendar, .timeZone:
            return true
            
        case .fractionalHour, .dayHalf:
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

    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        self.ApplesCalendar.locale = Locale.desiredLocale(localeIdentifier)
        return self.ApplesCalendar.veryShortStandaloneWeekdaySymbols
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>

    var usesISOTime:  Bool = false

    var daysPerWeek:  Int? = 7
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        self.ApplesCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat {
        if self.calendarCode.isHebrewCalendar && locale.languageCode == "he" {
            return .shortHebrew
        }
        
        return .system
    } // func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat
     
     
     // MARK:  - Time zone-dependent modified Julian day
     
     func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int {
         let timeZone = locationData.timeZone
         let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
         assert(fixedDate >= date)

         return fixedDate.localModifiedJulianDay(timeZone: timeZone)
     } // func localModifiedJulianDay(date: Date, timeZone: TimeZone) -> Int
 } // class ASASunsetTransitionCalendar
