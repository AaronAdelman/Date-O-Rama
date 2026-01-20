//
//  ASASouthIndianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/01/2026.
//  Copyright © 2026 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

// Calendar object for Solar-time, Sunrise-transition calendars
class ASASouthIndianCalendar: ASASolarTimeCalendar {
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

    override func solarTimeComponents(now: Date, locationData: ASALocation, transition: Date?) -> (hours: Double, daytime: Bool, valid: Bool) {
        // Compute hours since sunrise and whether it's daytime (between sunrise and sunset)
        // If transition is nil, try to compute it from now
        let location = locationData.location
        let tz = locationData.timeZone
        
        let anchor: Date
        if let transition {
            anchor = transition
        } else {
            // derive sunrise for the relevant day
            let events = now.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
            guard let s = events[ASASolarEvent.sunrise] ?? nil else { return (hours: 0, daytime: false, valid: false) }
            anchor = s
        }

        let seconds = now.timeIntervalSince(anchor)
        let hours = seconds / 3600.0

        // Determine daytime by comparing to sunrise/sunset envelope
        let dayEvents = now.solarEvents(location: location, events: [ASASolarEvent.sunrise, ASASolarEvent.sunset], timeZone: tz)
        let sunriseToday = dayEvents[ASASolarEvent.sunrise] ?? nil
        let sunsetToday  = dayEvents[ASASolarEvent.sunset]  ?? nil

        var daytime = false
        var valid = true
        if let sRise = sunriseToday, let sSet = sunsetToday {
            daytime = (now >= sRise && now < sSet)
        } else if sunriseToday == nil && sunsetToday == nil {
            // Polar conditions: cannot determine reliably
            valid = false
        } else if sunriseToday == nil {
            // No sunrise -> continuous night/day; mark invalid for solar hour
            valid = false
        } else if sunsetToday == nil {
            // No sunset -> continuous day; mark as daytime but hours are still measured from sunrise
            daytime = true
        }

        return (hours: hours, daytime: daytime, valid: valid)
    }

    override func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        // The start of the South Indian day is the sunrise that occurs on that civil date.
        // If sunrise is before local midnight (rare due to timezone math), fall back to previous/next logic.
        // We compute sunrise on the given date; if unavailable, we try neighboring days.
        let location = locationData.location
        let tz = locationData.timeZone
        
        let events = date.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
        if let sunrise = events[ASASolarEvent.sunrise] {
            return sunrise!
        }
        // Try previous day
        if let prevDate = self.applesCalendar.date(byAdding: .day, value: -1, to: date) {
            let prevEvents = prevDate.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
            if let prevSunrise = prevEvents[ASASolarEvent.sunrise] {
                // If date occurs before the first available sunrise (polar), choose previous sunrise
                return prevSunrise!
            }
        }
        // Try next day as last resort
        if let nextDate = self.applesCalendar.date(byAdding: .day, value: 1, to: date) {
            let nextEvents = nextDate.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)
            if let nextSunrise = nextEvents[ASASolarEvent.sunrise] {
                return nextSunrise!
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
                return nextSunrise!
            }
        }
        // If that failed (e.g., polar), try stepping day-by-day until we find one, up to a small cap
        var probe = start
        for _ in 0..<7 {
            probe = self.applesCalendar.date(byAdding: .day, value: 1, to: probe) ?? probe.addingTimeInterval(86400)
            if let s = probe.solarEvents(location: location, events: [ASASolarEvent.sunrise], timeZone: tz)[ASASolarEvent.sunrise] {
                return s!
            }
        }
        // Fallback: add 24 hours
        return start.addingTimeInterval(24 * 3600)
    }
}


