//
//  ASADateSpecification.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 03/03/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import CoreLocation
import Foundation

enum ASATimeSpecificationDayHalf:  String, Codable {
    case night = "night"
    case day   = "day"
} // enum ASATimeSpecificationDayHalf

struct ASADateSpecification:  Codable {
    var era:  Int?
    
    /// Will be ignored if not relevant
    var year:  Int?
    
    /// Will be ignored if not relevant
    var month:  Int?
    
    var day:  Int?
    
    var weekdays:  Array<ASAWeekday>?
    
    /// If non-nil, the number of the recurrence of the first weekday given in the month.  If negative, then -1 is the last recurrence, -2 is the next to last recurrence, etc.
    var weekdayRecurrence: Int?
    var lengthsOfMonth:  Array<Int>?
    var lengthsOfYear:  Array<Int>?
    var dayOfYear:  Int?

    var yearDivisor:  Int?
    
    /// Matches if year mod yearDivisor = yearRemainder
    var yearRemainder: Int?

    var type: ASATimeSpecificationType
    
    // For degrees below horizon events
    var degreesBelowHorizon: Double?
    var rising: Bool?
    var offset: TimeInterval?
    
    // For solar time events
    var solarHours: Double?
    var dayHalf: ASATimeSpecificationDayHalf?
    
    // For rise and set events
    var body: String?
    
    // For Islamic prayer times
    var event: ASAIslamicPrayerTimeEvent?
    var calculationMethod: ASACalculationMethod?
    var asrJuristicMethod: ASAJuristicMethodForAsr?
    var adjustingMethodForHigherLatitudes: ASAAdjustingMethodForHigherLatitudes?
    var dhuhrMinutes: Double?
    
} // struct ASADateSpecification


// MARK: -

extension ASADateSpecification {
    fileprivate func dateWithAddedSolarTime(rawDate: Date?, hours: Double, dayHalf: ASATimeSpecificationDayHalf, location: CLLocation, timeZone: TimeZone, dayHalfStart: ASASolarEvent, dayHalfEnd: ASASolarEvent) -> Date? {
        switch dayHalf {
        case .night:
            let previousDate = rawDate!.oneDayBefore
            let previousEvents = previousDate.solarEvents(location: location, events: [dayHalfEnd], timeZone:  timeZone)
            let events = rawDate!.solarEvents(location: location, events: [dayHalfStart, dayHalfEnd, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
            
            let previousSunset:  Date = previousEvents[dayHalfEnd]!! // שקיעה
            let sunrise:  Date = events[dayHalfStart]!! // נץ
            let nightLength = sunrise.timeIntervalSince(previousSunset)
            let nightHourLength = nightLength / 12.0
            let result = previousSunset + hours * nightHourLength
            return result
            
        case .day:
            let events = rawDate!.solarEvents(location: location, events: [dayHalfStart, dayHalfEnd, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
            let sunrise:  Date = events[dayHalfStart]!! // נץ
            let sunset:  Date = events[dayHalfEnd]!! // שקיעה
            let dayLength = sunset.timeIntervalSince(sunrise)
            let hourLength = dayLength / 12.0
            let result = sunrise + hours * hourLength
            return result
        }
    }
    
    func date(dateComponents:  ASADateComponents, calendar:  ASACalendar, isEndDate:  Bool, baseDate: Date) -> Date? {
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
        
        revisedDateComponents.weekday = nil
        revisedDateComponents.isLeapMonth = nil
        
        if !calendar.isValidDate(dateComponents: revisedDateComponents) {
            return nil
        }
        let rawDate = calendar.date(dateComponents: revisedDateComponents)
        if rawDate == nil {
            return nil
        }
        
        let timeZone = revisedDateComponents.locationData.timeZone
        
        switch self.type {
        case .oneYear, .multiYear:
            if isEndDate {
                let numberOfMonthsInYear = calendar.maximumValue(of: .month, in: .year, for: baseDate)!
                let tempComponents = ASADateComponents(calendar: calendar, locationData: revisedDateComponents.locationData, era: revisedDateComponents.era, year: revisedDateComponents.year, yearForWeekOfYear: nil, quarter: nil, month: numberOfMonthsInYear, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: 1, hour: nil, minute: nil, second: nil, nanosecond: nil)
                let tempDate = (calendar.date(dateComponents: tempComponents))!
                let numberOfDaysInLastMonth = calendar.maximumValue(of: .day, in: .month, for: tempDate)!
                revisedDateComponents.month = numberOfMonthsInYear
                revisedDateComponents.day   = numberOfDaysInLastMonth
            } else {
                revisedDateComponents.month =  1
                revisedDateComponents.day   =  1
            }
//            revisedDateComponents.weekday     = nil
//            revisedDateComponents.isLeapMonth = nil
            let tempResult = calendar.date(dateComponents: revisedDateComponents)
            if tempResult == nil {
                return nil
            }
            let result = isEndDate ? revisedDateComponents.calendar.startOfNextDay(date: tempResult!, locationData: revisedDateComponents.locationData) : revisedDateComponents.calendar.startOfDay(for: tempResult!, locationData: revisedDateComponents.locationData)
            return result
            
        case .oneMonth, .multiMonth:
            if isEndDate {
                let numberOfDaysInMonth = calendar.maximumValue(of: .day, in: .month, for: baseDate)!
                revisedDateComponents.day   = numberOfDaysInMonth
            } else {
                revisedDateComponents.day   =  1
            }
//            revisedDateComponents.weekday     = nil
//            revisedDateComponents.isLeapMonth = nil
            let tempResult = calendar.date(dateComponents: revisedDateComponents)
            if tempResult == nil {
                return nil
            }
            let result = isEndDate ? revisedDateComponents.calendar.startOfNextDay(date: tempResult!, locationData: revisedDateComponents.locationData) : revisedDateComponents.calendar.startOfDay(for: tempResult!, locationData: revisedDateComponents.locationData)
            return result
            
        case .oneDay, .multiDay:
            if isEndDate {
                return calendar.startOfNextDay(date: rawDate!, locationData: revisedDateComponents.locationData )
            } else {
                return calendar.startOfDay(for: rawDate!, locationData: revisedDateComponents.locationData )
            }
//        case .degreesBelowHorizon:
//            let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)
//            let events = rawDate!.solarEvents(location: revisedDateComponents.locationData.location, events: [solarEvent], timeZone:  timeZone)
//            let result = events[solarEvent]
//            if result == nil {
//                return nil
//            }
//            if result! == nil {
//                return nil
//            }
//            return result!
            
        case .solarTimeSunriseSunset:
            let hours = self.solarHours!
            let dayHalf = self.dayHalf!
            let dayHalfStart = ASASolarEvent.sunrise
            let dayHalfEnd   = ASASolarEvent.sunset
            return dateWithAddedSolarTime(rawDate: rawDate, hours: hours, dayHalf: dayHalf, location: revisedDateComponents.locationData.location, timeZone:  timeZone , dayHalfStart:  dayHalfStart, dayHalfEnd:  dayHalfEnd)

        case .solarTimeDawn72MinutesDusk72Minutes:
            let hours = self.solarHours!
            let dayHalf = self.dayHalf!
            let dayHalfStart = ASASolarEvent.dawn72Minutes
            let dayHalfEnd   = ASASolarEvent.dusk72Minutes
            return dateWithAddedSolarTime(rawDate: rawDate, hours: hours, dayHalf: dayHalf, location: revisedDateComponents.locationData.location, timeZone:  timeZone , dayHalfStart:  dayHalfStart, dayHalfEnd:  dayHalfEnd)
        default:
            return Date ()
            // TODO:  NEED TO FIX THIS!
        } // switch self.type
    } //func date(dateComponents:  ASADateComponents, calendar:  ASACalendar, isEndDate:  Bool) -> Date?

    func rawDegreesBelowHorizon(date:  Date, location: CLLocation, timeZone:  TimeZone) -> Date? {
        let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)

        let events = date.solarEvents(location: location, events: [solarEvent], timeZone:  timeZone)
        let result = events[solarEvent]
        return result!
    }
    
    func date(date:  Date, location: CLLocation, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double, startOfDay:  Date, startOfNextDay:  Date) -> Date? {
        switch self.type {
//        case .degreesBelowHorizon:
//            let result = self.rawDegreesBelowHorizon(date: date, location: location, timeZone: timeZone)
//            return result!
            
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
        } // switch self.type
    } // func date(date:  Date, latitude: CLLocationDegrees, longitude: CLLocationDegrees, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double) -> Date?
} // extension ASADateSpecification


// MARK:  -

extension ASADateSpecification {
    var EYMD: Array<Int?> {
        return [self.era, self.year, self.month, self.day]
    } // var EYMD
    
    func fillIn(EYMD: Array<Int?>) -> ASADateSpecification {
        var temp = self
        temp.era   = EYMD[0]
        temp.year  = EYMD[1]
        temp.month = EYMD[2]
        temp.day   = EYMD[3]
        return temp
    } // fillIn(EYMD: Array<Int?>) -> ASADateSpecification
    
    var EYM: Array<Int?> {
        return [self.era, self.year, self.month]
    } // var EYM
    
    func fillIn(EYM: Array<Int?>) -> ASADateSpecification {
        var temp = self
        temp.era   = EYMD[0]
        temp.year  = EYMD[1]
        temp.month = EYMD[2]
        return temp
    } // fillIn(EYM: Array<Int?>) -> ASADateSpecification
    
    var EY: Array<Int?> {
        return [self.era, self.year]
    } // var EYM
    
    func fillIn(EY: Array<Int?>) -> ASADateSpecification {
        var temp = self
        temp.era   = EYMD[0]
        temp.year  = EYMD[1]
        return temp
    } // fillIn(EY: Array<Int?>) -> ASADateSpecification
} // extension ASADateSpecification

