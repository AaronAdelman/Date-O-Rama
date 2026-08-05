//
//  ASASouthAsianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2026.
//  Copyright © 2026 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

// Calendar object for Solar-time, Sunrise-transition calendars
class ASASouthAsianCalendar: ASASolarTimeCalendar {
// MARK:  - Stuff identical to the stuff in ASAJudeoIslamicCalendar
    //TODO:  - Consider further inheritance or other method of code reuse.
    
    private var dateFormatter = DateFormatter()
    
    private var applesCalendar: Calendar
    
    override init(calendarCode: ASACalendarCode) {
        let identifier = calendarCode.equivalentCalendarIdentifier
        if let identifier {
            self.applesCalendar = Calendar(identifier: identifier)
        } else {
            // Fallback to current calendar if no equivalent identifier is available
            self.applesCalendar = Calendar.current
        }

        super.init(calendarCode: calendarCode)

        dateFormatter.calendar = applesCalendar
    } // init(calendarCode: ASACalendarCode)
    
    override func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat, dateComponents: ASADateComponents) -> String {
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: .none, timeZone: timeZone)
        
        self.dateFormatter.apply(dateFormat: dateFormat)
        
        let dateString = self.dateFormatter.string(from: fixedNow)
//        if dateFormat == .full {
//            debugPrint(#file, #function, dateComponents, dateString)
//        }
        
        return dateString
    } // func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat, dateComponents: ASADateComponents) -> String

    override func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let applesDateComponents = dateComponents.applesDateComponents()
        return applesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool

    override func date(dateComponents: ASADateComponents) -> Date? {
        var applesDateComponents = dateComponents.applesDateComponents()
        // The next part is to ensure we get the right day and don’t screw up Sunrise/Sunset calculations
        applesDateComponents.hour       = 12
        applesDateComponents.minute     =  0
        applesDateComponents.second     =  0
        applesDateComponents.nanosecond =  0
        
        return applesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?

    override func dateComponents(fixedDate: Date, transition: Date?, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        var applesComponents = Set<Calendar.Component>()
        for component in components {
            let applesCalendarComponent = component.calendarComponent()
            if applesCalendarComponent != nil {
                applesComponents.insert(applesCalendarComponent!)
            }
        } // for component in components
        
        let applesDateComponents = applesCalendar.dateComponents(applesComponents, from: fixedDate)
        var result = ASADateComponents.new(with: applesDateComponents, calendar: self, locationData: locationData)
        //                        debugPrint(#file, #function, "• Date:", date, "• Fixed date:", fixedDate, "• Result:", result)
        let timeComponents = self.timeComponents(date: date, transition: transition, locationData: locationData)
        
        if components.contains(.fractionalHour) {
            result.solarHours = timeComponents.fractionalHour
        }
        if components.contains(.dayHalf) {
            result.dayHalf = timeComponents.dayHalf
        }
        return result
    } // func dateComponents(fixedDate: Date, transition: Date?, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents
    
    // MARK: - Getting calendar information:  Stuff identical to the stuff in ASAJudeoIslamicCalendar

    override func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        let applesComponent = component.calendarComponent()
        if applesComponent == nil {
            return nil
        }
        return self.applesCalendar.maximumRange(of: applesComponent!)
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    override func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        let applesComponent = component.calendarComponent()
        if applesComponent == nil {
            return nil
        }
        return self.applesCalendar.minimumRange(of: applesComponent!)
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    override func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int? {
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)

        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        let applesSmaller = smaller.calendarComponent()
        let applesLarger  = larger.calendarComponent()
        if applesSmaller == nil || applesLarger == nil {
            return nil
        }
        return self.applesCalendar.ordinality(of: applesSmaller!, in: applesLarger!, for: fixedDate)
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int?
    
    override func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>? {
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)

        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        let applesSmaller = smaller.calendarComponent()
        let applesLarger  = larger.calendarComponent()
        if applesSmaller == nil || applesLarger == nil {
            return nil
        }
        
        var result = self.applesCalendar.range(of: applesSmaller!, in: applesLarger!, for: fixedDate)
        if result?.lowerBound == result?.upperBound {
            let upperBound = result?.upperBound ?? 1
            result = Range(uncheckedBounds: (1, upperBound))
        }
        return result
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>?
    
    
    // MARK: - Stuff identical to the stuff in ASAJudeoIslamicCalendar
    
    override func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.weekdaySymbols(localeIdentifier: localeIdentifier)
    } // func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func weekendDays(for regionCode: String?) -> Array<Int> {
        self.applesCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK: - Stuff identical to the stuff in ASAJudeoIslamicCalendar
    
    override func monthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.monthSymbols(localeIdentifier: localeIdentifier)
    } // func monthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - Stuff identical to the stuff in ASAJudeoIslamicCalendar
    
    override func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.quarterSymbols(localeIdentifier: localeIdentifier)
    } // func quarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    } // func shortQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    } // func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - Stuff identical to the stuff in ASAJudeoIslamicCalendar
    
    override func eraSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.eraSymbols(localeIdentifier: localeIdentifier)
    } // func eraSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    override func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.longEraSymbols(localeIdentifier: localeIdentifier)
    } // func longEraSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK:  - Stuff unique to this class
    
    override var midPointTransition: ASASolarEvent {
        return .sunset
    } // var midPointTransition
    
    override var dateTransition: ASASolarEvent {
        return .sunrise
    } // var dateTransition: ASASolarEvent

    // South Asian calendars: date boundary is sunrise; midpoint between halves is sunset.
    // Override to compute solar-time hours accordingly.
    override func solarTimeComponents(now: Date, locationData: ASALocation, dateBoundary: Date?) -> (hours: Double, daytime: Bool, valid: Bool) {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
        var sunriseBoundary: Date
        if dateBoundary == nil {
            // Sometimes dateBoundary is nil for some reason, so we need to compensate
            let temp = now
                .previousMidnight(timeZone: timeZone)
                .solarEvents(location: location, events: [.sunrise], timeZone: timeZone)[.sunrise]
            guard temp != nil else {
                debugPrint(
                    #file,
                    #function, "sunrise boundary is nil")
                return (hours: -1.0, daytime: false, valid: false)
            }
            
            sunriseBoundary = temp!
        } else {
            sunriseBoundary = dateBoundary!
        }

        let NUMBER_OF_HOURS = 12.0

        func sunset(on reference: Date) -> Date? {
            reference.solarEvents(location: location, events: [self.midPointTransition], timeZone: timeZone)[self.midPointTransition]
        }
        func sunrise(on reference: Date) -> Date? {
            reference.solarEvents(location: location, events: [.sunrise], timeZone: timeZone)[.sunrise]
        }

        // 1) Before sunrise -> Nighttime (previous sunset -> this sunrise)
        if now < sunriseBoundary {
            debugPrint(
                #file,
                #function, "now < sunriseBoundary",
                "now:",
                now,
                "sunrise boundary:",
                sunriseBoundary
            )
            let prevDate = now.noon(timeZone: timeZone).oneDayBefore
            if let prevSunset = sunset(on: prevDate) {
                let hours = now.fractionalHours(startDate: prevSunset, endDate: sunriseBoundary, numberOfHoursPerDay: NUMBER_OF_HOURS)
                return (hours: hours, daytime: false, valid: true)
            } else {
                return (hours: -1.0, daytime: false, valid: false)
            }
        }

        // Compute today's sunset relative to the sunriseBoundary day
        // We look up sunset using `now`; if it occurs before today's sunrise, re-query using next day.
        var todaysSunset: Date?
        if let s = sunset(on: now), s > sunriseBoundary {
            todaysSunset = s
        } else {
            // If sunset lookup mismatched the day, try using the next civil date
            let nextRef = now.noon(timeZone: timeZone).oneDayAfter
            if let s2 = sunset(on: nextRef), s2 > sunriseBoundary {
                todaysSunset = s2
            }
        }

        // 2) After sunset -> Nighttime (sunset -> next sunrise)
        if let s = todaysSunset, now >= s {
            let nextDate = now.noon(timeZone: timeZone).oneDayAfter
            if let nextSunrise = sunrise(on: nextDate) {
                let hours = now.fractionalHours(startDate: s, endDate: nextSunrise, numberOfHoursPerDay: NUMBER_OF_HOURS)
                return (hours: hours, daytime: false, valid: true)
            } else {
                return (hours: -1.0, daytime: false, valid: false)
            }
        }

        // 3) Otherwise, daytime (sunrise -> sunset)
        if let s = todaysSunset {
            let hours = now.fractionalHours(startDate: sunriseBoundary, endDate: s, numberOfHoursPerDay: NUMBER_OF_HOURS)
            return (hours: hours, daytime: true, valid: true)
        }

        return (hours: -1.0, daytime: false, valid: false)
    }

    
    override func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        // The start of the South Asian day is the sunrise that occurs on that civil date.
        // If sunrise is before local midnight (rare due to timezone math), fall back to previous/next logic.
        // We compute sunrise on the given date; if unavailable, we try neighboring days.
        let location = locationData.location
        let tz = locationData.timeZone
        
        let events = date.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
        if let sunrise = events[ASASolarEvent.sunrise] {
            return sunrise
        }
        // Try previous day
        if let prevDate = self.applesCalendar.date(byAdding: .day, value: -1, to: date) {
            let prevEvents = prevDate.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
            if let prevSunrise = prevEvents[ASASolarEvent.sunrise] {
                // If date occurs before the first available sunrise (polar), choose previous sunrise
                return prevSunrise
            }
        }
        // Try next day as last resort
        if let nextDate = self.applesCalendar.date(byAdding: .day, value: 1, to: date) {
            let nextEvents = nextDate.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
            if let nextSunrise = nextEvents[ASASolarEvent.sunrise] {
                return nextSunrise
            }
        }
        // Fallback to midnight if all else fails
        return self.applesCalendar.startOfDay(for: date)
    }

    override func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        // Next day begins at the next sunrise strictly after the start-of-day for this date.
        let location = locationData.location
        let tz = locationData.timeZone
        
        let start = self.startOfDay(for: date, locationData: locationData)
        // Search forward for the next sunrise after `start`
        if let nextDate = self.applesCalendar.date(byAdding: .day, value: 1, to: start) {
            let nextEvents = nextDate.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
            if let nextSunrise = nextEvents[ASASolarEvent.sunrise] {
                return nextSunrise
            }
        }
        // If that failed (e.g., polar), try stepping day-by-day until we find one, up to a small cap
        var probe = start
        for _ in 0..<7 {
            probe = self.applesCalendar.date(byAdding: .day, value: 1, to: probe) ?? probe.addingTimeInterval(86400)
            if let s = probe.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)[ASASolarEvent.sunrise] {
                return s
            }
        }
        // Fallback: add 24 hours
        return start.addingTimeInterval(24 * 3600)
    }
}
