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
import Contacts

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
    
    func events(startDate: Date, endDate: Date, locationData:  ASALocation, eventCalendarName: String, calendarTitle:  String, regionCode:  String?, requestedLocaleIdentifier:  String, calendar:  ASACalendar, clock: ASAClock) -> (dateEvents: Array<ASAEvent>, timeEvents: Array<ASAEvent>) {
        //        debugPrint(#file, #function, startDate, endDate, location, timeZone)
        
        if self.eventsFile == nil {
            // Something went wrong
            return ([], [])
        }
        
        let timeZone: TimeZone = locationData.timeZone
        var now = startDate.addingTimeInterval(endDate.timeIntervalSince(startDate) / 2.0)
        var startOfDay = startDate
        var startOfNextDay = calendar.startOfNextDay(date: startDate, locationData: locationData)
        var dateEvents:  Array<ASAEvent> = []
        var timeEvents:  Array<ASAEvent> = []
        repeat {
            let (tempDateEvents, tempTimeEvents) = self.events(date: now.noon(timeZone: timeZone), locationData: locationData, eventCalendarName: eventCalendarName, calendarTitle: calendarTitle, calendar: calendar, otherCalendars: otherCalendars, regionCode: regionCode, requestedLocaleIdentifier: requestedLocaleIdentifier, startOfDay: startOfDay, startOfNextDay: startOfNextDay, clock: clock)
            for event in tempDateEvents {
                if event.relevant(startDate:  startDate, endDate:  endDate) && !dateEvents.containsDuplicate(of: event) {
                    dateEvents.append(event)
                }
            } // for event in tempDateEvents
            for event in tempTimeEvents {
                if event.relevant(startDate:  startDate, endDate:  endDate) && !timeEvents.containsDuplicate(of: event) {
                    timeEvents.append(event)
                }
            } // for event in tempTimeEvents
            startOfDay = startOfNextDay
            startOfNextDay = calendar.startOfNextDay(date: now, locationData: locationData)
            
            now = startOfDay.addingTimeInterval(startOfNextDay.timeIntervalSince(startOfDay) / 2.0)
            
        } while startOfDay < endDate
        
        return (dateEvents, timeEvents)
    } // func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocation, eventCalendarName: String) -> Array<ASAEvent>
    
    var color:  SwiftUI.Color {
        return self.eventsFile!.calendarColor
    } // var color
    
    func title(localeIdentifier:  String) -> String {
        return self.eventsFile!.title(localeIdentifier: localeIdentifier)
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
            let tweakedDate = calendar.date(dateComponents: ASADateComponents(calendar: calendar, locationData: templateDateComponents.locationData, era: tweakedDateSpecification.era, year: tweakedDateSpecification.year, yearForWeekOfYear: nil, quarter: nil, month: tweakedDateSpecification.month, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: 1, hour: nil, minute: nil, second: nil, nanosecond: nil))
            if tweakedDate != nil {
                let numberOfDaysInMonth = calendar.daysInMonth(for: tweakedDate!)!
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
    
    func matchMoonPhase(type: ASAMoonPhaseType, startOfDay:  Date, startOfNextDay:  Date, dateSpecification: ASADateSpecification, components: ASADateComponents) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        if type == .firstFullMoon || type == .secondFullMoon {
            let matchesDayNumber = matchNumberedMoonPhaseNumbering(startDateSpecification: dateSpecification, components: components, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
            if !matchesDayNumber.matches {
                return MATCH_FAILURE
            }
        }
        
        var phase: MoonPhase
        switch type {
        case .fullMoon, .firstFullMoon, .secondFullMoon:
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
    } // func matchMoonPhase(type: ASAMoonPhaseType, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func matchNumberedMoonPhaseNumbering(startDateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        // Check the month
        guard let componentsMonth = components.month else {
            return MATCH_FAILURE
        }
        guard let startDateSpecificationMonth = startDateSpecification.month else {
            return MATCH_FAILURE
        }
        if componentsMonth != startDateSpecificationMonth {
            return MATCH_FAILURE
        }
        
        // Check which day this falls on
        guard let componentsDay = components.day else {
            return MATCH_FAILURE
        }
        let CUTOFF = ((12.0 * 60.0) + 44.0) * 60.0 + 2.9
        switch startDateSpecification.MoonPhase {
        case .firstFullMoon:
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
            
        case.secondFullMoon:
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
        } // switch startDateSpecification.MoonPhase
    } // func matchNumberedMoonPhaseNumbering(startDateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func possibleDateEquinoxOrSolstice(for type: ASAEquinoxOrSolsticeType, now: JulianDay) -> Date? {
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
    } // func possibleDateEquinoxOrSolstice(for type: ASAEquinoxOrSolsticeType, now: JulianDay) -> Date?
    
    func matchEquinoxOrSolstice(type: ASAEquinoxOrSolsticeType, startOfDay:  Date, startOfNextDay:  Date, offsetDays: Int) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        
        let initialDate = JulianDay(startOfDay)
        guard let dateThisYear = possibleDateEquinoxOrSolstice(for: type, now: initialDate) else {
            return MATCH_FAILURE
        }
        
        let offset = Double(offsetDays) * Date.SECONDS_PER_DAY
        
        let dateThisYearPlusOffset = dateThisYear.addingTimeInterval(offset)
        
        if startOfDay <= dateThisYearPlusOffset && dateThisYearPlusOffset < startOfNextDay {
            return (true, dateThisYearPlusOffset, dateThisYearPlusOffset)
        }
        
        let NUMBER_OF_DAYS_PER_YEAR = 365.2425
        
        if dateThisYearPlusOffset < startOfDay {
            guard let dateLastYear = possibleDateEquinoxOrSolstice(for: type, now: JulianDay(initialDate.value - NUMBER_OF_DAYS_PER_YEAR)) else {
                return MATCH_FAILURE
            }
            let dateLastYearPlusOffset = dateLastYear.addingTimeInterval(offset)
            
            if startOfDay <= dateLastYearPlusOffset && dateLastYearPlusOffset < startOfNextDay {
                return (true, dateLastYearPlusOffset, dateLastYearPlusOffset)
            }
        } else if dateThisYearPlusOffset > startOfNextDay {
            guard let dateNextYear = possibleDateEquinoxOrSolstice(for: type, now: JulianDay(initialDate.value + NUMBER_OF_DAYS_PER_YEAR)) else {
                return MATCH_FAILURE
            }
            let dateNextYearPlusOffset = dateNextYear.addingTimeInterval(offset)
            if startOfDay <= dateNextYearPlusOffset && dateNextYearPlusOffset < startOfNextDay {
                return (true, dateNextYearPlusOffset, dateNextYearPlusOffset)
            }
        }
        
        return MATCH_FAILURE
    } // func matchEquinoxOrSolstice(type: ASAEquinoxOrSolsticeType, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func possibleDateForRiseOrSet(for type: ASAPointEventType, now: JulianDay, body: String?, location: ASALocation?) -> Date? {
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
    } // func possibleDateForRiseOrSet(for type: ASAPointEventType, now: JulianDay, body: String?, location: ASALocation?) -> Date?
    
    func matchRiseOrSet(type: ASAPointEventType, startOfDay:  Date, startOfNextDay:  Date, body: String, locationData: ASALocation) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let initialDate: JulianDay = JulianDay(startOfDay.addingTimeInterval(startOfNextDay.timeIntervalSince(startOfDay) / 2.0).noon(timeZone: locationData.timeZone))
        let dateToday = possibleDateForRiseOrSet(for: type, now: initialDate, body: body, location: locationData)
        
        if dateToday != nil {
            if startOfDay <= dateToday! && dateToday! < startOfNextDay {
                return (true, dateToday!, dateToday!)
            }
        }
        
        if dateToday ?? Date.distantPast < startOfDay{
            guard let dateTomorrow = possibleDateForRiseOrSet(for: type, now: initialDate + 1, body: body, location: locationData) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateTomorrow && dateTomorrow < startOfNextDay {
                return (true, dateTomorrow, dateTomorrow)
            }
        } else if dateToday ?? Date.distantFuture >= startOfNextDay {
            guard let dateYesterday = possibleDateForRiseOrSet(for: type, now: initialDate - 1, body: body, location: locationData) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateYesterday && dateYesterday < startOfNextDay {
                return (true, dateYesterday, dateYesterday)
            }
        }
        
        return MATCH_FAILURE
    } // func matchRiseOrSet(type: ASAPointEventType, startOfDay:  Date, startOfNextDay:  Date, body: String, locationData: ASALocation) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func possibleDateForTwilight(now: JulianDay, degreesAboveHorizon: Double, rising: Bool, offset: TimeInterval, location: ASALocation) -> Date? {
        let terra = Earth(julianDay: now, highPrecision: true)
        let coordinates = GeographicCoordinates(location.location)
        
        let twilightTimes = terra.twilights(forSunAltitude: Degree(degreesAboveHorizon), coordinates: coordinates)
        switch rising {
        case true:
            guard let riseTime = twilightTimes.riseTime else {
                return nil
            }
            return riseTime.date + offset
            
        case false:
            guard let setTime = twilightTimes.setTime else {
                return nil
            }
            return setTime.date + offset
        } // switch rising
    } // func possibleDateForTwilight(now: JulianDay, degreesAboveHorizon: Double, rising: Bool, offset: TimeInterval, location: ASALocation) -> Date?
    
    func matchTwilight(startOfDay:  Date, startOfNextDay:  Date, degreesBelowHorizon: Double, rising: Bool, offset: TimeInterval, locationData: ASALocation) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let initialDate: JulianDay = JulianDay(startOfDay.addingTimeInterval(startOfNextDay.timeIntervalSince(startOfDay) / 2.0).noon(timeZone: locationData.timeZone))
        let degreesAboveHorizon = -degreesBelowHorizon
        let dateToday = possibleDateForTwilight(now: initialDate, degreesAboveHorizon: degreesAboveHorizon, rising: rising, offset: offset, location: locationData)
        
        if dateToday != nil {
            if startOfDay <= dateToday! && dateToday! < startOfNextDay {
                return (true, dateToday!, dateToday!)
            }
        }
        
        if dateToday ?? Date.distantPast < startOfDay{
            guard let dateTomorrow = possibleDateForTwilight(now: initialDate + 1, degreesAboveHorizon: degreesAboveHorizon, rising: rising, offset: offset, location: locationData) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateTomorrow && dateTomorrow < startOfNextDay {
                return (true, dateTomorrow, dateTomorrow)
            }
        } else if dateToday ?? Date.distantFuture >= startOfNextDay {
            guard let dateYesterday = possibleDateForTwilight(now: initialDate - 1, degreesAboveHorizon: degreesAboveHorizon, rising: rising, offset: offset, location: locationData) else {
                return MATCH_FAILURE
            }
            if startOfDay <= dateYesterday && dateYesterday < startOfNextDay {
                return (true, dateYesterday, dateYesterday)
            }
        }
        
        return MATCH_FAILURE
    } // func matchTwilight(startOfDay:  Date, startOfNextDay:  Date, degreesBelowHorizon: Double, rising: Bool, offset: TimeInterval, locationData: ASALocation) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    fileprivate func matchOneYear(date: Date, calendar: ASACalendar, locationData: ASALocation, tweakedStartDateSpecification: ASADateSpecification, components: ASADateComponents, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let matches = self.matchOneYear(date: date, calendar: calendar, locationData: locationData, dateSpecification: tweakedStartDateSpecification, components: components)
        if matches {
            let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
            let endDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: type)
            return (true, startDate, endDate)
        } else {
            return MATCH_FAILURE
        }
    } // func matchOneYear(date: Date, calendar: ASACalendar, locationData: ASALocation, tweakedStartDateSpecification: ASADateSpecification, components: ASADateComponents) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchMultiYear(endDateSpecification: ASADateSpecification?, components: ASADateComponents, startDateSpecification: ASADateSpecification, calendar: ASACalendar, date: Date, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        assert(endDateSpecification != nil)
        
        let dateEY: Array<Int?>      = components.EY
        let startDateEY: Array<Int?> = startDateSpecification.EY
        let endDateEY: Array<Int?>   = endDateSpecification!.EY
        let within: Bool = dateEY.isWithin(start: startDateEY, end: endDateEY)
        
        if !within {
            return MATCH_FAILURE
        }
        
        let (filledInStartDateEY, filledInEndDateEY) = dateEY.fillInFor(start: startDateEY, end: endDateEY)
        
        let tweakedStartDateSpecification = startDateSpecification.fillIn(EY: filledInStartDateEY)
        
        let tweakedEndDateSpecification = endDateSpecification!.fillIn(EY: filledInEndDateEY)
        
        let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
        let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: type)
        return (true, startDate, endDate)
    } // func matchMultiYear(endDateSpecification: ASADateSpecification?, components: ASADateComponents, startDateSpecification: ASADateSpecification, calendar: ASACalendar, date: Date) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchOneWeek(date: Date, calendar: ASACalendar, locationData: ASALocation, tweakedStartDateSpecification: ASADateSpecification, components: ASADateComponents, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let matchesOneMonth = self.matchOneMonth(date: date, calendar: calendar, locationData: locationData, dateSpecification: tweakedStartDateSpecification, components: components)
        if !matchesOneMonth {
            return MATCH_FAILURE
        }
        
        if calendar is ASACalendarSupportingWeeks {
            let day = components.day!
            let daysPerWeek = (calendar as! any ASACalendarSupportingWeeks as ASACalendarSupportingWeeks).daysPerWeek
            let daysInMonth = calendar.daysInMonth(for: date) ?? 1

            let span = daysOf(fullWeek: tweakedStartDateSpecification.fullWeek!, day: day, weekday: components.weekday!, daysPerWeek: daysPerWeek, monthLength: daysInMonth, firstDayOfWeek: (tweakedStartDateSpecification.firstDayOfWeek ?? ASADateSpecification.defaultFirstDayOfWeek).rawValue)
            guard let (startDay, endDay) = span else { return MATCH_FAILURE }
            if startDay <= day && day <= endDay {
                // Matches
                var weekStartSpecification = tweakedStartDateSpecification
                weekStartSpecification.day = startDay
                var weekEndSpecification = tweakedStartDateSpecification
                weekEndSpecification.day = endDay
                
                let startDate = weekStartSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
                let endDate = weekEndSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: type)
                return (true, startDate, endDate)
            }
        }

        return (matches: false, startDate: nil, endDate: nil)
    } // fileprivate func matchOneWeek(date: Date, calendar: ASACalendar, locationData: ASALocation, tweakedStartDateSpecification: ASADateSpecification, components: ASADateComponents, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchOneMonth(date: Date, calendar: ASACalendar, locationData: ASALocation, tweakedStartDateSpecification: ASADateSpecification, components: ASADateComponents, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let matches = self.matchOneMonth(date: date, calendar: calendar, locationData: locationData, dateSpecification: tweakedStartDateSpecification, components: components)
        if matches {
            let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
            let endDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: type)
            return (true, startDate, endDate)
        } else {
            return MATCH_FAILURE
        }
    } // func matchOneMonth(date: Date, calendar: ASACalendar, locationData: ASALocation, tweakedStartDateSpecification: ASADateSpecification, components: ASADateComponents) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchMultiMonth(startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification, date: Date, calendar: ASACalendar, locationData: ASALocation, components: ASADateComponents, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        if !matchOneYear(date: date, calendar: calendar, locationData: locationData, dateSpecification: startDateSpecification, components: components) {
            return MATCH_FAILURE
        }
        
        let dateEYM: Array<Int?>      = components.EYM
        let startDateEYM: Array<Int?> = startDateSpecification.EYM
        let endDateEYM: Array<Int?>   = endDateSpecification.EYM
        let within: Bool = dateEYM.isWithin(start: startDateEYM, end: endDateEYM)
        
        if !within {
            return MATCH_FAILURE
        }
        
        let (filledInStartDateEYM, filledInEndDateEYM) = dateEYM.fillInFor(start: startDateEYM, end: endDateEYM)
        
        let tweakedStartDateSpecification = startDateSpecification.fillIn(EYM: filledInStartDateEYM)
        
        let tweakedEndDateSpecification = endDateSpecification.fillIn(EYM: filledInEndDateEYM)
        
        let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
        let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: type)
        return (true, startDate, endDate)
    } // func matchMultiMonth(startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification, date: Date, calendar: ASACalendar, locationData: ASALocation, components: ASADateComponents) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    func matchEasterEvent(date:  Date, calendar:  ASACalendar, startDateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date, dateMJD: Int) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        var forGregorianCalendar: Bool
        switch calendar.calendarCode {
        case .Gregorian:
            forGregorianCalendar = true
            
        case .Julian:
            forGregorianCalendar = false
            
        default:
            return MATCH_FAILURE // Calculating the date of Easter is currently irrelevant for other calendars
        } // switch calendar.calendarCode
        
        guard let componentsYear = components.year else {
            return MATCH_FAILURE
        }
        let (EasterMonth, EasterDay) = calculateEaster(nYear: componentsYear, GregorianCalendar: forGregorianCalendar)
        guard let componentsMonth = components.month else {
            return MATCH_FAILURE
        }
        guard let componentsDay = components.day else {
            return MATCH_FAILURE
        }
        
        let offsetDays = startDateSpecification.offsetDays ?? 0
        if offsetDays == 0 {
            if componentsMonth == EasterMonth && componentsDay == EasterDay {
                return (true, startOfDay, startOfNextDay)
            } else {
                return MATCH_FAILURE
            }
        }
        
        // Nonzero offset from Easter events
        let locationData = components.locationData
        let timeZone: TimeZone = locationData.timeZone
        
        let EasterDateComponents = ASADateComponents(calendar: calendar, locationData: locationData, era: components.era, year: components.year, yearForWeekOfYear: nil, quarter: nil, month: EasterMonth, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: EasterDay)
        let EasterDate = EasterDateComponents.date
        let EasterMJD = EasterDate!.localModifiedJulianDay(timeZone: timeZone)
        let EasterEventMJD = EasterMJD + offsetDays
        
        if dateMJD == EasterEventMJD {
            return (true, startOfDay, startOfNextDay)
        } else {
            return MATCH_FAILURE
        }
    } // func matchEasterEvent(date:  Date, calendar:  ASACalendar, startDateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchIslamicPrayerTime(tweakedStartDateSpecification: ASADateSpecification, date: Date, locationData: ASALocation) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        var event: ASAIslamicPrayerTimeEvent
        switch tweakedStartDateSpecification.pointEventType {
        case .Fajr:
            event = .Fajr
            
        case .Dhuhr:
            event = .Dhuhr
            
        case .Asr:
            event = .Asr
            
        case .Maghrib:
            event = .Maghrib
            
        case .Isha:
            event = .Isha
            
        default:
            return MATCH_FAILURE
        } // switch tweakedStartDateSpecification.pointEventType
        
        let latitude: CLLocationDegrees = locationData.location.coordinate.latitude
        let longitude: CLLocationDegrees = locationData.location.coordinate.longitude
        let calcMethod: ASACalculationMethod = tweakedStartDateSpecification.calculationMethod ?? .Jafari
        let asrJuristic: ASAJuristicMethodForAsr = tweakedStartDateSpecification.asrJuristicMethod ?? .Shafii
        let dhuhrMinutes: Double = tweakedStartDateSpecification.dhuhrMinutes ?? 0.0
        let adjustHighLats: ASAAdjustingMethodForHigherLatitudes = tweakedStartDateSpecification.adjustingMethodForHigherLatitudes ?? .midnight
        let events = date.prayerTimesSunsetTransition(latitude: latitude, longitude: longitude, calcMethod: calcMethod, asrJuristic: asrJuristic, dhuhrMinutes: dhuhrMinutes, adjustHighLats: adjustHighLats, events: [event])
        let startDate = events![event]
        return (true, startDate, startDate)
    } // func matchIslamicPrayerTime(_ tweakedStartDateSpecification: ASADateSpecification, _ date: Date, _ locationData: ASALocation) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func dayForFullWeek(calendar: any ASACalendar, locationData: ASALocation, dateEYMD: [Int?], descriptionMonth: Int, descriptionWeekDay: Int?, descriptionFullWeek: Int?, components: ASADateComponents, daysPerWeek: Int, descriptionFirstDayOfWeek: Int) -> Int {
        let newComponents = ASADateComponents(calendar: calendar, locationData: locationData, era: dateEYMD[0], year: dateEYMD[1], month: descriptionMonth, day: 1)
        let newDate = newComponents.date
        let numberOfDaysInMonth = calendar.daysInMonth(for: newDate!) ?? 1
        let day = dayGiven(weekdayOfFullWeek: descriptionWeekDay ?? 0, fullWeek: descriptionFullWeek!, day: components.day ?? 0, weekday: components.weekday ?? 0, daysPerWeek: daysPerWeek, monthLength: numberOfDaysInMonth, firstDayOfWeek: descriptionFirstDayOfWeek)
        return day
    }
    
    func matchMultiDay(components: ASADateComponents, startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification?) -> (matches: Bool, startDateSpecification: ASADateSpecification?, endDateSpecification: ASADateSpecification?) {
        // TODO:  Could use improvement to support month/day of week/occurrence of weekday events
        
        let calendar = components.calendar
//        let locationData = components.locationData
                
        let NO_MATCH: (matches: Bool, startDateSpecification: ASADateSpecification?, endDateSpecification: ASADateSpecification?) = (false, nil, nil)
        
        // Elimination based on era and year
        let dateEY: Array<Int?>      = components.EY
        let startDateEY: Array<Int?> = startDateSpecification.EY
        let endDateEY: Array<Int?>   = endDateSpecification?.EY ?? startDateEY
        let withinEY: Bool               = dateEY.isWithin(start: startDateEY, end: endDateEY)
        if !withinEY {
            return NO_MATCH
        }
        
        // Elimination based on month
        let startMonth        = startDateSpecification.month ?? -1
        let startThroughMonth = startDateSpecification.throughMonth
        
        let endMonth          = endDateSpecification?.month
        let endThroughMonth   = endDateSpecification?.throughMonth

        let componentsMonth = components.month ?? 0
        if componentsMonth < startMonth || (endThroughMonth ?? endMonth ?? 1000000) < componentsMonth {
            return NO_MATCH
        }
        
        let dateEYMD: Array<Int?>      = components.EYMD
        var startDateEYMD: Array<Int?> = startDateSpecification.EYMD
        var endDateEYMD: Array<Int?>   = endDateSpecification?.EYMD ?? startDateEYMD

        // NOTE:  Month/day of week/occurrence of weekday events go awry here
//        guard let startDay   = startDateSpecification.day else { return NO_MATCH }
        let startDay            = startDateSpecification.day
        let startThroughDay     = startDateSpecification.throughDay
        let startWeekday        = startDateSpecification.weekdays?[0].rawValue
        
        let endDay            = (endDateSpecification?.day) ?? startDay
        let endThroughDay     = endDateSpecification?.throughDay
        let endWeekday        = endDateSpecification?.weekdays?[0].rawValue
        
        lazy var daysPerWeek = {
            if calendar is ASACalendarSupportingWeeks {
                return (calendar as! ASACalendarSupportingWeeks).daysPerWeek
            }
            
            return 1
        }()
        
        if startDateEYMD[0] == nil {
            startDateEYMD[0] = components.era
        }
        if startDateEYMD[1] == nil {
            startDateEYMD[1] = components.year
        }
        if endDateEYMD[0] == nil {
            endDateEYMD[0] = components.era
        }
        if endDateEYMD[1] == nil {
            endDateEYMD[1] = components.year
        }
        
        if startThroughDay != nil {
            assert(startWeekday != nil)
            let (month, day) = rangedMonthAndDayForWeekday(components: components, daysPerWeek: daysPerWeek, era: startDateEYMD[0], year: startDateEYMD[1], descriptionMonth: startMonth, descriptionThroughMonth: startThroughMonth, descriptionDay: startDay!, descriptionThroughDay: startThroughDay!, descriptionWeekday: startWeekday!)
            guard day != nil else { return NO_MATCH  }
            startDateEYMD[2] = month
            startDateEYMD[3] = day
        }
                
        let durationDays = startDateSpecification.durationDays
        if durationDays != nil {
            endDateEYMD[3] = startDateEYMD[3]! + durationDays! - 1
        } else if endThroughDay != nil {
            assert(endWeekday != nil)
            assert(endMonth != nil)
            let (month, day) = rangedMonthAndDayForWeekday(components: components, daysPerWeek: daysPerWeek, era: endDateEYMD[0], year: endDateEYMD[1], descriptionMonth: endMonth!, descriptionThroughMonth: endThroughMonth, descriptionDay: endDay!, descriptionThroughDay: endThroughDay!, descriptionWeekday: endWeekday!)
            guard day != nil else { return NO_MATCH  }
            endDateEYMD[2] = month
            endDateEYMD[3] = day
        }

//        let startDateEYMD: Array<Int?> = startDateSpecification.EYMD(componentsDay: components.day ?? 0, componentsWeekday: components.weekday ?? 0, calendar: calendar, locationData: locationData)
//        let endDateEYMD: Array<Int?>   = endDateSpecification!.EYMD(componentsDay: components.day ?? 0, componentsWeekday: components.weekday ?? 0, calendar: calendar, locationData: locationData)
        let within: Bool               = dateEYMD.isWithin(start: startDateEYMD, end: endDateEYMD)
        
        if !within {
            return NO_MATCH
        }
        
        let (filledInStartDateEYMD, filledInEndDateEYMD) = dateEYMD.fillInFor(start: startDateEYMD, end: endDateEYMD)
        
        let filledInStartDateSpecification = startDateSpecification.fillIn(EYMD: filledInStartDateEYMD)
        
        let filledInEndDateSpecification = (endDateSpecification ?? startDateSpecification).fillIn(EYMD: filledInEndDateEYMD)
        
        //        assert(filledInStartDateSpecification != nil)
        //        assert(filledInEndDateSpecification != nil)
        return (true, filledInStartDateSpecification, filledInEndDateSpecification)
    } // func matchMultiDay(components: ASADateComponents, startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification?) -> (matches: Bool, startDateSpecification: ASADateSpecification?, endDateSpecification: ASADateSpecification?)
    
    fileprivate func matchMultiDay(components: ASADateComponents, startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification?, calendar: ASACalendar, date: Date, locationData: ASALocation, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let (matches, tweakedStartDateSpecification, tweakedEndDateSpecification) = matchMultiDay(components: components, startDateSpecification: startDateSpecification, endDateSpecification: endDateSpecification)
        if !matches {
            return MATCH_FAILURE
        }
        
        let eventStartDate = tweakedStartDateSpecification!.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
        if eventStartDate == nil {
            return MATCH_FAILURE
        }
        let eventEndDate = tweakedEndDateSpecification!.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: type)
        if eventEndDate == nil {
            return MATCH_FAILURE
        }
        guard let tweakedStartDateSpecification = tweakedStartDateSpecification else {
            return MATCH_FAILURE
        }
        guard let tweakedEndDateSpecification = tweakedEndDateSpecification else {
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
    } // func matchMultiDay(components: ASADateComponents, startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification?, calendar: ASACalendar, date: Date, locationData: ASALocation) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchPoint(date: Date, calendar: ASACalendar, locationData: ASALocation, eventSpecification: ASAEventSpecification, components: ASADateComponents, startOfDay: Date, startOfNextDay: Date, tweakedDateSpecification: ASADateSpecification, previousSunset: Date, nightHourLength: TimeInterval, sunrise: Date, hourLength: TimeInterval, previousOtherDusk: Date, otherNightHourLength: TimeInterval, otherDawn: Date, otherHourLength: TimeInterval, dateMJD: Int, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let dateSpecification = eventSpecification.startDateSpecification
        
        let genericMatch: (matches: Bool, startDate: Date?, endDate: Date?) = matchOneDayOrLess(date: date, calendar: calendar, locationData: locationData, dateSpecification: dateSpecification, components: components, startOfDay: startOfDay, startOfNextDay: startOfNextDay, dateMJD: dateMJD)
        if !genericMatch.matches {
            return MATCH_FAILURE
        }
        
        switch dateSpecification.pointEventType ?? .generic {
        case .generic:
            if dateSpecification.hour != nil {
                var filledInDateComponents = components
                filledInDateComponents.hour = dateSpecification.hour
                filledInDateComponents.minute = dateSpecification.minute
                filledInDateComponents.second = dateSpecification.second
                filledInDateComponents.nanosecond = dateSpecification.nanosecond
                let date = calendar.date(dateComponents: filledInDateComponents)
                return (true, date, date)
            }
            return genericMatch
            
        case .twilight:
            guard let degreesBelowHorizon = dateSpecification.degreesBelowHorizon else { return MATCH_FAILURE }
            guard let rising = dateSpecification.rising else { return MATCH_FAILURE }
            let offset = dateSpecification.offset ?? 0.0
            return matchTwilight(startOfDay: startOfDay, startOfNextDay: startOfNextDay, degreesBelowHorizon: degreesBelowHorizon, rising: rising, offset: offset, locationData: locationData)
            
        case .Isha, .Maghrib, .Asr, .Dhuhr, .Fajr:
            return matchIslamicPrayerTime(tweakedStartDateSpecification: tweakedDateSpecification, date: date, locationData: locationData)
            
        case .rise, .set:
            guard let body = dateSpecification.body else { return MATCH_FAILURE }
            return matchRiseOrSet(type: dateSpecification.pointEventType!, startOfDay: startOfDay, startOfNextDay: startOfNextDay, body: body, locationData: locationData)
        case .solarTimeSunriseSunset, .solarTimeDawn72MinutesDusk72Minutes:
            let (startDate, endDate) = solarStartAndEndDates(eventSpecification: eventSpecification, appropriateCalendar: calendar, date: date, locationData: locationData, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay, type: type)
            return (true, startDate!, endDate!)
        } // switch dateSpecification.pointEventType ?? .generic
    } // func matchPoint(date: Date, calendar: ASACalendar, locationData: ASALocation, dateSpecification: ASADateSpecification, components: ASADateComponents, startOfDay: Date, startOfNextDay: Date) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func matchSpan(components: ASADateComponents, startDateSpecification: ASADateSpecification, endDateSpecification: ASADateSpecification?, calendar: ASACalendar, date: Date, type: ASAEventSpecificationType) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let (matches, filledInStartDateSpecification, filledInEndDateSpecification) = matchMultiDay(components: components, startDateSpecification: startDateSpecification, endDateSpecification: endDateSpecification)
        if !matches {
            return MATCH_FAILURE
        }
        assert(filledInStartDateSpecification != nil)
        assert(filledInEndDateSpecification != nil)
        
        let startDate = filledInStartDateSpecification!.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
        if startDate == nil {
            debugPrint(#file, #function, "Invalid start date specification:", filledInStartDateSpecification as Any)
            return MATCH_FAILURE
        }
        var endDate = filledInEndDateSpecification!.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
        
        let startDateComponents = calendar.dateComponents([.weekday], from: startDate!, locationData: components.locationData)
        let endDateComponents = calendar.dateComponents([.weekday], from: endDate!, locationData: components.locationData)
        let matchingStartDateWeekDay = startDateComponents.weekday!.matches(weekdays: startDateSpecification.weekdays)
        let matchingEndDateWeekDay = endDateComponents.weekday!.matches(weekdays: endDateSpecification!.weekdays)
        if !matchingStartDateWeekDay {
            return MATCH_FAILURE
        }
        
        if !matchingEndDateWeekDay {
            let locationData = components.locationData
            let newRawEndDate = calendar.startOfNextDay(date: startDate!, locationData: locationData)
            let newRawEndDateComponents = calendar.dateComponents([.era, .year, .month, .day], from: newRawEndDate, locationData: locationData)
            var newFilledInEndDateSpecification = endDateSpecification
            newFilledInEndDateSpecification?.era = newRawEndDateComponents.era
            newFilledInEndDateSpecification?.year = newRawEndDateComponents.year
            newFilledInEndDateSpecification?.month = newRawEndDateComponents.month
            newFilledInEndDateSpecification?.day = newRawEndDateComponents.day
            endDate = newFilledInEndDateSpecification!.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: type)
        }
        if endDate == nil {
            return MATCH_FAILURE
        }
        return (true, startDate, endDate)
    }
    
    // NOTE:  May need updating to support new date specification types!
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, eventSpecification: ASAEventSpecification, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date, previousSunset: Date, nightHourLength: TimeInterval, sunrise: Date, hourLength: TimeInterval, previousOtherDusk: Date, otherNightHourLength: TimeInterval, otherDawn: Date, otherHourLength: TimeInterval, type: ASAEventSpecificationType) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let startDateSpecification = eventSpecification.startDateSpecification
        let endDateSpecification = eventSpecification.endDateSpecification
        let firstDateSpecification = eventSpecification.firstDateSpecification
        let tweakedStartDateSpecification = self.tweak(dateSpecification: startDateSpecification, date: date, calendar: calendar, templateDateComponents: components)
        let timeZone = locationData.timeZone
        let dateMJD = date.localModifiedJulianDay(timeZone: timeZone)
        
        // Check whether the event is before the first occurrence
        if firstDateSpecification != nil {
//            if eventSpecification.inherits == "Canadian Environment Week" {
//                debugPrint("Foo date \(date)")
//                debugPrint("Foo first \(firstDateSpecification!.EYMD) self \(tweakedStartDateSpecification.EYMD)")
//            }
            let start = tweakedStartDateSpecification.EYMD
            let first = firstDateSpecification!.EYMD
            
            if start.isBefore(first: first) {
//                debugPrint("Foo match failure first")
                return MATCH_FAILURE
            }
        }
        
        // Check whether the event is after the last occurrence
        let lastDateSpecification = eventSpecification.lastDateSpecification
        if lastDateSpecification != nil {
//            if eventSpecification.inherits == "Canadian Environment Week" {
//                debugPrint("Foo date \(date)")
//                debugPrint("Foo last \(lastDateSpecification!.EYMD) self \(tweakedStartDateSpecification.EYMD)")
//            }
            let start = tweakedStartDateSpecification.EYMD
            let last = lastDateSpecification!.EYMD
            
            if start.isAfter(last: last) {
//                debugPrint("Foo match failure last")
                return MATCH_FAILURE
            }
        }
        
        let dateSpecificationType: ASAEventSpecificationType = eventSpecification.type
        
        switch dateSpecificationType {
        case .multiYear:
            // Multi-year events
            return matchMultiYear(endDateSpecification: endDateSpecification, components: components, startDateSpecification: startDateSpecification, calendar: calendar, date: date, type: type)
            
        case .oneYear:
            // One-year events
            assert(endDateSpecification == nil)
            return matchOneYear(date: date, calendar: calendar, locationData: locationData, tweakedStartDateSpecification: tweakedStartDateSpecification, components: components, type: type)
            
        case .multiMonth:
            // Multi-month events
            guard let nonOptionalEndDateSpecification = endDateSpecification
            else {
                return MATCH_FAILURE
            }
            return matchMultiMonth(startDateSpecification: startDateSpecification, endDateSpecification: nonOptionalEndDateSpecification, date: date, calendar: calendar, locationData: locationData, components: components, type: type)
            
        case .oneMonth:
            // One-month events
            assert(endDateSpecification == nil)
            return matchOneMonth(date: date, calendar: calendar, locationData: locationData, tweakedStartDateSpecification: tweakedStartDateSpecification, components: components, type: type)
            
        case .oneWeek:
            // One-week events
            assert(endDateSpecification == nil)
            return matchOneWeek(date: date, calendar: calendar, locationData: locationData, tweakedStartDateSpecification: tweakedStartDateSpecification, components: components, type: type)
            
        case .multiDay:
            // Multi-day events
            
            // ⬇️ Use to debug multi-day events
            // As of this writing, weeks longer than one week are not shown by default.  In some cases, that is the problem.
//            if eventSpecification.titles?["en"] == "March Madness" {
//                debugPrint("Foo")
//            }
            
            let matchesMultiDay: (matches: Bool, startDate: Date?, endDate: Date?) = matchMultiDay(components: components, startDateSpecification: startDateSpecification, endDateSpecification: endDateSpecification, calendar: calendar, date: date, locationData: locationData, type: type)
            return matchesMultiDay
            
        case .oneDay:
            // One-day events
            let matchesDay = matchOneDayOrLess(date: date, calendar: calendar, locationData: locationData, dateSpecification: tweakedStartDateSpecification, components: components, startOfDay: startOfDay, startOfNextDay: startOfNextDay, dateMJD: dateMJD)
            if !matchesDay.matches {
                return MATCH_FAILURE
            }
            
            // Weird bug-squashing condition
            if startOfNextDay.timeIntervalSince(startOfDay) < 23.0 * Date.SECONDS_PER_HOUR {
                return (false, nil, nil)
            }
            
            return (true, startOfDay, startOfNextDay)
            
        case .point:
            // Point events
            let matchesDay = matchPoint(date: date, calendar: calendar, locationData: locationData, eventSpecification: eventSpecification, components: components, startOfDay: startOfDay, startOfNextDay: startOfNextDay, tweakedDateSpecification: tweakedStartDateSpecification, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, dateMJD: dateMJD, type: type)
            if !matchesDay.matches {
                return MATCH_FAILURE
            } else {
                return (true, matchesDay.startDate!, matchesDay.endDate!)
            }
            
        case .span:
//            if eventSpecification.inherits == "Hour of the Sun" && eventSpecification.startDateSpecification.solarHours == 3.0 && eventSpecification.startDateSpecification.dayHalf == .night {
//                debugPrint("Foo")
//            }
            return matchSpan(components: components, startDateSpecification: startDateSpecification, endDateSpecification: endDateSpecification, calendar: calendar, date: date, type: type)
        } // switch startDateSpecificationType
    } // func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date, firstDateSpecification: ASADateSpecification?) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfYear != nil {
            let numberOfDaysInYear = calendar.daysInYear(for: date)!
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
            let numberOfDaysInMonth = calendar.daysInMonth(for: date)!
          if !numberOfDaysInMonth.matches(values: dateSpecification.lengthsOfMonth) {
                return false
            }
        }
        
        return true
    } // func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func matchOneYear(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        let supportsEra: Bool = calendar.supports(calendarComponent: .era)
        if supportsEra {
            if !(components.era?.matches(value: dateSpecification.era) ?? false) {
                return false
            }
        }
        
        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
        if supportsYear {
            if !(components.year?.matches(value: dateSpecification.year) ?? false) {
                return false
            }
            
            if !self.matchYearSupplemental(date: date, components: components, dateSpecification: dateSpecification, calendar: calendar) {
                return false
            }
        }
        
        return true
    } // func matchOneYear(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool
    
    func matchOneMonth(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        if !matchOneYear(date: date, calendar: calendar, locationData: locationData, dateSpecification: dateSpecification, components: components) {
            return false
        }
        
        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
        if supportsMonth {
            if !(components.month?.matches(value: dateSpecification.month) ?? false) {
                return false
            }
            
            if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: dateSpecification, calendar: calendar) {
                return false
            }
        }
        
        return true
    } // func matchOneMonth(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool
    
    func matchOneDayOrLess(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay: Date, startOfNextDay: Date, dateMJD: Int) -> (matches: Bool, startDate: Date?, endDate: Date?) {
        let NO_MATCH: (matches: Bool, startDate: Date?, endDate: Date?) = (false, nil, nil)
        var start = startOfDay
        var end = startOfNextDay
        
        let offsetDays = dateSpecification.offsetDays ?? 0
        if offsetDays != 0 && dateSpecification.Easter == nil && dateSpecification.equinoxOrSolstice == nil {
            let specifiedEra = dateSpecification.era ?? components.era
            let specifiedYear = dateSpecification.year ?? components.year
            let specifiedMonth = dateSpecification.month ?? components.month
            let specifiedDay = dateSpecification.day ?? components.day
            let specifiedComponents = ASADateComponents(calendar: calendar, locationData: locationData, era: specifiedEra, year: specifiedYear, month: specifiedMonth, day: specifiedDay)
            let unoffsetDate = specifiedComponents.date
            let unoffsetMJD = unoffsetDate!.localModifiedJulianDay(timeZone: locationData.timeZone)
            let offsetMJD = unoffsetMJD + offsetDays
            if dateMJD != offsetMJD {
                return NO_MATCH
            }
        } else {
            // offsetDays == 0
            if dateSpecification.throughMonth == nil {
                let matchesMonth: Bool = matchOneMonth(date: date, calendar: calendar, locationData: locationData, dateSpecification: dateSpecification, components: components)
                if !matchesMonth {
                    return NO_MATCH
                }
            }
            
            let supportsDay: Bool = calendar.supports(calendarComponent: .day)
            if supportsDay {
                // TODO:  Probably should add in day of full week of month support
                let dateSpecificationDay = dateSpecification.day
                if dateSpecificationDay != nil {
                    let componentsDay = components.day!
                    
                    // Check specified day of month
                    
                    let dateSpecificationThroughDay = dateSpecification.throughDay
                    if dateSpecificationThroughDay == nil {
                        if !(componentsDay.matches(value: dateSpecificationDay!) ) {
                            return NO_MATCH
                        }
                    } else {
                        // Check specified day of month in range that crosses month boundary
                        let dateSpecificationMonth = dateSpecification.month
                        let dateSpecificationThroughMonth = dateSpecification.throughMonth
                        let componentsMonth = components.month
                        if componentsMonth != nil && dateSpecificationMonth != nil && dateSpecificationThroughMonth != nil {
                            let startMD = [dateSpecificationMonth, dateSpecificationDay]
                            let endMD = [dateSpecificationThroughMonth, dateSpecificationThroughDay]
                            let componentsMD = [componentsMonth, componentsDay]
                            if !componentsMD.isWithin(start: startMD, end: endMD) {
                                return NO_MATCH
                            }
                        } else {
                            // No crossing month boundary
                            if !(dateSpecificationDay! <=  componentsDay && componentsDay <= dateSpecificationThroughDay!) {
                                return NO_MATCH
                            }
                        }
                    }
                }
            }
        }
        
        let supportsWeekday: Bool = calendar.supports(calendarComponent: .weekday)
        if supportsWeekday {
            if !(components.weekday?.matches(weekdays: dateSpecification.weekdays) ?? false) {
                return NO_MATCH
            }
        }
        
        if dateSpecification.weekdayRecurrence != nil && dateSpecification.weekdays != nil {
            let daysInMonth = calendar.daysInMonth(for: date) ?? 1

            if calendar is ASACalendarSupportingWeeks {
                let calendarSupportingWeeks = calendar as! ASACalendarSupportingWeeks
                let daysPerWeek = calendarSupportingWeeks.daysPerWeek
                
                if !(components.day!.matches(recurrence: dateSpecification.weekdayRecurrence!, lengthOfWeek: daysPerWeek, lengthOfMonth: daysInMonth)) {
                    return NO_MATCH
                }
            }
        }
        
        let Easter = dateSpecification.Easter
        if Easter ?? .none != .none {
            let matchesAndStartAndEndDates = matchEasterEvent(date: date, calendar: calendar, startDateSpecification: dateSpecification, components: components, startOfDay: startOfDay, startOfNextDay: startOfNextDay, dateMJD: dateMJD)
            if !matchesAndStartAndEndDates.matches {
                return NO_MATCH
            }
        }
        
        let equinoxOrSolstice = dateSpecification.equinoxOrSolstice
        if equinoxOrSolstice != nil && equinoxOrSolstice! != .none {
            let matchesAndStartAndEndDates = matchEquinoxOrSolstice(type: equinoxOrSolstice!, startOfDay: startOfDay, startOfNextDay: startOfNextDay, offsetDays: dateSpecification.offsetDays ?? 0)
            if !matchesAndStartAndEndDates.matches {
                return NO_MATCH
            } else {
                start = matchesAndStartAndEndDates.startDate!
                end = matchesAndStartAndEndDates.endDate!
            }
        }
        
        let timeChange = dateSpecification.timeChange
        if timeChange != nil && timeChange! != .none {
            let matchesAndStartAndEndDates = matchTimeChange(timeZone: locationData.timeZone, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
            if !matchesAndStartAndEndDates.matches {
                return NO_MATCH
            } else {
                start = matchesAndStartAndEndDates.startDate!
                end = matchesAndStartAndEndDates.endDate!
            }
        }
        
        let MoonPhase = dateSpecification.MoonPhase
        if MoonPhase != nil && MoonPhase! != .none {
            let matchesAndStartAndEndDates = matchMoonPhase(type: MoonPhase!, startOfDay: startOfDay, startOfNextDay: startOfNextDay, dateSpecification: dateSpecification, components: components)
            if !matchesAndStartAndEndDates.matches {
                return NO_MATCH
            } else {
                start = matchesAndStartAndEndDates.startDate!
                end = matchesAndStartAndEndDates.endDate!
            }
        }
        
        return (true, start, end)
    } // func matchOneDayOrLess(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents, startOfDay: Date, startOfNextDay: Date) -> (matches: Bool, startDate: Date?, endDate: Date?)
    
    fileprivate func solarStartAndEndDates(eventSpecification: ASAEventSpecification, appropriateCalendar: ASACalendar, date: Date, locationData: ASALocation, previousSunset: Date, nightHourLength: TimeInterval, sunrise: Date, hourLength: TimeInterval, previousOtherDusk: Date, otherNightHourLength: TimeInterval, otherDawn: Date, otherHourLength: TimeInterval, startOfDay: Date, startOfNextDay: Date, type: ASAEventSpecificationType) -> (startDate: Date?, endDate: Date?) {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
        var startDate: Date?
        var endDate: Date?
        
        if eventSpecification.isAllDay {
            startDate = appropriateCalendar.startOfDay(for: date, locationData: locationData)
            endDate   = appropriateCalendar.startOfNextDay(date: date, locationData: locationData)
        } else {
            startDate = eventSpecification.startDateSpecification.date(date: date, location: location, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay, type: type)
            if eventSpecification.endDateSpecification == nil {
                endDate = startDate
            } else {
                endDate = eventSpecification.endDateSpecification!.date(date: date, location: location, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay, type: type)
            }
        }
        return (startDate, endDate)
    }
    
    func fileEmoji() -> String? {
        return self.eventsFile?.symbol
    } // func fileEmoji() -> String?
    
    fileprivate func processEventSpecification(calendar: ASACalendar, eventSpecification: ASAEventSpecification, otherCalendars: [ASACalendarCode : ASACalendar], components: ASADateComponents, date: Date, locationData: ASALocation, startOfDay: Date, startOfNextDay: Date, previousSunset: Date, nightHourLength: TimeInterval, sunrise: Date, hourLength: TimeInterval, previousOtherDusk: Date, otherNightHourLength: TimeInterval, otherDawn: Date, otherHourLength: TimeInterval, regionCode: String?, location: CLLocation, timeZone: TimeZone, requestedLocaleIdentifier: String, eventCalendarName: String, calendarTitle: String, clock: ASAClock, eventsFileTemplates: Array<ASAEventSpecification>?) -> ASAEvent? {
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
                
        let (matchesDateSpecifications, returnedStartDate, returnedEndDate) = self.match(date: date, calendar: appropriateCalendar, locationData: locationData, eventSpecification: eventSpecification, components: appropriateComponents, startOfDay: startOfDay, startOfNextDay: startOfNextDay, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, type: eventSpecification.type)
        if !matchesDateSpecifications {
            return nil
        }
        
        let matchesRegionCode: Bool = eventSpecification.match(regionCode: regionCode, latitude: location.coordinate.latitude)
        if !matchesRegionCode {
            return nil
        }
        
        let filledInEventSpecification = eventSpecification.filledIn(eventsFileTemplates: eventsFileTemplates)
        
        let eventsFileDefaultLocale = eventsFile!.defaultLocale

        var title: String
        if eventSpecification.type == .point && eventSpecification.startDateSpecification.timeChange == .timeChange {
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
            let NO_TITLE = ""
            title = filledInEventSpecification.eventTitle(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocale) ?? NO_TITLE
        }
        let color = self.color
        let locationString: String? = eventSpecification.eventLocation(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocale)
        let url: URL? = {
            var result = filledInEventSpecification.eventURL(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocale)
            if result == nil {
                result = eventsFile?.urls?[requestedLocaleIdentifier]
            }
            if result == nil {
                result = eventsFile?.urls?[eventsFileDefaultLocale]
            }
            return result
        }()
        
        let notes: String? = filledInEventSpecification.eventNotes(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocale)
        
        let emoji = filledInEventSpecification.emoji
        
        var newEvent = ASAEvent(title:  title, location: locationString, startDate: returnedStartDate, endDate: returnedEndDate, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, url: url, notes: notes, color: color, calendarTitleWithLocation: eventCalendarName, calendarTitle: calendarTitle, calendarCode: appropriateCalendar.calendarCode, locationData:  locationData, recurrenceRules: eventSpecification.recurrenceRules, regionCodes: eventSpecification.regionCodes, excludeRegionCodes: eventSpecification.excludeRegionCodes, emoji: emoji, fileEmoji: fileEmoji(), type: eventSpecification.type)
        
        let eventIsTodayOnly = newEvent.isOnlyForRange(rangeStart: startOfDay, rangeEnd: startOfNextDay)
        let (startDateString, endDateString) = clock.startAndEndDateStrings(event: newEvent, eventIsTodayOnly: eventIsTodayOnly, location: locationData)

        newEvent.startDateString = startDateString
        newEvent.endDateString = endDateString
        
        if clock.eventsShouldShowSecondaryDates {
            let (secondaryStartDateString, secondaryEndDateString) =  ASAEventCalendar.secondaryClock.startAndEndDateStrings(event: newEvent, eventIsTodayOnly: eventIsTodayOnly, location: locationData)
            newEvent.secondaryStartDateString = secondaryStartDateString
            newEvent.secondaryEndDateString = secondaryEndDateString
        }

        return newEvent
    }
    
    func events(date:  Date, locationData:  ASALocation, eventCalendarName: String, calendarTitle:  String, calendar:  ASACalendar, otherCalendars: Dictionary<ASACalendarCode, ASACalendar>, regionCode:  String?, requestedLocaleIdentifier:  String, startOfDay:  Date, startOfNextDay:  Date, clock: ASAClock) -> (dateEvents: Array<ASAEvent>, timeEvents: Array<ASAEvent>) {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
        var previousSunset                     = date
        var nightHourLength: TimeInterval      = 0
        var sunrise                            = date
        var hourLength: TimeInterval           = 0
        var previousOtherDusk                  = date
        var otherNightHourLength: TimeInterval = 0
        var otherDawn                          = date
        var otherHourLength: TimeInterval      = 0
        
        if calendar.calendarCode.isSunsetTransitionCalendar {
            let previousDate = date.oneDayBefore
            let previousEvents = previousDate.solarEvents(location: location, events: [.sunset, .dusk72Minutes], timeZone:  timeZone)
            let previousSunsetDoubleOptional = previousEvents[.sunset]
            if previousSunsetDoubleOptional == nil {
                return ([], [])
            }
            let previousSunsetOptional = previousSunsetDoubleOptional!
            if previousSunsetOptional == nil {
                return ([], [])
            }
            previousSunset = previousSunsetOptional! // שקיעה
            previousOtherDusk = previousEvents[.dusk72Minutes]!!
            
            let solarEvents = date.solarEvents(location: location, events: [.sunrise, .sunset, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
            
            // According to the גר״א
            sunrise = solarEvents[.sunrise]!! // נץ
            let sunset:  Date = solarEvents[.sunset]!! // שקיעה
            
            let HOURS_PER_DAY_HALF = 12.0
            
            let nightLength = sunrise.timeIntervalSince(previousSunset)
            nightHourLength = nightLength / HOURS_PER_DAY_HALF
            
            let dayLength = sunset.timeIntervalSince(sunrise)
            hourLength = dayLength / HOURS_PER_DAY_HALF
            
            // According to the מגן אברהם
            otherDawn = solarEvents[.dawn72Minutes]!! // עלות השחר
            let otherDusk = solarEvents[.dusk72Minutes]!! // צאת הכוכבים
            
            let otherNightLength = otherDawn.timeIntervalSince(previousOtherDusk)
            otherNightHourLength = otherNightLength / HOURS_PER_DAY_HALF
            
            let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
            otherHourLength = otherDayLength / HOURS_PER_DAY_HALF
        }
        
        var dateEvents:  Array<ASAEvent> = []
        var timeEvents:  Array<ASAEvent> = []
        
        let components = calendar.dateComponents([.era, .year, .month, .day, .weekday, .hour, .minute, .second, .nanosecond], from: date, locationData: locationData)
        
        for eventSpecification in self.eventsFile!.eventSpecifications {
            assert(previousSunset.oneDayAfter > date)
            
//            assert(startOfDay <= date)
//            assert(date < startOfNextDay)
            // TODO:  Assertion failure here!
            let newEvent = processEventSpecification(calendar: calendar, eventSpecification: eventSpecification, otherCalendars: otherCalendars, components: components, date: date, locationData: locationData, startOfDay: startOfDay, startOfNextDay: startOfNextDay, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, regionCode: regionCode, location: location, timeZone: timeZone, requestedLocaleIdentifier: requestedLocaleIdentifier, eventCalendarName: eventCalendarName, calendarTitle: calendarTitle, clock: clock, eventsFileTemplates: eventsFile!.templateSpecifications)
            
            if newEvent != nil {
                if (eventSpecification.titles != nil || eventSpecification.inherits != nil) {
                    if newEvent!.isAllDay {
                        dateEvents.append(newEvent!)
                    } else {
                        timeEvents.append(newEvent!)
                    }
                }
                
                let nonoverlappingSubEvents: [ASAEventSpecification]? = eventSpecification.nonoverlappingSubEvents
                if nonoverlappingSubEvents != nil {
                    for subEventSpecification in nonoverlappingSubEvents! {
                        let newEvent = processEventSpecification(calendar: calendar, eventSpecification: subEventSpecification, otherCalendars: otherCalendars, components: components, date: date, locationData: locationData, startOfDay: startOfDay, startOfNextDay: startOfNextDay, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, regionCode: regionCode, location: location, timeZone: timeZone, requestedLocaleIdentifier: requestedLocaleIdentifier, eventCalendarName: eventCalendarName, calendarTitle: calendarTitle, clock: clock, eventsFileTemplates: eventsFile!.templateSpecifications)

                        if newEvent != nil {
                            if newEvent!.isAllDay {
                                dateEvents.append(newEvent!)
                            } else {
                                timeEvents.append(newEvent!)
                            }

                            break
                        }
                    } // for subEventSpecification in nonoverlappingSubEvents!
                }
                
                let overlappingSubEvents: [ASAEventSpecification]? = eventSpecification.overlappingSubEvents
                if overlappingSubEvents != nil {
                    for subEventSpecification in overlappingSubEvents! {
                        let newEvent = processEventSpecification(calendar: calendar, eventSpecification: subEventSpecification, otherCalendars: otherCalendars, components: components, date: date, locationData: locationData, startOfDay: startOfDay, startOfNextDay: startOfNextDay, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, regionCode: regionCode, location: location, timeZone: timeZone, requestedLocaleIdentifier: requestedLocaleIdentifier, eventCalendarName: eventCalendarName, calendarTitle: calendarTitle, clock: clock, eventsFileTemplates: eventsFile!.templateSpecifications)

                        if newEvent != nil {
                            if newEvent!.isAllDay {
                                dateEvents.append(newEvent!)
                            } else {
                                timeEvents.append(newEvent!)
                            }
                        }
                    } // for subEventSpecification in overlappingSubEvents!
                }
            }
        } // for eventSpecification in self.eventsFile.eventSpecifications
        return (dateEvents, timeEvents)
    } // func events(date:  Date, locationData:  ASALocation, eventCalendarName: String, calendarTitle:  String, calendar:  ASACalendar, otherCalendars: Dictionary<ASACalendarCode, ASACalendar>, regionCode:  String?, requestedLocaleIdentifier:  String, startOfDay:  Date, startOfNextDay:  Date) -> (dateEvents: Array<ASAEvent>, timeEvents: Array<ASAEvent>)
    
    func eventCalendarNameWithPlaceName(locationData:  ASALocation, localeIdentifier:  String) -> String {
        let localizableTitle = self.eventCalendarNameWithoutPlaceName(localeIdentifier: localeIdentifier)
        let oneLineAddress = locationData.shortFormattedOneLineAddress
        return "\(NSLocalizedString(localizableTitle, comment: "")) • \(oneLineAddress)"
    } // func eventCalendarName(locationData:  ASALocation) -> String
    
    func autolocalizableRegionCode() -> String? {
        return self.eventsFile!.autolocalizableRegionCode()
    }
    
    func eventCalendarNameWithoutPlaceName(localeIdentifier:  String) -> String {
        if self.eventsFile == nil {
            return self.fileName
        }
        
        return self.eventsFile!.eventCalendarNameWithoutPlaceName(localeIdentifier: localeIdentifier)
    } // func eventCalendarNameWithoutPlaceName(localeIdentifier:  String) -> String
    
    static let secondaryClock = ASAClock.generic
} // class ASAEventCalendar


// MARK: -

struct ASABuiltInEventCalendarFileRecord {
    var fileName: String
    var emoji: String?
    var eventCalendarNameWithoutPlaceName: String
    var numberOfEventSpecifications: Int
    var color: SwiftUI.Color
}

class ASABuiltInEventCalendarFileData {
    var records: Array<ASABuiltInEventCalendarFileRecord> = []
}

extension ASAEventCalendar {
    fileprivate static var builtInEventCalendarFileNamesCache = NSCache<NSString, ASABuiltInEventCalendarFileData>()

    class func builtInEventCalendarFileRecords(calendarCode:  ASACalendarCode) -> ASABuiltInEventCalendarFileData {
        let temp = ASAEventCalendar.builtInEventCalendarFileNamesCache.object(forKey: NSString(string: calendarCode.rawValue))
        if temp != nil {
            return temp!
        }
        
        let mainBundle = Bundle.main
        let URLs = mainBundle.urls(forResourcesWithExtension: "json", subdirectory: nil)
        let rawFileNames: Array<String> = URLs!.map {
            $0.deletingPathExtension().lastPathComponent
        }
        
        var unsortedRecords: Array<ASABuiltInEventCalendarFileRecord> = []
        let localeIdentifier: String = Locale.current.identifier
        for fileName in rawFileNames {
            let (eventsFile, _) = ASAEventsFile.builtIn(fileName: fileName)
            if eventsFile != nil {
                if eventsFile!.calendarCode.matches(calendarCode) {
                    unsortedRecords.append(ASABuiltInEventCalendarFileRecord(fileName: fileName, emoji: eventsFile!.symbol, eventCalendarNameWithoutPlaceName: eventsFile!.eventCalendarNameWithoutPlaceName(localeIdentifier: localeIdentifier), numberOfEventSpecifications: eventsFile!.eventSpecifications.count, color: eventsFile!.calendarColor))
                }
            }
        }
        let records = unsortedRecords.sorted(by: {$0.eventCalendarNameWithoutPlaceName < $1.eventCalendarNameWithoutPlaceName})
        let result = ASABuiltInEventCalendarFileData()
        result.records = records
        
        ASAEventCalendar.builtInEventCalendarFileNamesCache.setObject(result, forKey: NSString(string: calendarCode.rawValue))
        
        return result
    } // static var builtInEventCalendarFileNames
} // extension ASAEventCalendar

extension Array where Element == ASAEvent {
    func containsDuplicate(of event: ASAEvent) -> Bool {
        let firstIndex = self.firstIndex(where: { $0.title == event.title && $0.location == event.location && $0.startDate == event.startDate && $0.calendarTitleWithLocation == event.calendarTitleWithLocation })
        // NOTE:  We do not check the end date, as the switch to daylight savings time can screw that up.
        return firstIndex != nil
    } // func containsDuplicate(of event: ASAEvent) -> Bool
} // extension Array where Element == ASAEventCompatible

