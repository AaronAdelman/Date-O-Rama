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
        case .julianDay:
            return 0.0
            
        case .reducedJulianDay:
            return 2400000.0
            
        case .modifiedJulianDay:
            return 2400000.5
            
        case .truncatedJulianDay:
            return 2440000.5
            
        case .dublinJulianDay:
            return 2415020.0
            
        case .cnesJulianDay:
            return 2433282.5
            
        case .ccsdsJulianDay:
            return 2436204.5
            
        case .lilianDate:
            return 2299159.5
            
        case .rataDie:
            return 1721424.5
            
        default:
            return 0.0
        } // switch calendarCode
    } // var offsetFromJulianDay
} // extension ASACalendarCode

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

    func previousMidnight(timeZone: TimeZone) -> Date {
        let timeZoneOffset:  TimeInterval = TimeInterval(timeZone.secondsFromGMT(for: self))
        return previousMidnight(timeZoneOffset: timeZoneOffset)
    } // func previousMidnight(timeZone:  TimeZone) -> Date

    func dateToCalculateSolarEventsFor(timeZone: TimeZone) -> Date {
        return self.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: self)))
    } // func dateToCalculateSolarEventsFor(timeZone: TimeZone) -> Date
} // extension Date

extension Date {
    var julianDate: Double {
        let seconds = self.timeIntervalSince1970
        return ( seconds / 86400.0 ) + 2440587.5
    } // var julianDate

    static func date(julianDate:  Double) -> Date {
        let seconds = (julianDate - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } // static func date(JulianDate:  Double) -> Date

    func julianDateWithTime(calendarCode: ASACalendarCode) -> Double {
        if calendarCode == .marsSolDate {
            return self.marsSolDate
        }
        
        let offsetFromJulianDay = calendarCode.offsetFromJulianDay
        return self.julianDate - offsetFromJulianDay
    } // func julianDateWithTime(calendarCode: ASACalendarCode) -> Double

    func julianDateWithoutTime(calendarCode: ASACalendarCode) -> Int {
        return Int(floor(julianDateWithTime(calendarCode: calendarCode)))
    } // func julianDateWithoutTime(calendarCode: ASACalendarCode) -> Int
    
    func localModifiedJulianDay(timeZone: TimeZone) -> Int {
        let seconds = timeZone.secondsFromGMT(for: self)
        let adjustedDate = self.addingTimeInterval(Double(seconds))
        return adjustedDate.julianDateWithoutTime(calendarCode: .modifiedJulianDay)
    } // func localModifiedJulianDay(timeZone: TimeZone) -> Int
    
//    static func date(localModifiedJulianDay: Int, timeZone: TimeZone) -> Date {
//        let rawDate = Date.date(JulianDate: Double(localModifiedJulianDay), calendarCode: .modifiedJulianDay)
//        let seconds = timeZone.secondsFromGMT(for: rawDate)
//        let adjustedDate = rawDate.addingTimeInterval(-Double(seconds))
//        return adjustedDate
//    } // static func date(localModifiedJulianDay: Double, timeZone: TimeZone) -> Date

    func julianDateComponents(calendarCode: ASACalendarCode) -> (day:  Int, fractionOfDay: Double) {
        let full = self.julianDateWithTime(calendarCode: calendarCode)
        let dayAsDouble: TimeInterval = floor(full)
        let fractionOfDay = full - dayAsDouble
        
        return (day: day, fractionOfDay: fractionOfDay)
    } // func julianDateComponents(calendarCode: ASACalendarCode) -> (day:  Int, fractionOfDay: Double)

    func julianDateWithComponents(calendarCode: ASACalendarCode) -> (JulianDate: Double, day:  Int, fractionOfDay: Double) {
        let full = self.julianDateWithTime(calendarCode: calendarCode)
        let dayAsDouble: TimeInterval = floor(full)
        let fractionOfDay = full - dayAsDouble

        let day = Int(dayAsDouble)

        return (JulianDate: full, day:  day, fractionOfDay: fractionOfDay)
    } // func julianDateWithComponents(calendarCode: ASACalendarCode) -> (JulianDate: Double, day:  Int, fractionOfDay: Double)

    static func date(JulianDate:  Double, calendarCode: ASACalendarCode) -> Date {
        if calendarCode == .marsSolDate {
            return Date.date(MarsSolDate: JulianDate)
        }
        
        let offsetFromJulianDay = calendarCode.offsetFromJulianDay
        let seconds = ((JulianDate + offsetFromJulianDay) - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } // static func date(JulianDate:  Double, calendarCode: ASACalendarCode) -> Date
    
    var previousGMTNoon: Date {
        let thisJulianDay = floor(self.julianDate)
        let result = Date.date(julianDate: thisJulianDay)
        return result
    } // var previousGMTNoon
} // extension Date

extension Date {
    func solarCorrected(locationData:  ASALocation, transitionEvent:  ASASolarEvent) -> (date:  Date, transition:  Date??) {
        let timeZone = locationData.timeZone
        let events = self.solarEvents(location: locationData.location, events: [transitionEvent], timeZone: timeZone)

        let sunset = events[transitionEvent]
//        debugPrint("🔧", #file, #function, "self:", self, "sunset:", sunset as Any)
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
        return self.addingTimeInterval(-Date.SECONDS_PER_DAY)
    } // var oneDayBefore
    
    var oneDayAfter:  Date {
        return self.addingTimeInterval(Date.SECONDS_PER_DAY)
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
} // extension Date


// -  Mars Sol Date

fileprivate let marsSolDateOffset  = 2405522.0
fileprivate let marsSolDateDivisor =       1.027491252
fileprivate let marsSolDateFudge   =       0.00200 // Fudged to get the same value, more or less as https://marsclock.com/

extension Date {
    var marsSolDate: Double {
        let jd: Double = self.julianDate
        let result = (jd - marsSolDateOffset) / marsSolDateDivisor - marsSolDateFudge
        return result
    }
    
    static func date(MarsSolDate: Double) -> Date {
        let jd = marsSolDateDivisor * (MarsSolDate + marsSolDateFudge) + marsSolDateOffset
        return Date.date(julianDate: jd)
    }
}


// -

extension Date {
    static func date(timeIntervalSince1970: TimeInterval?) -> Date? {
        if timeIntervalSince1970 == nil {
            return nil
        }
        
        return Date(timeIntervalSince1970: timeIntervalSince1970!)
    } // static func date(timeIntervalSince1970: TimeInterval?) -> Date?
} // extension Date
