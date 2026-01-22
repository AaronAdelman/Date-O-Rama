//
//  ASASolarTimeCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-22.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

// MARK: -

public class ASASolarTimeCalendar: ASACalendar, ASALDMLCalendar {
    var calendarCode: ASACalendarCode
    
#if os(watchOS)
    var defaultDateFormat: ASADateFormat = .short
#else
    var defaultDateFormat: ASADateFormat = .full
#endif
    
    init(calendarCode: ASACalendarCode) {
        self.calendarCode = calendarCode
    } // init(calendarCode: ASACalendarCode)
    
    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let timeZone = locationData.timeZone
        let (fixedNow, transition) = now.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)
        
        switch self.dateTransition {
        case .dawn72Minutes, .sunrise:
            if !(fixedNow <= now) {
                debugPrint(#file, #function, "!(fixedNow <= now)", calendarCode, fixedNow, now)
            }
        case .sunset, .dusk72Minutes:
            if !(fixedNow >= now) {
                debugPrint(#file, #function, "!(fixedNow >= now)", calendarCode, fixedNow, now)
            }
        default:
            debugPrint(#file, #function, "Unknown date transition!")
        }
        
//        debugPrint("📅", #file, #function, "fixedNow:", fixedNow.formattedFor(timeZone: timeZone) as Any, "transition:", transition.formattedFor(timeZone: timeZone) as Any)
        
        let dateComponents = self.dateComponents(fixedDate: fixedNow, transition: transition, components: [.era, .year, .month, .day, .weekday, .fractionalHour, .dayHalf], from: now, locationData: locationData)

        var timeString: String = ""
        if timeFormat != .none {
            let solarHours: Double = dateComponents.solarHours ?? -1
            timeString = self.timeString(hours: solarHours, daytime: dateComponents.dayHalf == .day, valid: solarHours >= 0, localeIdentifier: localeIdentifier, timeFormat: timeFormat)
        }
        
        let dateString = self.dateString(fixedNow: fixedNow, localeIdentifier: localeIdentifier, timeZone: timeZone, dateFormat: dateFormat, dateComponents: dateComponents)
        
        return (dateString, timeString, dateComponents)
    } // func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    /// For a Jewish or Islamic calendar, night precedes day, so this is Sunrise or dawn.  For a South Asian calendar, day precedes night, so this is Sunset.
    var midPointTransition: ASASolarEvent {
        return .sunrise
    } // var midPointTransition
    
    /// For a Jewish or Islamic calendar, this is Sunset or dusk.  For a South Asian calendar, this is Sunrise.
    var dateTransition: ASASolarEvent {
        return .sunset
    } // var dateTransition: ASASolarEvent
    
    // TODO:  This needs to be updated to also handle Sunrise transition calendars.
    func solarTimeComponents(now: Date, locationData: ASALocation, transition: Date?) -> (hours: Double, daytime: Bool, valid: Bool) {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
        var existsSolarTime = true
        if transition == nil {
            existsSolarTime = false
        }

        if !existsSolarTime {
            return (hours: -1.0, daytime: false, valid: false)
        }
//        debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, location, timeZone, "Transition:", transition?.formattedFor(timeZone: timeZone) as Any)
        
        var dayHalfStart: Date
        
        var hours: Double
        var daytime: Bool
        let NUMBER_OF_HOURS = 12.0
        
        let deoptionalizedTransition: Date = transition!
        if deoptionalizedTransition <= now  {
//            debugPrint(#file, #function, "deoptionalizedTransition <= now")
            // Nighttime, transition is at the start of the nighttime
//            debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, "Transition:", transition.formattedFor(timeZone: timeZone) as Any, "Nighttime, transition is at the start of the nighttime")
            let nextDate = now.noon(timeZone: timeZone).oneDayAfter
            var nextDayHalfStart: Date
            let nextEvents = nextDate.solarEvents(location: location, events: [self.midPointTransition], timeZone: timeZone )
            nextDayHalfStart = nextEvents[self.midPointTransition]!!
            assert(nextDayHalfStart > deoptionalizedTransition)
            
//            debugPrint(#file, #function, "Now:", now, "Nighttime start:", deoptionalizedTransition.formattedFor(timeZone: timeZone) as Any, "Nighttime end:", nextDayHalfStart.formattedFor(timeZone: timeZone) as Any)
            
            hours = now.fractionalHours(startDate: deoptionalizedTransition, endDate: nextDayHalfStart, numberOfHoursPerDay: NUMBER_OF_HOURS)
            daytime = false
        } else {
//            debugPrint(#file, #function, "deoptionalizedTransition > now")
            let dateToCalculateSolarEventsFor = now
            let events = dateToCalculateSolarEventsFor.solarEvents(location: location, events: [self.midPointTransition], timeZone: timeZone)
//            debugPrint(#file, #function, events)

            let rawDayHalfStart: Date? = events[self.midPointTransition] ?? nil
            
            if rawDayHalfStart == nil {
                return (hours: -1.0, daytime: false, valid: false)
            }
            
            dayHalfStart = rawDayHalfStart!
            
            var jiggeredNow = now
            if dayHalfStart > deoptionalizedTransition {
//                debugPrint(#file, #function, "Need to jigger")
                // Uh-oh.  It found the day half start for the wrong day!
                jiggeredNow = now - Date.SECONDS_PER_DAY
                let events = jiggeredNow.solarEvents(location: location, events: [self.midPointTransition], timeZone: timeZone )
                
                let rawDayHalfStart: Date? = events[self.midPointTransition] ?? nil
                
                if rawDayHalfStart == nil {
                    return (hours: -1.0, daytime: false, valid: false)
                }
                
                dayHalfStart = rawDayHalfStart!
            }
            
//            debugPrint(#file, #function, "Day half start:", dayHalfStart.formattedFor(timeZone: timeZone) as Any)
            
            if dayHalfStart <= now && now < deoptionalizedTransition {
                // Daytime
//                debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, "Transition:", transition.formattedFor(timeZone: timeZone) as Any, "Daytime")
                assert(deoptionalizedTransition > dayHalfStart)
                hours = now.fractionalHours(startDate: dayHalfStart, endDate: deoptionalizedTransition, numberOfHoursPerDay: NUMBER_OF_HOURS)
                daytime = true
            } else {
                // Previous nighttime
//                debugPrint(#file, #function, "Now:", now.formattedFor(timeZone: timeZone) as Any, "Transition:", transition.formattedFor(timeZone: timeZone) as Any, "Previous nighttime")
                var previousDayHalfEnd: Date
                previousDayHalfEnd = self.startOfDay(for: jiggeredNow, locationData: locationData)
                assert(dayHalfStart > previousDayHalfEnd)
//                debugPrint(#file, #function, "Previous day half end:", previousDayHalfEnd.formattedFor(timeZone: timeZone) as Any, "Day half start:", dayHalfStart.formattedFor(timeZone: timeZone) as Any)
                hours = now.fractionalHours(startDate: previousDayHalfEnd, endDate: dayHalfStart, numberOfHoursPerDay: NUMBER_OF_HOURS)
                daytime = false
            }
        }
        
        assert(!(hours == 12.0 && daytime == true))
        return (hours: hours, daytime: daytime, valid: true)
    } // func solarTimeComponents(now: Date, locationData: ASALocation, transition: Date?) -> (hours: Double, daytime: Bool, valid: Bool)
    
    func timeString(hours: Double, daytime: Bool, valid: Bool, localeIdentifier: String, timeFormat: ASATimeFormat) -> String {
        let NIGHT_SYMBOL    = "☽"
        let DAY_SYMBOL      = "☼"
        
//        debugPrint("⌛️", #file, #function, "hours:", hours, "daytime:", daytime as Any, "valid:", valid)
        if !valid {
            return NSLocalizedString("NO_SOLAR_TIME", comment: "")
        }
        assert(hours >= 0.0)
        assert(hours < 12.0)
        
        let symbol = daytime ? DAY_SYMBOL : NIGHT_SYMBOL
        
        var result = ""
        switch timeFormat {
        case .decimalTwelveHour:
            result = self.fractionalHoursTimeString(hours: hours, symbol: symbol, localeIdentifier: localeIdentifier)
                    
        case .medium:
            result = self.sexagesimalTimeString(hours: hours, symbol: symbol, localeIdentifier: localeIdentifier)
            
        default:
            result = self.fractionalHoursTimeString(hours: hours, symbol: symbol, localeIdentifier: localeIdentifier)
        }
        return result
    } // func timeString(now: Date, localeIdentifier: String, timeFormat: ASATimeFormat, locationData: ASALocation, transition: Date?) -> String
    
    func fractionalHoursTimeString(hours: Double, symbol: String, localeIdentifier: String) -> String {
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
        result = "\(numberFormatter.string(from: NSNumber(value: revisedHours)) ?? "") \(symbol)"
        assert(result != "12.0000 ☼")
        return result
    } // func fractionalHoursTimeString(hours: Double, symbol: String) -> String
        
    func sexagesimalTimeString(hours: Double, symbol: String, localeIdentifier: String) -> String {
        return self.hoursMinutesSecondsTimeString(hours: hours, symbol: symbol, localeIdentifier: localeIdentifier, minutesPerHour: 60.0, secondsPerMinute: 60.0, minimumHourDigits: 1, minimumMinuteDigits: 2, minimumSecondDigits: 2)
    } // func sexagesimalTimeString(hours: Double, symbol: String, localeIdentifier: String) -> String
    
    func hoursMinutesSecondsComponents(hours: Double, minutesPerHour: Double, secondsPerMinute: Double) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) {
        let integralHours = floor(hours)
        let fractionalHours = hours - integralHours
        let totalMinutes = fractionalHours * minutesPerHour
        let integralMinutes = floor(totalMinutes)
        let fractionalMinutes = totalMinutes - integralMinutes
        let totalSeconds = fractionalMinutes * secondsPerMinute
        let integralSeconds = floor(totalSeconds)
        let nanoseconds = (totalSeconds - integralSeconds) * 1000000000
        return (hour: Int(integralHours), minute: Int(integralMinutes), second: Int(integralSeconds), nanosecond: Int(nanoseconds))
    } // func hoursMinutesSecondsComponents(hours: Double, minutesPerHour: Double, secondsPerMinute: Double) -> (hour: Int, minute: Int, second: Int, nanosecond: Int)
    
    func hoursMinutesSecondsTimeString(hours: Double, symbol: String, localeIdentifier: String, minutesPerHour: Double, secondsPerMinute: Double, minimumHourDigits: Int, minimumMinuteDigits: Int, minimumSecondDigits: Int) -> String {
        let (integralHours, integralMinutes, integralSeconds, _) = self .hoursMinutesSecondsComponents(hours: hours, minutesPerHour: minutesPerHour, secondsPerMinute: secondsPerMinute)
        
        var result = ""
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = Locale.desiredLocale(localeIdentifier)
        numberFormatter.minimumIntegerDigits = minimumHourDigits
        let hourString = numberFormatter.string(from: NSNumber(value: integralHours))
        numberFormatter.minimumIntegerDigits = minimumMinuteDigits
        let minuteString = numberFormatter.string(from: NSNumber(value: integralMinutes))
        numberFormatter.minimumIntegerDigits = minimumSecondDigits
        let secondString = numberFormatter.string(from: NSNumber(value: integralSeconds))
        result = "\(hourString ?? ""):\(minuteString ?? ""):\(secondString ?? "") \(symbol)"
        return result
    } // func hoursMinutesSecondsTimeString(hours: Double, symbol: String, localeIdentifier: String, minutesPerHour: Double, secondsPerMinutes: Double, minimumHourDigits: Int, minimumMinuteDigits: Int, minimumSecondDigits: Int) -> String
    
    // TODO: Point of expansion
    func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat, dateComponents: ASADateComponents) -> String {
        return ""
    } // func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat, dateComponents: ASADateComponents) -> String
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        let (dateString, timeString, _) = dateStringTimeStringDateComponents(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        if dateString == "" {
            return timeString
        } else if timeString == "" {
            return dateString
        } else {
            let SEPARATOR = ", "
            return dateString + SEPARATOR + timeString
        }
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String
    
    public var supportsLocales: Bool   = true
    
    public var supportsTimeZones: Bool = false
    
    // TODO:  Needs to be updated to support Sunrise transition calendars
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        let location = locationData.location
        let timeZone = locationData.timeZone
        let yesterday: Date = date.oneDayBefore
        let (fixedYesterday, _) = yesterday.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)
        let events = fixedYesterday.solarEvents(location: location, events: [self.dateTransition], timeZone: timeZone )
        let rawDayTransition: Date? = events[self.dateTransition] ?? nil
        if rawDayTransition == nil {
            return date.sixPMYesterday(timeZone: timeZone)
        }

       return rawDayTransition!
    } // func startOfDay(for date: Date, locationData: ASALocation) -> Date
    
    // TODO:  Needs to be updated to support Sunrise transition calendars
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
        let (fixedNow, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)
        let events = fixedNow.solarEvents(location: location, events: [self.dateTransition], timeZone: timeZone )
        let rawDayTransition: Date? = events[self.dateTransition] ?? nil
        if rawDayTransition == nil {
            return date.sixPM(timeZone: timeZone)
        }

        return rawDayTransition!
    } // func transitionToNextDay(now: Date, locationData: ASALocation) -> Date
    
    public var supportsLocations: Bool = true
    
    public var supportsTimes: Bool     = true
    
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
    
    public var canSplitTimeFromDate: Bool = true
    
    var defaultTimeFormat: ASATimeFormat = .decimalTwelveHour
    
    
    // MARK: - Date components
    
    // TODO: Point of expansion
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        return false
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    // TODO: Point of expansion
    func date(dateComponents: ASADateComponents) -> Date? {
        return nil
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    
    // MARK: - Extracting Components
    
    func timeComponents(date: Date, transition: Date?, locationData: ASALocation) -> (fractionalHour: Double, dayHalf: ASADayHalf) {
        let solarTimeComponents = self.solarTimeComponents(now: date, locationData: locationData, transition: transition)
        if !solarTimeComponents.valid {
            return (fractionalHour: -1.0, dayHalf: ASADayHalf.night)
        }
        return (solarTimeComponents.hours, solarTimeComponents.daytime ? .day : .night)
    } // func timeComponents(date: Date, transition: Date?, locationData: ASALocation) -> (fractionalHour: Double, dayHalf: ASADayHalf)
    
    // TODO: Point of expansion
    func dateComponents(fixedDate: Date, transition: Date?, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        return ASADateComponents(calendar: self, locationData: locationData)
    } // func dateComponents(fixedDate: Date, transition: Date?, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        let (fixedDate, transition) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)
        
        let result = dateComponents(fixedDate: fixedDate, transition: transition, components: components, from: date, locationData: locationData)
        return result
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents
    
    
    // MARK: - Getting calendar information
    
    // TODO: Point of expansion
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
       return nil
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    // TODO: Point of expansion
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        return nil
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    // TODO: Point of expansion
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        return nil
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int?
    
    // TODO: Point of expansion
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        return nil
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>?
    
    
    // MARK: -
    
    func supports(calendarComponent: ASACalendarComponent) -> Bool {
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
    } // func supports(calendarComponent: ASACalendarComponent) -> Bool
    
    
    // MARK: -
    
    public var transitionType: ASATransitionType {
        switch self.dateTransition {
        case .sunset:
            return .sunset
            
        case .dusk72Minutes:
            return .dusk
            
        case .sunrise:
            return .sunrise
            
        default:
            return .midnight
        }
    }
    
    
    // MARK: - ASACalendarWithWeeks
    
    // TODO: Point of expansion
    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    var usesISOTime: Bool = false
    
    var daysPerWeek: Int = 7
    
    // TODO: Point of expansion
    func weekendDays(for regionCode: String?) -> Array<Int> {
        return []
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK: - ASACalendarWithMonths
    
    // TODO: Point of expansion
    func monthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func monthSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithQuarters
    
    // TODO: Point of expansion
    func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func quarterSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithEras
    
    // TODO: Point of expansion
    func eraSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func eraSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return []
    } // func longEraSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - Time zone-dependent modified Julian day
    
    func localModifiedJulianDay(date: Date, locationData: ASALocation) -> Int {
        let timeZone = locationData.timeZone
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)
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
} // class ASASolarTimeCalendar
