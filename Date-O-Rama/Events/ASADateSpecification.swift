//
//  ASADateSpecification.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 03/03/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import CoreLocation
import Foundation

struct ASADateSpecification:  Codable {
    var pointEventType: ASAPointEventType?
    
    var era: Int?
    
    /// Will be ignored if not relevant
    var year: Int?
    
    /// Will be ignored if not relevant
    var month: Int?
    
    var day: Int?
    
    var hour: Int?
    var minute: Int?
    var second: Int?
    var nanosecond: Int?
    
    var weekdays:  Array<ASAWeekday>?
    
    /// If non-nil, the number of the recurrence of the first weekday given in the month.  If negative, then -1 is the last recurrence, -2 is the next to last recurrence, etc.
    var weekdayRecurrence: Int?
    var lengthsOfMonth: Array<Int>?
    var lengthsOfYear: Array<Int>?
    var dayOfYear: Int?
    
    /// The number of the full week of the month
    var fullWeek: Int?
    
    /// The first day of the week.  By default, Sunday.
    var firstDayOfWeek: ASAWeekday?
    static let defaultFirstDayOfWeek = ASAWeekday.sunday

    var yearDivisor:  Int?
    
    /// Matches if year mod yearDivisor = yearRemainder
    var yearRemainder: Int?
    
    /// For date-specified and Easter-related events
    var offsetDays: Int?
    
    var throughDay: Int?
    var throughMonth: Int?
    var durationDays: Int?

    // For degrees below horizon events
    var degreesBelowHorizon: Double?
    var rising: Bool?
    var offset: TimeInterval?
    
    // For solar time events
    var solarHours: Double?
    var dayHalf: ASADayHalf?
    
    // For rise and set events
    var body: String?
    
    // For Islamic prayer times
    var calculationMethod: ASACalculationMethod?
    var asrJuristicMethod: ASAJuristicMethodForAsr?
    var adjustingMethodForHigherLatitudes: ASAAdjustingMethodForHigherLatitudes?
    var dhuhrMinutes: Double?
    
    // For Easter-related events
    var Easter: ASAEasterType?
    
    // For equinox and solstice events
    var equinoxOrSolstice:  ASAEquinoxOrSolsticeType?
    
    // For time change events
    var timeChange: ASATimeChangeType?
    
    // For Moon phase events
    var MoonPhase: ASAMoonPhaseType?
    
    enum CodingKeys: String, CodingKey {
        case pointEventType      = "ptType"
        case era
        case year                = "y"
        case month               = "mon"
        case day                 = "d"
        case hour                = "h"
        case minute              = "min"
        case second              = "s"
        case nanosecond          = "ns"
        case weekdays            = "wkd"
        case weekdayRecurrence   = "nth"
        case lengthsOfMonth      = "monLengths"
        case lengthsOfYear       = "yLengths"
        case dayOfYear           = "dOfY"
        case yearDivisor         = "yDiv"
        case yearRemainder       = "yRem"
        case degreesBelowHorizon = "degBelowHorizon"
        case rising
        case offset
        case solarHours          = "zsuH"
        case dayHalf             = "dHalf"
        case body
        case calculationMethod   = "calcMethod"
        case asrJuristicMethod
        case adjustingMethodForHigherLatitudes
        case dhuhrMinutes        = "dhuhrMin"
        case Easter
        case offsetDays          = "offsetD"
        case equinoxOrSolstice
        case timeChange
        case MoonPhase           = "zmoPhase"
        case throughDay          = "thruD"
        case throughMonth        = "thruMon"
        case fullWeek            = "fullWk"
        case firstDayOfWeek      = "firstDOfWk"
        case durationDays        = "durationD"
    } // enum CodingKeys
} // struct ASADateSpecification


// MARK: -

extension ASADateSpecification {
    fileprivate func dateWithAddedSolarTime(rawDate: Date?, hours: Double, dayHalf: ASADayHalf, location: CLLocation, timeZone: TimeZone, dayHalfStart: ASASolarEvent, dayHalfEnd: ASASolarEvent) -> Date? {
        let HOURS_PER_DAY_HALF = 12.0
        
        switch dayHalf {
        case .night:
            let previousDate = rawDate!.oneDayBefore
            let previousEvents = previousDate.solarEvents(location: location, events: [dayHalfEnd], timeZone:  timeZone)
            let events = rawDate!.solarEvents(location: location, events: [dayHalfStart], timeZone:  timeZone)
            
            let previousSunset:  Date = previousEvents[dayHalfEnd]!! // שקיעה
            let sunrise:  Date = events[dayHalfStart]!! // נץ
            let nightLength = sunrise.timeIntervalSince(previousSunset)
            let nightHourLength = nightLength / HOURS_PER_DAY_HALF
            let result = previousSunset + hours * nightHourLength
            return result
            
        case .day:
            let events = rawDate!.solarEvents(location: location, events: [dayHalfStart, dayHalfEnd], timeZone:  timeZone)
            let sunrise:  Date = events[dayHalfStart]!! // נץ
            let sunset:  Date = events[dayHalfEnd]!! // שקיעה
            let dayLength = sunset.timeIntervalSince(sunrise)
            let hourLength = dayLength / HOURS_PER_DAY_HALF
            let result = sunrise + hours * hourLength
            return result
        }
    } // func dateWithAddedSolarTime(rawDate: Date?, hours: Double, dayHalf: ASADayHalf, location: CLLocation, timeZone: TimeZone, dayHalfStart: ASASolarEvent, dayHalfEnd: ASASolarEvent) -> Date?
    
    // NOTE:  May need updating to support new date specification types!
    func date(dateComponents:  ASADateComponents, calendar:  ASACalendar, isEndDate:  Bool, baseDate: Date, type: ASAEventSpecificationType) -> Date? {
        var revisedDateComponents = dateComponents
        if self.era != nil {
            revisedDateComponents.era = self.era
        }
        if self.year != nil {
            revisedDateComponents.year = self.year
        }
        if self.month != nil {
            revisedDateComponents.month = self.month
        }
        if self.day != nil {
            revisedDateComponents.day = self.day
        }

        if self.hour != nil {
            revisedDateComponents.hour = self.hour
        }

        if self.minute != nil {
            revisedDateComponents.minute = self.minute
        }

        if self.second != nil {
            revisedDateComponents.second = self.second
        }

        if self.nanosecond != nil {
            revisedDateComponents.nanosecond = self.nanosecond
        }

        revisedDateComponents.weekday = nil
        revisedDateComponents.isLeapMonth = nil
        
        let rawDate = calendar.date(dateComponents: revisedDateComponents)
        if rawDate == nil {
            return nil
        }
        
        let timeZone = revisedDateComponents.locationData.timeZone
        
        switch type {
        case .oneYear, .multiYear:
            if isEndDate {
                let numberOfMonthsInYear = calendar.lastMonthOfYear(for: baseDate)!
                let numberOfDaysInLastMonth = calendar.daysInMonth(locationData: revisedDateComponents.locationData, era: revisedDateComponents.era!, year: revisedDateComponents.year!, month: numberOfMonthsInYear)
                revisedDateComponents.month = numberOfMonthsInYear
                revisedDateComponents.day   = numberOfDaysInLastMonth
            } else {
                revisedDateComponents.month =  1
                revisedDateComponents.day   =  1
            }
            let tempResult = calendar.date(dateComponents: revisedDateComponents)
            if tempResult == nil {
                return nil
            }
            let result = isEndDate ? revisedDateComponents.calendar.startOfNextDay(date: tempResult!, locationData: revisedDateComponents.locationData) : revisedDateComponents.calendar.startOfDay(for: tempResult!, locationData: revisedDateComponents.locationData)
            return result
            
        case .oneMonth, .multiMonth:
            if isEndDate {
                let dateComponentsForFirstDayOfMonth = ASADateComponents(calendar: calendar, locationData: dateComponents.locationData, era: self.era, year: self.year, yearForWeekOfYear: nil, quarter: nil, month: self.month, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: 1, hour: nil, minute: nil, second: nil, nanosecond: nil, solarHours: nil, dayHalf: nil)
                let dateOfFirstDayOfMonth = calendar.date(dateComponents: dateComponentsForFirstDayOfMonth)
                let numberOfDaysInMonth = calendar.daysInMonth(for: dateOfFirstDayOfMonth!)!
                revisedDateComponents.day   = numberOfDaysInMonth
            } else {
                revisedDateComponents.day   =  1
            }
            let tempResult = calendar.date(dateComponents: revisedDateComponents)
            if tempResult == nil {
                return nil
            }
            let result = isEndDate ? revisedDateComponents.calendar.startOfNextDay(date: tempResult!, locationData: revisedDateComponents.locationData) : revisedDateComponents.calendar.startOfDay(for: tempResult!, locationData: revisedDateComponents.locationData)
            return result
                        
        case .oneDay, .multiDay, .oneWeek:
            if isEndDate {
                return calendar.startOfNextDay(date: rawDate!, locationData: revisedDateComponents.locationData )
            } else {
                return calendar.startOfDay(for: rawDate!, locationData: revisedDateComponents.locationData )
            }
            
        case .point, .span:
            switch self.pointEventType {
            case .solarTimeSunriseSunset:
                let hours = self.solarHours!
                let dayHalf = self.dayHalf!
                let dayHalfStart = ASASolarEvent.sunrise
                let dayHalfEnd   = ASASolarEvent.sunset
                return dateWithAddedSolarTime(rawDate: rawDate, hours: hours, dayHalf: dayHalf, location: revisedDateComponents.locationData.location, timeZone:  timeZone, dayHalfStart:  dayHalfStart, dayHalfEnd:  dayHalfEnd)

            case .solarTimeDawn72MinutesDusk72Minutes:
                let hours = self.solarHours!
                let dayHalf = self.dayHalf!
                let dayHalfStart = ASASolarEvent.dawn72Minutes
                let dayHalfEnd   = ASASolarEvent.dusk72Minutes
                return dateWithAddedSolarTime(rawDate: rawDate, hours: hours, dayHalf: dayHalf, location: revisedDateComponents.locationData.location, timeZone:  timeZone, dayHalfStart:  dayHalfStart, dayHalfEnd:  dayHalfEnd)
                
            default:
                let tempDate = (calendar.date(dateComponents: revisedDateComponents))!
                return tempDate
            } // switch self.pointEventType
        } // switch type
    } //func date(dateComponents:  ASADateComponents, calendar:  ASACalendar, isEndDate:  Bool) -> Date?

    func rawDegreesBelowHorizon(date:  Date, location: CLLocation, timeZone:  TimeZone) -> Date? {
        let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)

        let events = date.solarEvents(location: location, events: [solarEvent], timeZone:  timeZone)
        let result = events[solarEvent]
        return result!
    }
    
    func date(date:  Date, location: CLLocation, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double, startOfDay:  Date, startOfNextDay:  Date, type: ASAEventSpecificationType) -> Date? {
        switch type {
        case .point:
            switch self.pointEventType {
            case .solarTimeSunriseSunset:
                let hours = self.solarHours!
                let dayHalf = self.dayHalf!
                switch dayHalf {
                case .night:
                    let result = previousSunset + hours * nightHourLength
                    return result
                    
                case .day:
                    let result = sunrise + hours * hourLength
                    return result
                } // switch dayHalf

            case .solarTimeDawn72MinutesDusk72Minutes:
                let hours = self.solarHours!
                let dayHalf = self.dayHalf!
                switch dayHalf {
                case .night:
                    let result = previousOtherDusk + hours * otherNightHourLength
                    return result
                    
                case .day:
                    let result = otherDawn + hours * otherHourLength
                    return result
                } // switch dayHalf

            default:
                return date // TODO:  May have to fix this!
            }

        default:
            return date // TODO:  May have to fix this!
        } // switch type
    } // func date(date:  Date, latitude: CLLocationDegrees, longitude: CLLocationDegrees, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double) -> Date?
} // extension ASADateSpecification


// MARK:  -

extension ASADateSpecification {
    var EYMD: Array<Int?> {
        return [self.era, self.year, self.month, self.day]
    } // var EYMD
    
    func fillIn(EYMD: Array<Int?>) -> ASADateSpecification {
        var result = self
        result.era   = EYMD[0]
        result.year  = EYMD[1]
        result.month = EYMD[2]
        result.day   = EYMD[3]
        return result
    } // func fillIn(EYMD: Array<Int?>) -> ASADateSpecification
    
    var EYM: Array<Int?> {
        return [self.era, self.year, self.month]
    } // var EYM
    
    func fillIn(EYM: Array<Int?>) -> ASADateSpecification {
        var result = self
        result.era   = EYM[0]
        result.year  = EYM[1]
        result.month = EYM[2]
//        debugPrint(#file, #function, "self:", self, "EYM:", EYM, "result:", result)
        return result
    } // fillIn(EYM: Array<Int?>) -> ASADateSpecification
    
    var EY: Array<Int?> {
        return [self.era, self.year]
    } // var EY
    
    func fillIn(EY: Array<Int?>) -> ASADateSpecification {
        var temp = self
        temp.era   = EY[0]
        temp.year  = EY[1]
        return temp
    } // fillIn(EY: Array<Int?>) -> ASADateSpecification
} // extension ASADateSpecification

