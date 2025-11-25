//
//  ASASunsetTransitionCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-22.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
//import UIKit
import SwiftUI

// MARK: -

public class ASASunsetTransitionCalendar:  ASACalendar, ASACalendarWithWeeks, ASACalendarWithMonths, ASACalendarWithQuarters, ASACalendarWithEras {
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
        ApplesCalendar = Calendar(identifier: title!)
        dateFormatter.calendar = ApplesCalendar
    } // init(calendarCode:  ASACalendarCode)
    
    func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let timeZone = locationData.timeZone
        let (fixedNow, transition) = now.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        assert(fixedNow >= now)
//        debugPrint("📅", #file, #function, "fixedNow:", fixedNow.formattedFor(timeZone: timeZone) as Any, "transition:", transition.formattedFor(timeZone: timeZone) as Any)
        
        let dateComponents = self.dateComponents(fixedDate: fixedNow, transition: transition, components: [.era, .year, .month, .day, .weekday, .fractionalHour, .dayHalf], from: now, locationData: locationData)

        var timeString:  String = ""
        if timeFormat != .none {
            let solarHours: Double = dateComponents.solarHours ?? -1
            timeString = self.timeString(hours: solarHours, daytime: dateComponents.dayHalf == .day, valid: solarHours >= 0, localeIdentifier: localeIdentifier, timeFormat: timeFormat)
        }
        
        let dateString = self.dateString(fixedNow: fixedNow, localeIdentifier: localeIdentifier, timeZone: timeZone, dateFormat: dateFormat)
        
        return (dateString, timeString, dateComponents)
    } // func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    var dayStart:  ASASolarEvent {
        switch self.calendarCode {
        case .hebrewMA:
            return .dawn72Minutes
            
        default:
            return .sunrise
        } // switch self.calendarCode
    } // var dayStart
    
    var dayEnd:  ASASolarEvent {
        switch self.calendarCode {
        case .hebrewMA:
            return .dusk72Minutes
            
        default:
            return .sunset
        } // switch self.calendarCode
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
//        debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, location, timeZone, "Transition:", transition?.formattedFor(timeZone: timeZone) as Any)
        
        var dayHalfStart:  Date
        
        var hours:  Double
        var daytime:  Bool
        let NUMBER_OF_HOURS = 12.0
        
        let deoptionalizedTransition: Date = transition!!
        if deoptionalizedTransition <= now  {
//            debugPrint(#file, #function, "deoptionalizedTransition <= now")
            // Nighttime, transition is at the start of the nighttime
//            debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, "Transition:", transition.formattedFor(timeZone: timeZone) as Any, "Nighttime, transition is at the start of the nighttime")
            //            let nextDate = now.oneDayAfter
            let nextDate = now.noon(timeZone:  timeZone).oneDayAfter
            var nextDayHalfStart:  Date
            let nextEvents = nextDate.solarEvents(location: location, events: [self.dayStart], timeZone: timeZone )
            nextDayHalfStart = nextEvents[self.dayStart]!!
            assert(nextDayHalfStart > deoptionalizedTransition)
            
//            debugPrint(#file, #function, "Now:", now, "Nighttime start:", deoptionalizedTransition.formattedFor(timeZone: timeZone) as Any, "Nighttime end:", nextDayHalfStart.formattedFor(timeZone: timeZone) as Any)
            
            hours = now.fractionalHours(startDate:  deoptionalizedTransition, endDate:  nextDayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
            daytime = false
        } else {
//            debugPrint(#file, #function, "deoptionalizedTransition > now")
            // now < deoptionalizedTransition
//            let events = now.noon(timeZone: timeZone).solarEvents(location: location, events: [self.dayStart], timeZone: timeZone)
//            let dateToCalculateSolarEventsFor = now.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: now)))
            let dateToCalculateSolarEventsFor = now
          let events = dateToCalculateSolarEventsFor.solarEvents(location: location, events: [self.dayStart], timeZone: timeZone)
//            debugPrint(#file, #function, events)

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
//                debugPrint(#file, #function, "Need to jigger")
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
            
//            debugPrint(#file, #function, "Day half start:", dayHalfStart.formattedFor(timeZone: timeZone) as Any)
            
            if dayHalfStart <= now && now < deoptionalizedTransition {
                // Daytime
//                debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, "Transition:", transition.formattedFor(timeZone: timeZone) as Any, "Daytime")
                assert(deoptionalizedTransition > dayHalfStart)
                hours = now.fractionalHours(startDate:  dayHalfStart, endDate:  deoptionalizedTransition, numberOfHoursPerDay:  NUMBER_OF_HOURS)
                daytime = true
            } else {
                // Previous nighttime
//                debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, "Transition:", transition.formattedFor(timeZone: timeZone) as Any, "Previous nighttime")
                var previousDayHalfEnd:  Date
                previousDayHalfEnd = self.startOfDay(for: jiggeredNow, locationData: locationData)
                assert(dayHalfStart > previousDayHalfEnd)
//                debugPrint(#file, #function, "Previous day half end:", previousDayHalfEnd.formattedFor(timeZone: timeZone) as Any, "Day half start:", dayHalfStart.formattedFor(timeZone: timeZone) as Any)
                hours = now.fractionalHours(startDate:  previousDayHalfEnd, endDate:  dayHalfStart, numberOfHoursPerDay:  NUMBER_OF_HOURS)
                daytime = false
            }
        }
        
        assert(!(hours == 12.0 && daytime == true))
        return (hours:  hours, daytime:  daytime, valid:  true)
    } // func solarTimeComponents(now: Date, localeIdentifier: String, locationData: ASALocation, transition:  Date??) -> (hours:  Double, daytime:  Bool, valid:  Bool)
    
    func timeString(
        hours:  Double, daytime:  Bool, valid:  Bool,
//        now: Date,
        localeIdentifier: String, timeFormat: ASATimeFormat
//        , locationData: ASALocation, transition:  Date??
    ) -> String {
        let NIGHT_SYMBOL    = "☽"
        let DAY_SYMBOL      = "☼"
        
//        let (hours, daytime, valid) = self.solarTimeComponents(now: now, locationData: locationData, transition: transition)
//        debugPrint("⌛️", #file, #function, "hours:", hours, "daytime:", daytime as Any, "valid:", valid)
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
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: .none, timeZone: timeZone)
        
        self.dateFormatter.apply(dateFormat: dateFormat)
        
        let dateString = self.dateFormatter.string(from: fixedNow)
        return dateString
    }
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        let timeZone = locationData.timeZone
        let (fixedNow, transition) = now.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        assert(fixedNow >= now)
        
        var timeString:  String = ""
        if timeFormat != .none {
//            timeString = self.timeString(now: now, localeIdentifier:  localeIdentifier, timeFormat:  timeFormat, locationData: locationData, transition: transition) // TO DO:  EXPAND ON THIS!
            let (hours, daytime, valid) = self.solarTimeComponents(now: now, locationData: locationData, transition: transition)
            timeString = self.timeString(hours: hours, daytime: daytime, valid: valid, localeIdentifier: localeIdentifier, timeFormat: timeFormat)
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
        .fullWithoutYear,
        .longWithoutYear,
        .mediumWithoutYear,
        .shortWithoutYear
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
    
    func timeComponents(date: Date, transition:  Date??, locationData:  ASALocation) -> (fractionalHour: Double, dayHalf: ASADayHalf) {
        let solarTimeComponents = self.solarTimeComponents(now: date, locationData: locationData, transition: transition)
        if !solarTimeComponents.valid {
            return (fractionalHour: -1.0, dayHalf: ASADayHalf.night)
        }
        return (solarTimeComponents.hours, solarTimeComponents.daytime ? .day : .night)
    } // func hoursMinutesSecondsComponents(date: Date, transition:  Date, locationData:  ASALocation) -> (hour:  Int, minute:  Int, second:  Int, nanosecond:  Int)
    
    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int {
        // Returns the value for one component of a date.
        
        var calendar = self.ApplesCalendar
        calendar.timeZone = locationData.timeZone
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        
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
//                        debugPrint(#file, #function, "• Date:", date, "• Fixed date:", fixedDate, "• Result:", result)
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
        
        var result = self.ApplesCalendar.range(of: ApplesSmaller!, in: ApplesLarger!, for: date)
        if result?.lowerBound == result?.upperBound {
            let upperBound = result?.upperBound ?? 1
            result = Range(uncheckedBounds: (1, upperBound))
        }
        return result
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
        switch self.dayEnd {
        case .sunset:
            return .sunset
            
        case .dusk72Minutes:
            return .dusk
            
        default:
            return .midnight
        }
    }
    
    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.weekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return self.ApplesCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    var usesISOTime:  Bool = false
    
    var daysPerWeek: Int = 7
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        self.ApplesCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK:  - ASACalendarWithMonths
    
    func monthSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.monthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK:  - ASACalendarWithQuarters
    
    func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.quarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK:  - ASACalendarWithEras
    
    func eraSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.eraSymbols(localeIdentifier: localeIdentifier)
    }
    
    func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return self.ApplesCalendar.longEraSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK: -
    
//    func miniCalendarNumberFormat(locale: Locale) -> ASANumberFormat {
//        if self.calendarCode.isHebrewCalendar && locale.isHebrewLocale {
//            return .shortHebrew
//        }
//        
//        return .system
//    } // func miniCalendarNumberFormat(locale: Locale) -> ASANumberFormat
    
    
    // MARK:  - Time zone-dependent modified Julian day
    
    func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int {
        let timeZone = locationData.timeZone
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dayEnd)
        assert(fixedDate >= date)
        
        return fixedDate.localModifiedJulianDay(timeZone: timeZone)
    } // func localModifiedJulianDay(date: Date, timeZone: TimeZone) -> Int
    
    
    // MARK: - Cycles
    
    func cycleNumberFormat(locale: Locale) -> ASANumberFormat {
        if self.calendarCode.isHebrewCalendar && locale.language.languageCode?.identifier == "he" {
            return .hebrew
        }
        
        return .system
    } // func cycleNumberFormat(locale: Locale) -> ASANumberFormat
} // class ASASunsetTransitionCalendar
