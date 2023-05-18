//
//  DateExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-16.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

fileprivate extension ASACalendarCode {
    var offsetFromJulianDay:  Double {
        switch self {
        case .JulianDay:
            return 0.0
            
        case .ReducedJulianDay:
            return 2400000.0
            
        case .ModifiedJulianDay:
            return 2400000.5
            
        case .TruncatedJulianDay:
            return 2440000.5
            
        case .DublinJulianDay:
            return 2415020.0
            
        case .CNESJulianDay:
            return 2433282.5
            
        case .CCSDSJulianDay:
            return 2436204.5
            
        case .LilianDate:
            return 2299159.5
            
        case .RataDie:
            return 1721424.5
            
        default:
            return 0.0
        } // switch calendarCode
    } // var offsetFromJulianDay
    
}

extension Date {
    static let SECONDS_PER_DAY:  TimeInterval  = 24.0 * 60.0 * 60.0
    static let SECONDS_PER_HOUR:  TimeInterval = 60.0 * 60.0

    func previousMidnight(timeZoneOffset: TimeInterval) -> Date {
        let secondsSinceGlobalEpoch = self.timeIntervalSince1970
        let secondsSinceTimeZoneEpoch = secondsSinceGlobalEpoch + timeZoneOffset
        let daysSinceTimeZoneEpoch = secondsSinceTimeZoneEpoch / Date.SECONDS_PER_DAY
        let integralDaysSinceTimeZoneEpoch = floor(daysSinceTimeZoneEpoch)
        let midnightOfDate = Date(timeIntervalSince1970: -timeZoneOffset + (integralDaysSinceTimeZoneEpoch * Date.SECONDS_PER_DAY))
        return midnightOfDate
    } // func previousMidnight(timeZoneOffset: TimeInterval) -> Date

    func previousMidnight(timeZone:  TimeZone) -> Date {
        let timeZoneOffset:  TimeInterval = TimeInterval(timeZone.secondsFromGMT(for: self))
        return previousMidnight(timeZoneOffset: timeZoneOffset)
    } // func previousMidnight(timeZone:  TimeZone) -> Date

//    func nextMidnight(timeZone:  TimeZone) -> Date {
//        let previousMidnight = self.previousMidnight(timeZone: timeZone)
//        let nextMidnight =  previousMidnight.addingTimeInterval(Date.SECONDS_PER_DAY)
//        return nextMidnight
//    } // func nextMidnight(timeZone:  TimeZone) -> Date
} // extension Date

extension Date {
    var JulianDate: Double {
        let seconds = self.timeIntervalSince1970
        return ( seconds / 86400.0 ) + 2440587.5
    } // var JulianDate

    static func date(JulianDate:  Double) -> Date {
        let seconds = (JulianDate - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } // static func date(JulianDate:  Double) -> Date

    func JulianDateWithTime(calendarCode: ASACalendarCode) -> Double {
        if calendarCode == .MarsSolDate {
            return self.MarsSolDate
        }
        
        let offsetFromJulianDay = calendarCode.offsetFromJulianDay
        return self.JulianDate - offsetFromJulianDay
    } // func JulianDateWithTime(calendarCode: ASACalendarCode) -> Double

    func JulianDateWithoutTime(calendarCode: ASACalendarCode) -> Int {
        return Int(floor(JulianDateWithTime(calendarCode: calendarCode)))
    } // func JulianDateWithoutTime(calendarCode: ASACalendarCode) -> Int
    
    func localModifiedJulianDay(timeZone: TimeZone) -> Int {
        let seconds = timeZone.secondsFromGMT(for: self)
        let adjustedDate = self.addingTimeInterval(Double(seconds))
        return adjustedDate.JulianDateWithoutTime(calendarCode: .ModifiedJulianDay)
    }
    
    static func date(localModifiedJulianDay: Int, timeZone: TimeZone) -> Date {
        let rawDate = Date.date(JulianDate: Double(localModifiedJulianDay), calendarCode: .ModifiedJulianDay)
        let seconds = timeZone.secondsFromGMT(for: rawDate)
        let adjustedDate = rawDate.addingTimeInterval(-Double(seconds))
        return adjustedDate
    } // static func date(localModifiedJulianDay: Double, timeZone: TimeZone) -> Date

    func JulianDateComponents(calendarCode: ASACalendarCode) -> (day:  Int, fractionOfDay: Double) {
        let full = self.JulianDateWithTime(calendarCode: calendarCode)
        let dayAsDouble: TimeInterval = floor(full)
        let fractionOfDay = full - dayAsDouble
        
        return (day: day, fractionOfDay: fractionOfDay)
    } // func JulianDateComponents(calendarCode: ASACalendarCode) -> (day:  Int, fractionOfDay: Double)

    func JulianDateWithComponents(calendarCode: ASACalendarCode) -> (JulianDate: Double, day:  Int, fractionOfDay: Double) {
        let full = self.JulianDateWithTime(calendarCode: calendarCode)
        let dayAsDouble: TimeInterval = floor(full)
        let fractionOfDay = full - dayAsDouble

        let day = Int(dayAsDouble)

        return (JulianDate: full, day:  day, fractionOfDay: fractionOfDay)
    } // func JulianDateWithComponents(calendarCode: ASACalendarCode) -> (JulianDate: Double, day:  Int, fractionOfDay: Double)

    static func date(JulianDate:  Double, calendarCode: ASACalendarCode) -> Date {
        if calendarCode == .MarsSolDate {
            return Date.date(MarsSolDate: JulianDate)
        }
        
        let offsetFromJulianDay = calendarCode.offsetFromJulianDay
        let seconds = ((JulianDate + offsetFromJulianDay) - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } // static func date(JulianDate:  Double, calendarCode: ASACalendarCode) -> Date
    
    var previousGMTNoon: Date {
        let thisJulianDay = floor(self.JulianDate)
        let result = Date.date(JulianDate: thisJulianDay)
        return result
    } // var previousGMTNoon

//    var nextGMTNoon: Date {
//        let thisJulianDay = floor(self.JulianDate)
//        let nextJulianDay = thisJulianDay + 1
//        let result = Date.date(JulianDate: nextJulianDay)
//        return result
//    } // var nextGMTNoon
} // extension Date

extension Date {
    func solarCorrected(locationData:  ASALocation, transitionEvent:  ASASolarEvent) -> (date:  Date, transition:  Date??) {
        let timeZone = locationData.timeZone
        let events = self.solarEvents(location: locationData.location, events: [transitionEvent], timeZone: timeZone)

        let sunset = events[transitionEvent]
        debugPrint("🔧", #file, #function, "self:", self, "sunset:", sunset as Any)
        var result: (date:  Date, transition:  Date??)
        if sunset == nil {
            // Guarding against there being no Sunset
            let sixPM: Date = self.sixPM(timeZone: timeZone)
            result = (sixPM, sixPM)
//            assert(result.date >= self)
        } else if sunset! == nil {
            // Guarding against there being no Sunset
            let sixPM: Date = self.sixPM(timeZone: timeZone)
            result = (sixPM, sixPM)
            if self < sixPM {
//                debugPrint(#file, #function, result, self)
                result.date = self
            }
            assert(result.date >= self)
        } else if self >= sunset!! {
            result = (self.noon(timeZone: timeZone).oneDayAfter, sunset)
            assert(result.date >= self)
        } else {
            result = (self, sunset)
            assert(result.date >= self)
        }

        return result
    } // func solarCorrected(location:  CLLocation) -> Date

    func noon(timeZone:  TimeZone) -> Date {
        let midnightToday = self.previousMidnight(timeZone: timeZone)
        let result = midnightToday.addingTimeInterval(12 * Date.SECONDS_PER_HOUR)
        return result
    } // func noon(timeZone:  TimeZone) -> Date

    func sixPM(timeZone:  TimeZone) -> Date {
        let midnightToday = self.previousMidnight(timeZone: timeZone)
        let result = midnightToday.addingTimeInterval(18 * Date.SECONDS_PER_HOUR)
        return result
    } // func sixPM(timeZone:  TimeZone) -> Date

    func sixPMYesterday(timeZone:  TimeZone) -> Date {
        let midnightToday = self.previousMidnight(timeZone: timeZone)
        let result = midnightToday.addingTimeInterval(6 * Date.SECONDS_PER_HOUR)
        return result
    } // func sixPMYesterday()
} // extension Date

extension Date {
    var oneDayBefore:  Date {
        get {
            return self.addingTimeInterval(-Date.SECONDS_PER_DAY)
        } // get
    } // var oneDayBefore

    var oneDayAfter:  Date {
        get {
            return self.addingTimeInterval(Date.SECONDS_PER_DAY)
        } // get
    } // var oneDayAfter
} // extension Date

extension Date {
    func fractionalHours(startDate:  Date, endDate:  Date, numberOfHoursPerDay:  Double) -> Double {
        assert(endDate > startDate)
        assert(numberOfHoursPerDay > 0.0)

        let seconds = self.timeIntervalSince(startDate)
        let hourLength = endDate.timeIntervalSince(startDate) / numberOfHoursPerDay
        let hours = seconds / hourLength
        return hours
    } // func fractionalHours(startDate:  Date, endDate:  Date) -> Double

    func hoursMinutesAndSeconds(startDate:  Date, endDate:  Date, numberOfHoursPerDay:  Double, numberOfMinutesPerHour:  Double, numberOfSecondsPerMinute:  Double) -> (hours:  Int, minutes:  Int, seconds:  Double) {
        assert(endDate > startDate)
        assert(numberOfHoursPerDay > 0.0)
        assert(numberOfMinutesPerHour > 0.0)
        assert(numberOfSecondsPerMinute > 0.0)

        let totalSISeconds = self.timeIntervalSince(startDate)
        let hourLength = endDate.timeIntervalSince(startDate) / numberOfHoursPerDay
        let hours = floor(totalSISeconds / hourLength)
        let nonHourSISeconds = totalSISeconds - hours * hourLength
        let minuteLength = hourLength / numberOfMinutesPerHour
        let minutes = floor(nonHourSISeconds  / minuteLength)
        let nonMinuteSISeconds = nonHourSISeconds - minutes * minuteLength
        let secondLength = minuteLength / numberOfSecondsPerMinute
        let seconds = nonMinuteSISeconds / secondLength
        return (hours:  Int(hours), minutes:  Int(minutes), seconds:  seconds)
    } // func hoursMinutesAndSeconds(startDate:  Date, endDate:  Date, numberOfHours:  Int, numberOfMinutesPerHour:  Int, numberOfSecondsPerMinute:  Int) -> (hours:  Int, minutes:  Int, seconds:  Double)
} // extension Date


// -  Mars Sol Date

fileprivate let MarsSolDateOffset  = 2405522.0
fileprivate let MarsSolDateDivisor =       1.027491252
fileprivate let MarsSolDateFudge   =       0.00200 // Fudged to get the same value, more or less as https://marsclock.com/

extension Date {
    var MarsSolDate: Double {
        let JD: Double = self.JulianDate
        let result = (JD - MarsSolDateOffset) / MarsSolDateDivisor - MarsSolDateFudge
        return result
    }
    
    static func date(MarsSolDate: Double) -> Date {
        let JD = MarsSolDateDivisor * (MarsSolDate + MarsSolDateFudge) + MarsSolDateOffset
        return Date.date(JulianDate: JD)
    }
}


// -

extension Date {
    static func date(timeIntervalSince1970: TimeInterval?) -> Date? {
        if timeIntervalSince1970 == nil {
            return nil
        }
        
        return Date(timeIntervalSince1970: timeIntervalSince1970!)
    }
}
