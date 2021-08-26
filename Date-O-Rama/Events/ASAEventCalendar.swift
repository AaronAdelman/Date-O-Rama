//
//  ASAEventCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation
import SwiftAA

class ASAEventCalendar {
    var fileName:  String
    var eventsFile:  ASAEventsFile?
    var error:  Error?
    var otherCalendars:  Dictionary<ASACalendarCode, ASACalendar> = [:]


    init(fileName:  String) {
        self.fileName = fileName
        (self.eventsFile, self.error) = ASAEventsFile.builtIn(fileName: fileName)

        if eventsFile != nil {
            if eventsFile!.otherCalendarCodes != nil {
                for calendarCode in eventsFile!.otherCalendarCodes! {
                    otherCalendars[calendarCode] = ASACalendarFactory.calendar(code: calendarCode)
                } // for calendarCode in eventsFile!.otherCalendarCodes!
            }
        }
    } // init(fileName:  String)

    func events(startDate: Date, endDate: Date, locationData:  ASALocation, eventCalendarName: String, calendarTitleWithoutLocation:  String, regionCode:  String?, requestedLocaleIdentifier:  String, calendar:  ASACalendar) -> Array<ASAEvent> {
        //        debugPrint(#file, #function, startDate, endDate, location, timeZone)

        if self.eventsFile == nil {
            // Something went wrong
            return []
        }

        let timeZone: TimeZone = locationData.timeZone 
        var now = startDate.addingTimeInterval(endDate.timeIntervalSince(startDate) / 2.0)
//        var startOfDay = calendar.startOfDay(for: startDate, locationData: locationData)
        var startOfDay = startDate
        var startOfNextDay = calendar.startOfNextDay(date: startDate, locationData: locationData)
        var result:  Array<ASAEvent> = []
        repeat {
            let temp = self.events(date: now.noon(timeZone: timeZone), locationData: locationData, eventCalendarName: eventCalendarName, calendarTitleWithoutLocation: calendarTitleWithoutLocation, calendar: calendar, otherCalendars: otherCalendars, regionCode: regionCode, requestedLocaleIdentifier: requestedLocaleIdentifier, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
            for event in temp {
                if event.relevant(startDate:  startDate, endDate:  endDate) && !result.contains(event) {
                    result.append(event)
                } else {
                }
            } // for event in tempResult
            startOfDay = startOfNextDay
            startOfNextDay = calendar.startOfNextDay(date: now, locationData: locationData)

            now = startOfDay.addingTimeInterval(startOfNextDay.timeIntervalSince(startOfDay) / 2.0)

        } while startOfDay < endDate

        return result
    } // func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocation, eventCalendarName: String) -> Array<ASAEvent>
    
    var color:  SwiftUI.Color {
        return self.eventsFile!.calendarColor
    } // var color

    func title(localeIdentifier:  String) -> String {
        return self.eventsFile!.titles[localeIdentifier] ?? "???"
    }

    /// Fills in nil fields in one date specification with information from another.
    /// - Parameters:
    ///   - dateSpecification: The date specification which may need information filled in
    ///   - date: The corresponding date.
    ///   - calendar: The relevant calendar object
    ///   - templateDateComponents: The “donor” date description
    /// - Returns: The date description with nil fields filled in
    func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar, templateDateComponents:  ASADateComponents) -> ASADateSpecification {
        var tweakedDateSpecification = dateSpecification
        
        if tweakedDateSpecification.era == nil && templateDateComponents.era != nil {
            tweakedDateSpecification.era = templateDateComponents.era!
        }
        if tweakedDateSpecification.year == nil && templateDateComponents.year != nil {
            tweakedDateSpecification.year = templateDateComponents.year!
        }
        if tweakedDateSpecification.month == nil && templateDateComponents.month != nil {
            tweakedDateSpecification.month = templateDateComponents.month!
        }
        if tweakedDateSpecification.day == nil && templateDateComponents.day != nil {
            tweakedDateSpecification.day = templateDateComponents.day!
        }
        
        if tweakedDateSpecification.day! < 0 {
            let tweakedDate = calendar.date(dateComponents: ASADateComponents(calendar: calendar, locationData: templateDateComponents.locationData, era: tweakedDateSpecification.era, year: tweakedDateSpecification.year, yearForWeekOfYear: nil, quarter: nil, month: tweakedDateSpecification.month, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: tweakedDateSpecification.day, hour: nil, minute: nil, second: nil, nanosecond: nil))
            if tweakedDate != nil {
                let numberOfDaysInMonth = calendar.maximumValue(of: .day, in: .month, for: tweakedDate!)!
                tweakedDateSpecification.day = tweakedDateSpecification.day! + (numberOfDaysInMonth + 1)
                
                //            debugPrint(#file, #function, "📆 Date:", date, "🔴 Original date specification:", dateSpecification, "🟢 Tweaked date specification:", tweakedDateSpecification, "🗓 Calendar:", calendar, "Template date components:", templateDateComponents)
            }
        }
        return tweakedDateSpecification
    } // func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar) -> ASADateSpecification
    
    fileprivate let MATCH_FAILURE: (matches:  Bool, startDate:  Date?, endDate:  Date?) = (false, nil, nil)

    func matchTimeChange(timeZone: TimeZone, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let oneSecondBeforeStartOfDay = startOfDay.addingTimeInterval(-1.0)
        let nextDaylightSavingTimeTransition = timeZone.nextDaylightSavingTimeTransition(after: oneSecondBeforeStartOfDay)
        if nextDaylightSavingTimeTransition != nil {
            let nextTransition: Date = nextDaylightSavingTimeTransition!
            if startOfDay <= nextTransition && nextTransition < startOfNextDay {
               return (true, nextTransition, nextTransition)
            }
        }
        
        return MATCH_FAILURE
    } // func matchTimeChange(timeZone: TimeZone, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func matchMoonPhase(type: ASATimeSpecificationType, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        var phase: MoonPhase
        switch type {
        case .fullMoon:
            phase = .fullMoon
            
        case .newMoon:
            phase = .newMoon
            
        case .firstQuarter:
            phase = .firstQuarter
            
        case .lastQuarter:
            phase = .lastQuarter
            
        default:
            // Should not happen!
            return MATCH_FAILURE
        } // switch type
        
        let now = JulianDay(startOfDay)
        let luna = Moon(julianDay: now, highPrecision: true)
        
        let julianDayOfNextPhase: JulianDay = luna.time(of: phase, forward: true, mean: false)
        let nextPhase = julianDayOfNextPhase.date
        if nextPhase < startOfNextDay {
            return (true, nextPhase, nextPhase)
        }
        
        return MATCH_FAILURE
    } // func matchMoonPhase(type: ASATimeSpecificationType, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func matchNumberedFullMoon(startDateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {

        // Check if this is a full Moon
        let fullMoonTuple = matchMoonPhase(type: .fullMoon, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
        if !fullMoonTuple.matches {
            return MATCH_FAILURE
        }
        
        // Check the month
        guard let componentsMonth = components.month else {
            return MATCH_FAILURE
        }
        guard let startDateSpecifiationMonth = startDateSpecification.month else {
            return MATCH_FAILURE
        }
        if componentsMonth != startDateSpecifiationMonth {
            return MATCH_FAILURE
        }
        
        // Check which day this falls on
        guard let componentsDay = components.day else {
            return MATCH_FAILURE
        }
        let CUTOFF = ((12.0 * 60.0) + 44.0) * 60.0 + 2.9
        switch startDateSpecification.type {
        case .firstFullMoonDay:
            if componentsDay < 30 {
                return (true, nil, nil)
                
            }
            if componentsDay == 30 {
                guard let secondsSinceMidnight: Double = components.secondsSinceStartOfDay else {
                    return MATCH_FAILURE
                }
                if secondsSinceMidnight < CUTOFF {
                    return (true, nil, nil)
                }
            }
            return MATCH_FAILURE
            
        case.secondFullMoonDay:
            if componentsDay > 30 {
                return (true, nil, nil)
            }
            guard let secondsSinceMidnight: Double = components.secondsSinceStartOfDay else {
                return MATCH_FAILURE
            }
            if secondsSinceMidnight > CUTOFF {
                return (true, nil, nil)
            }
            return MATCH_FAILURE
            
        default:
            // Should not happen
            return MATCH_FAILURE
        } // switch startDateSpecification.type
    } // func matchNumberedFullMoon(startDateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func possibleDate(for type: ASATimeSpecificationType, now: JulianDay) -> Date? {
        let terra = Earth(julianDay: now, highPrecision: true)
        var possibleDate: Date
        
        switch type {
        case .MarchEquinox:
            let MarchEquinox = terra.equinox(of: .northwardSpring)
            possibleDate = MarchEquinox.date
            
        case .JuneSolstice:
            let JuneSolstice = terra.solstice(of: .northernSummer)
            possibleDate = JuneSolstice.date
            
        case .SeptemberEquinox:
            let SeptemberEquinox = terra.equinox(of: .southwardSpring)
            possibleDate = SeptemberEquinox.date
            
        case .DecemberSolstice:
            let DecemberSolstice = terra.solstice(of: .southernSummer)
            possibleDate = DecemberSolstice.date

        default:
            return nil
        } // switch type
        
        return possibleDate
    } // func possibleDate(for type: ASATimeSpecificationType, now: JulianDay) -> Date?
    
    func matchEquinoxOrSolstice(type: ASATimeSpecificationType, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let initialDate = JulianDay(startOfDay)
        guard let dateThisYear = possibleDate(for: type, now: initialDate) else {
            return MATCH_FAILURE
        }
        
        if startOfDay <= dateThisYear && dateThisYear < startOfNextDay {
            return (true, dateThisYear, dateThisYear)
        }
        
        let NUMBER_OF_DAYS_PER_YEAR = 365.2425
        
        if dateThisYear < startOfDay {
            guard let dateLastYear = possibleDate(for: type, now: JulianDay(initialDate.value - NUMBER_OF_DAYS_PER_YEAR)) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateLastYear && dateThisYear < dateLastYear {
                return (true, dateLastYear, dateLastYear)
            }
        } else if dateThisYear > startOfNextDay {
            guard let dateNextYear = possibleDate(for: type, now: JulianDay(initialDate.value + NUMBER_OF_DAYS_PER_YEAR)) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateNextYear && dateThisYear < dateNextYear {
                return (true, dateNextYear, dateNextYear)
            }
        }

        return MATCH_FAILURE
    } // func matchEquinoxOrSolstice(type: ASATimeSpecificationType, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func possibleDate(for type: ASATimeSpecificationType, now: JulianDay, body: String?, location: ASALocation?) -> Date? {
        switch type {
        case .rise, .set:
            guard let body = body else {
                return nil
            }
            guard let celestialBody = body.celestialBody(julianDay: now) else {
                return nil
            }
            let riseSetTimes = celestialBody.riseTransitSetTimes(for: GeographicCoordinates(location!.location))
            switch type {
            case .rise:
                return riseSetTimes.riseTime?.date
                
            case .set:
                return riseSetTimes.setTime?.date
                
            default:
                return nil
            }

        default:
            return nil
        } // switch type
    } // func possibleDate(for type: ASATimeSpecificationType, now: JulianDay, body: String?, location: ASALocation?) -> Date?
    
    func matchRiseOrSet(type: ASATimeSpecificationType, startOfDay:  Date, startOfNextDay:  Date, body: String, locationData: ASALocation) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let initialDate: JulianDay = JulianDay(startOfDay.addingTimeInterval(startOfNextDay.timeIntervalSince(startOfDay) / 2.0).noon(timeZone: locationData.timeZone))
        let dateToday = possibleDate(for: type, now: initialDate, body: body, location: locationData)
        
        if dateToday != nil {
            if startOfDay <= dateToday! && dateToday! < startOfNextDay {
                return (true, dateToday!, dateToday!)
            }
        }
                
        if dateToday ?? Date.distantPast < startOfDay{
            guard let dateTomorrow = possibleDate(for: type, now: initialDate + 1, body: body, location: locationData) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateTomorrow && dateTomorrow < startOfNextDay {
                return (true, dateTomorrow, dateTomorrow)
            }
        } else if dateToday ?? Date.distantFuture >= startOfNextDay {
            guard let dateYesterday = possibleDate(for: type, now: initialDate - 1, body: body, location: locationData) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateYesterday && dateYesterday < startOfNextDay {
                return (true, dateYesterday, dateYesterday)
            }
        }

        return MATCH_FAILURE
    } // func matchRiseOrSet(type: ASATimeSpecificationType, startOfDay:  Date, startOfNextDay:  Date, body: String, locationData: ASALocation) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date, firstDateSpecification: ASADateSpecification?) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
                    
        // Time change events
        let startDateSpecificationType: ASATimeSpecificationType = startDateSpecification.type
        if startDateSpecificationType == .timeChange {
            return matchTimeChange(timeZone: locationData.timeZone, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
        }
        
        // Moon phases
        if startDateSpecificationType == .newMoon || startDateSpecificationType == .firstQuarter || startDateSpecificationType == .fullMoon || startDateSpecificationType == .lastQuarter {
            return matchMoonPhase(type: startDateSpecificationType, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
        }
        
        // Numbered full moon days
        if startDateSpecificationType == .firstFullMoonDay || startDateSpecificationType == .secondFullMoonDay {
            return matchNumberedFullMoon(startDateSpecification: startDateSpecification, components: components, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
        }
        
        // Equinoxes and solstices
        if startDateSpecificationType == .MarchEquinox || startDateSpecificationType == .JuneSolstice || startDateSpecificationType == .SeptemberEquinox || startDateSpecificationType == .DecemberSolstice {
            return matchEquinoxOrSolstice(type: startDateSpecificationType, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
        }
        
        // Rise and set
        if startDateSpecificationType == .rise || startDateSpecificationType == .set {
            guard let body = startDateSpecification.body else { return MATCH_FAILURE }
            return matchRiseOrSet(type: startDateSpecificationType, startOfDay: startOfDay, startOfNextDay: startOfNextDay, body: body, locationData: locationData)
        }
        
        var tweakedStartDateSpecification = self.tweak(dateSpecification: startDateSpecification, date: date, calendar: calendar, templateDateComponents: components)
        
        // Check whether the event is before the first occurrence
        if firstDateSpecification != nil {            
            let start = tweakedStartDateSpecification.EYMD
            let first = firstDateSpecification!.EYMD
                        
            if !start.isAfterOrEqual(first: first) {
                return MATCH_FAILURE
            }
        }

        // One-year events
        if startDateSpecificationType == .oneYear {
            assert(endDateSpecification == nil)
            let matches = self.matchOneYear(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: tweakedStartDateSpecification, components: components)
            if matches {
                let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
                let endDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
                return (true, startDate, endDate)
            } else {
                return MATCH_FAILURE
            }
        }
        
        // Multi-year events
        if startDateSpecificationType == .multiYear {
            assert(endDateSpecification != nil)
            
            let dateEY: Array<Int?>      = components.EY
            let startDateEY: Array<Int?> = startDateSpecification.EY
            let endDateEY: Array<Int?>   = endDateSpecification!.EY
            let within: Bool = dateEY.isWithin(start: startDateEY, end: endDateEY)
            
            if !within {
                return MATCH_FAILURE
            }
            
            let (filledInStartDateEY, filledInEndDateEY) = dateEY.fillInFor(start: startDateEY, end: endDateEY)
            
            tweakedStartDateSpecification = startDateSpecification.fillIn(EY: filledInStartDateEY)
            
            let tweakedEndDateSpecification = endDateSpecification!.fillIn(EY: filledInEndDateEY)

            let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
            let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
            return (true, startDate, endDate)
        }
        
        // One-month events
        if startDateSpecificationType == .oneMonth {
            assert(endDateSpecification == nil)
            
            let matches = self.matchOneMonth(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: tweakedStartDateSpecification, components: components)
            if matches {
                let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
                let endDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
                return (true, startDate, endDate)
            } else {
                return MATCH_FAILURE
            }
        }
        
        // Multi-month events
        if startDateSpecificationType == .multiMonth {
            assert(endDateSpecification != nil)
            
            if !matchOneYear(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: startDateSpecification, components: components) {
                return MATCH_FAILURE
            }
            
            let dateEYM: Array<Int?>      = components.EYM
            let startDateEYM: Array<Int?> = startDateSpecification.EYM
            let endDateEYM: Array<Int?>   = endDateSpecification!.EYM
            let within: Bool = dateEYM.isWithin(start: startDateEYM, end: endDateEYM)
            
            if !within {
                return MATCH_FAILURE
            }
            
            let (filledInStartDateEYM, filledInEndDateEYM) = dateEYM.fillInFor(start: startDateEYM, end: endDateEYM)
            
            tweakedStartDateSpecification = startDateSpecification.fillIn(EYM: filledInStartDateEYM)
            
            let tweakedEndDateSpecification = endDateSpecification!.fillIn(EYM: filledInEndDateEYM)

            let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
            let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
            return (true, startDate, endDate)
        }

        if endDateSpecification == nil {
            // One-day and one-instant events
            assert(endDateSpecification?.type != .multiDay)
            let matches = self.matchOneDayOrInstant(date: date, calendar: calendar, locationData: locationData, dateSpecification: tweakedStartDateSpecification, components: components)
            
            if matches && tweakedStartDateSpecification.type == .IslamicPrayerTime {
                if tweakedStartDateSpecification.event == nil {
                    // Major error!
                    debugPrint(#file, #function, "Missing Islamic prayer event!")
                    return MATCH_FAILURE
                }
                let events = date.prayerTimesSunsetTransition(latitude: locationData.location.coordinate.latitude, longitude: locationData.location.coordinate.longitude, calcMethod: tweakedStartDateSpecification.calculationMethod ?? .Jafari, asrJuristic: tweakedStartDateSpecification.asrJuristicMethod ?? .Shafii, dhuhrMinutes: tweakedStartDateSpecification.dhuhrMinutes ?? 0.0, adjustHighLats: tweakedStartDateSpecification.adjustingMethodForHigherLatitudes ?? .midnight, events: [tweakedStartDateSpecification.event!])
                let startDate = events![tweakedStartDateSpecification.event!]
                return (matches, startDate, startDate)
            } else {
                if startDateSpecification.type == .oneDay {
                    return (matches, startOfDay, startOfNextDay)
                }
                return (matches, nil, nil)
            }
        }
        
        // Now we are clearly dealing with an event with specified start and end dates
        let dateEYMD: Array<Int?>      = components.EYMD
        let startDateEYMD: Array<Int?> = startDateSpecification.EYMD
        let endDateEYMD: Array<Int?>   = endDateSpecification!.EYMD
        let within: Bool = dateEYMD.isWithin(start: startDateEYMD, end: endDateEYMD)
        
        if !within {
            return MATCH_FAILURE
        }
        
        let (filledInStartDateEYMD, filledInEndDateEYMD) = dateEYMD.fillInFor(start: startDateEYMD, end: endDateEYMD)
        
        tweakedStartDateSpecification = startDateSpecification.fillIn(EYMD: filledInStartDateEYMD)
        
        let tweakedEndDateSpecification = endDateSpecification!.fillIn(EYMD: filledInEndDateEYMD)
        
        let eventStartDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
        if eventStartDate == nil {
            return MATCH_FAILURE
        }
        let eventEndDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
        if eventEndDate == nil {
            return MATCH_FAILURE
        }
        
        let eventStartComponents = calendar.dateComponents([.era, .year, .month, .day, .weekday], from: eventStartDate!, locationData: locationData)
        let eventEndComponents = calendar.dateComponents([.era, .year, .month, .day, .weekday], from: eventEndDate!, locationData: locationData)
        
        if !self.matchYearSupplemental(date: eventStartDate!, components: eventStartComponents, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return MATCH_FAILURE
        }
        
        if !self.matchYearSupplemental(date: eventEndDate!, components: eventEndComponents, dateSpecification: tweakedEndDateSpecification, calendar: calendar) {
            return MATCH_FAILURE
        }
        
        if !self.matchMonthSupplemental(date: eventStartDate!, components: eventStartComponents, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return MATCH_FAILURE
        }

        if !self.matchMonthSupplemental(date: eventEndDate!, components: eventEndComponents, dateSpecification: tweakedEndDateSpecification, calendar: calendar) {
            return MATCH_FAILURE
        }

        let dateStartOfDay = calendar.startOfDay(for: date, locationData: locationData)
        let dateEndOfDay = calendar.startOfNextDay(date: date, locationData: locationData)

        if eventStartDate == eventEndDate && eventStartDate == dateStartOfDay {
            return (true, eventStartDate, eventEndDate)
        }
        
        if dateEndOfDay <= eventStartDate! {
            return MATCH_FAILURE
        }

        if dateStartOfDay >= eventEndDate! {
            return MATCH_FAILURE
        }
        
        return (true, eventStartDate, eventEndDate)
    } // func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?, components: ASADateComponents) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfYear != nil {
            let numberOfDaysInYear = calendar.maximumValue(of: .day, in: .year, for: date)!
            //            debugPrint(#file, #function, rangeOfDaysInYear as Any, numberOfDaysInYear as Any)
            if !numberOfDaysInYear.matches(values: dateSpecification.lengthsOfYear) {
                return false
            }
        }
        
        if dateSpecification.dayOfYear != nil {
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)
            if dayOfYear == nil {
                return false
            }
            if !dayOfYear!.matches(value: dateSpecification.dayOfYear) {
                return false
            }
        }

        if dateSpecification.yearDivisor != nil && dateSpecification.yearRemainder != nil {
            let year = components.year
            let (_, remainder) = year!.quotientAndRemainder(dividingBy:  dateSpecification.yearDivisor!)
            if !remainder.matches(value: dateSpecification.yearRemainder) {
                return false
            }
        }
        
        return true
    } // func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfMonth != nil {
            let numberOfDaysInMonth = calendar.maximumValue(of: .day, in: .month, for: date)!
            if !numberOfDaysInMonth.matches(values: dateSpecification.lengthsOfMonth) {
                return false
            }
        }
        
        return true
    } // func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func matchOneYear(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        let supportsEra: Bool = calendar.supports(calendarComponent: .era)
        if supportsEra {
            if !(components.era?.matches(value: onlyDateSpecification.era) ?? false) {
                return false
            }
        }

        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
        if supportsYear {
            if !(components.year?.matches(value: onlyDateSpecification.year) ?? false) {
                return false
            }
            
            if !self.matchYearSupplemental(date: date, components: components, dateSpecification: onlyDateSpecification, calendar: calendar) {
                return false
            }
        }
        
        return true
    } // func matchOneYear(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool
    
    func matchOneMonth(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        if !matchOneYear(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: onlyDateSpecification, components: components) {
            return false
        }
        
        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
        if supportsMonth {
            if !(components.month?.matches(value: onlyDateSpecification.month) ?? false) {
                return false
            }
            
            if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: onlyDateSpecification, calendar: calendar) {
                return false
            }
        }

        return true
    } // func matchOneMonth(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool
    
    func matchOneDayOrInstant(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        if !matchOneMonth(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: dateSpecification, components: components) {
            return false
        }
        
        let supportsDay: Bool = calendar.supports(calendarComponent: .day)
        if supportsDay {
            if dateSpecification.day != nil {
                // Check specified day of month
                if !(components.day!.matches(value: dateSpecification.day!) ) {
                    return false
                }
            }
        }
        
        let supportsWeekday: Bool = calendar.supports(calendarComponent: .weekday)
        if supportsWeekday {
            if !(components.weekday?.matches(weekdays: dateSpecification.weekdays) ?? false) {
                return false
            }
        }
        
        if dateSpecification.weekdayRecurrence != nil && dateSpecification.weekdays != nil {
            let daysInMonth = calendar.maximumValue(of: .day, in: .month, for: date) ?? 1
            
            if !(components.day!.matches(recurrence: dateSpecification.weekdayRecurrence!, lengthOfWeek: calendar.daysPerWeek!, lengthOfMonth: daysInMonth)) {
                return false
            }
        }

        return true
    } // func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification) -> Bool
    
    func events(date:  Date, locationData:  ASALocation, eventCalendarName: String, calendarTitleWithoutLocation:  String, calendar:  ASACalendar, otherCalendars: Dictionary<ASACalendarCode, ASACalendar>, regionCode:  String?, requestedLocaleIdentifier:  String, startOfDay:  Date, startOfNextDay:  Date) -> Array<ASAEvent> {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
        let previousDate = date.oneDayBefore
        let previousEvents = previousDate.solarEvents(location: location, events: [.sunset, .dusk72Minutes], timeZone:  timeZone)
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        let previousOtherDusk:  Date = previousEvents[.dusk72Minutes]!!
        
        let events = date.solarEvents(location: location, events: [.sunrise, .sunset, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
        
        // According to the גר״א
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        let nightLength = sunrise.timeIntervalSince(previousSunset)
        let nightHourLength = nightLength / 12.0
        
        let dayLength = sunset.timeIntervalSince(sunrise)
        let hourLength = dayLength / 12.0
        
        // According to the מגן אברהם
        let otherDawn = events[.dawn72Minutes]!! // עלות השחר
        let otherDusk = events[.dusk72Minutes]!! // צאת הכוכבים
        
        let otherNightLength = otherDawn.timeIntervalSince(previousOtherDusk)
        let otherNightHourLength = otherNightLength / 12.0
        
        let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
        let otherHourLength = otherDayLength / 12.0
        
        var result:  Array<ASAEvent> = []
        
        let components = calendar.dateComponents([.era, .year, .month, .day, .weekday], from: date, locationData: locationData)
        
        for eventSpecification in self.eventsFile!.eventSpecifications {
            assert(previousSunset.oneDayAfter > date)
            
            var appropriateCalendar:  ASACalendar = calendar
            if eventSpecification.calendarCode != nil {
                let probableAppropriateCalendar = otherCalendars[eventSpecification.calendarCode!]
                if probableAppropriateCalendar != nil {
                    appropriateCalendar = probableAppropriateCalendar!
                }
            }
            var appropriateComponents: ASADateComponents
            if calendar.calendarCode == appropriateCalendar.calendarCode {
                appropriateComponents = components
            } else {
                appropriateComponents = appropriateCalendar.dateComponents([.era, .year, .month, .day, .weekday], from: date, locationData: locationData)
            }
            
            let (matchesDateSpecifications, returnedStartDate, returnedEndDate) = self.match(date: date, calendar: appropriateCalendar, locationData: locationData, startDateSpecification: eventSpecification.startDateSpecification, endDateSpecification: eventSpecification.endDateSpecification, components: appropriateComponents, startOfDay: startOfDay, startOfNextDay: startOfNextDay, firstDateSpecification: eventSpecification.firstDateSpecification)
            if matchesDateSpecifications {
                let matchesRegionCode: Bool = eventSpecification.match(regionCode: regionCode, latitude: location.coordinate.latitude)
                if matchesRegionCode {
                    var title: String
                    if eventSpecification.startDateSpecification.type == .timeChange {
                        let oneSecondBeforeChange = returnedStartDate!.addingTimeInterval(-1.0)
                        let oneSecondAfterChange = returnedStartDate!.addingTimeInterval(1.0)
                        let offsetBeforeChange = timeZone.daylightSavingTimeOffset(for: oneSecondBeforeChange)
                        let offsetAfterChange = timeZone.daylightSavingTimeOffset(for: oneSecondAfterChange)
                        if offsetBeforeChange < offsetAfterChange {
                            title = NSLocalizedString("Spring ahead", comment: "")
                        } else {
                            title = NSLocalizedString("Fall back", comment: "")
                        }
                    } else {
                        title = eventSpecification.eventTitle(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale) ?? ""
                    }
                    let color = self.color
                    var startDate = returnedStartDate
                    var endDate = returnedEndDate
                    
                    // We have to make sure that solar events after Sunset happen on the correct day.  This is an issue on Sunset transition calendars.
                    var fixedDate:  Date
                    if appropriateCalendar.transitionType == .sunset
                        && !eventSpecification.isAllDay
                        && eventSpecification.startDateSpecification.type == .degreesBelowHorizon
                        && eventSpecification.startDateSpecification.rising == false
                        && eventSpecification.startDateSpecification.offset ?? -1 >= 0 {
                        fixedDate = date.oneDayBefore
                    } else {
                        fixedDate = date
                    }
                    
                    if startDate == nil {
                        if eventSpecification.isAllDay {
                            startDate = appropriateCalendar.startOfDay(for: date, locationData: locationData)
                            endDate   = appropriateCalendar.startOfNextDay(date: date, locationData: locationData)
                        } else {
                            startDate = eventSpecification.startDateSpecification.date(date: fixedDate, location: location, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
                            if eventSpecification.endDateSpecification == nil {
                                endDate = startDate
                            } else {
                                endDate = eventSpecification.endDateSpecification!.date(date: fixedDate, location: location, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
                            }
                        }
                    }
                    
                    let location: String? = eventSpecification.eventLocation(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let url: URL? = eventSpecification.eventURL(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let notes: String? = eventSpecification.eventNotes(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let category: ASAEventCategory = eventSpecification.category ?? .generic
                    
                    let newEvent = ASAEvent(title:  title, location: location, startDate: startDate, endDate: endDate, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, url: url, notes: notes, color: color, calendarTitleWithLocation: eventCalendarName, calendarTitleWithoutLocation: calendarTitleWithoutLocation, calendarCode: appropriateCalendar.calendarCode, locationData:  locationData, recurrenceRules: eventSpecification.recurrenceRules, regionCodes: eventSpecification.regionCodes, excludeRegionCodes: eventSpecification.excludeRegionCodes, category: category, emoji: eventSpecification.emoji, fileEmoji: eventsFile?.emoji, type: eventSpecification.startDateSpecification.type)
                    result.append(newEvent)
                }
            }
        } // for eventSpecification in self.eventsFile.eventSpecifications
        return result
    } // func eventDetails(date:  Date, location:  locationData:  ASALocation, eventCalendarName: String) -> Array<ASAEvent>
    
    func eventCalendarNameWithPlaceName(locationData:  ASALocation, localeIdentifier:  String) -> String {
        let localizableTitle = self.eventCalendarNameWithoutPlaceName(localeIdentifier: localeIdentifier)
        let oneLineAddress = locationData.shortFormattedOneLineAddress
        return "\(NSLocalizedString(localizableTitle, comment: "")) • \(oneLineAddress)"
    } // func eventCalendarName(locationData:  ASALocation) -> String
    
    func eventCalendarNameWithoutPlaceName(localeIdentifier:  String) -> String {
        if self.eventsFile == nil {
            return self.fileName
        }
        
        let titles = self.eventsFile!.titles

        let userLocaleIdentifier = localeIdentifier == "" ? Locale.autoupdatingCurrent.identifier : localeIdentifier
        let firstAttempt = titles[userLocaleIdentifier]
        if firstAttempt != nil {
            return firstAttempt!
        }

        let userLanguageCode = userLocaleIdentifier.localeLanguageCode
        if userLanguageCode != nil {
            let secondAttempt = titles[userLanguageCode!]
            if secondAttempt != nil {
                return secondAttempt!
            }
        }

        let thirdAttempt = titles["en"]
        if thirdAttempt != nil {
            return thirdAttempt!
        }

        return "???"
    } // func eventSourceName() -> String
} // class ASAEventCalendar


// MARK: -

extension ASAEventCalendar {
    class func builtInEventCalendarFileNames(calendarCode:  ASACalendarCode) -> Array<String> {
        let mainBundle = Bundle.main
        let URLs = mainBundle.urls(forResourcesWithExtension: "json", subdirectory: nil)
        let rawFileNames: Array<String> = URLs!.map {
            $0.deletingPathExtension().lastPathComponent
        }
        var unsortedFileNames:  Array<String> = []
        for fileName in rawFileNames {
            let (eventsFile, _) = ASAEventsFile.builtIn(fileName: fileName)
            if (eventsFile?.calendarCode ?? .none).matches(calendarCode) {
                unsortedFileNames.append(fileName)
            }
        }
        let fileNames = unsortedFileNames.sorted(by: {NSLocalizedString($0, comment: "") < NSLocalizedString($1, comment: "")})
//        debugPrint(#file, #function, fileNames)

        return fileNames
    } // static var builtInEventCalendarFileNames
} // extension ASAEventCalendar


// MARK:  -

extension Array where Element == ASAEventCompatible {
    func nextEvents(now:  Date) -> Array<ASAEventCompatible> {
        let firstIndex = self.firstIndex(where: { $0.startDate > now })
        if firstIndex == nil {
            return []
        }
        let firstItemStartDate = self[firstIndex!].startDate

        var result:  Array<ASAEventCompatible> = []
        for i in firstIndex!..<self.count {
            let item_i: ASAEventCompatible = self[i]
            if item_i.startDate == firstItemStartDate {
                result.append(item_i)
            } else {
                break
            }
        } // for i

        return result
    } // func nextEvent(now:  Date) -> ASAEventCompatible?
} // extension Array where Element == ASAEventCompatible
