//
//  DateExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-16.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

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

    func nextMidnight(timeZone:  TimeZone) -> Date {
        let previousMidnight = self.previousMidnight(timeZone: timeZone)
        let nextMidnight =  previousMidnight.addingTimeInterval(Date.SECONDS_PER_DAY)
        return nextMidnight
    } // func nextMidnight(timeZone:  TimeZone) -> Date
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

    func JulianDateWithTime(offsetFromJulianDay:  TimeInterval) -> Double {
        return self.JulianDate - offsetFromJulianDay
    } // func JulianDateWithTime(offsetFromJulianDay:  TimeInterval) -> Double

    func JulianDateWithoutTime(offsetFromJulianDay:  TimeInterval) -> Int {
        return Int(floor(JulianDateWithTime(offsetFromJulianDay: offsetFromJulianDay)))
    } // func JulianDateWithoutTime(offsetFromJulianDay:  TimeInterval) -> Int

    func JulianDateComponents(offsetFromJulianDay:  TimeInterval) -> (day:  Int,
//                                                                      hour:  Int, minute:  Int, second:  Int, nanosecond:  Int,
                                                                      fractionOfDay: Double) {
        let full = self.JulianDateWithTime(offsetFromJulianDay: offsetFromJulianDay)
        let dayAsDouble: TimeInterval = floor(full)
        let fractionOfDay = full - dayAsDouble
//        let fullHours = fractionOfDay * 24.0
//        let integralHoursAsDouble = floor(fullHours)
//        let fullMinutes = (fullHours - integralHoursAsDouble) * 60.0
//        let integralMinutesAsDouble = floor(fullMinutes)
//        let fullSeconds = (fullMinutes - integralMinutesAsDouble) * 60.0
//        let integralSecondsAsDouble = floor(fullSeconds)
//        let fullNanoseconds = (fullSeconds - integralSecondsAsDouble) * 1000000000.0
//        let integralNanosecondsAsDouble = floor(fullNanoseconds)
//
//        let day = Int(dayAsDouble)
//        let hour = Int(integralHoursAsDouble)
//        let minute = Int(integralMinutesAsDouble)
//        let second = Int(integralSecondsAsDouble)
//        let nanosecond = Int(integralNanosecondsAsDouble)

        return (day:  day,
//                hour:  hour, minute:  minute, second:  second, nanosecond:  nanosecond,
                fractionOfDay: fractionOfDay)
    } // func JulianDateComponents(offsetFromJulianDay:  TimeInterval) -> (day:  Int, hour:  Int, minute:  Int, second:  Int, nanosecond:  Int, fractionOfDay: Double)

    func JulianDateWithComponents(offsetFromJulianDay:  TimeInterval) -> (JulianDate: Double, day:  Int,
//                                                                          hour:  Int, minute:  Int, second:  Int, nanosecond:  Int,
                                                                          fractionOfDay: Double) {
        let full = self.JulianDateWithTime(offsetFromJulianDay: offsetFromJulianDay)
        let dayAsDouble: TimeInterval = floor(full)
        let fractionOfDay = full - dayAsDouble
//        let fullHours = fractionOfDay * 24.0
//        let integralHoursAsDouble = floor(fullHours)
//        let fullMinutes = (fullHours - integralHoursAsDouble) * 60.0
//        let integralMinutesAsDouble = floor(fullMinutes)
//        let fullSeconds = (fullMinutes - integralMinutesAsDouble) * 60.0
//        let integralSecondsAsDouble = floor(fullSeconds)
//        let fullNanoseconds = (fullSeconds - integralSecondsAsDouble) * 1000000000.0
//        let integralNanosecondsAsDouble = floor(fullNanoseconds)

        let day = Int(dayAsDouble)
//        let hour = Int(integralHoursAsDouble)
//        let minute = Int(integralMinutesAsDouble)
//        let second = Int(integralSecondsAsDouble)
//        let nanosecond = Int(integralNanosecondsAsDouble)

        return (JulianDate: full, day:  day,
//                hour:  hour, minute:  minute, second:  second, nanosecond:  nanosecond,
                fractionOfDay: fractionOfDay)
    } // func JulianDateWithComponents(offsetFromJulianDay:  TimeInterval, supportsTime: Bool) -> (JulianDate: Double, day:  Int, hour:  Int, minute:  Int, second:  Int, nanosecond:  Int)

    static func date(JulianDate:  Double, offsetFromJulianDay:  TimeInterval) -> Date {
        let seconds = ((JulianDate + offsetFromJulianDay) - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } // static func date(JulianDate:  Double, offsetFromJulianDay:  TimeInterval) -> Date

    var previousGMTNoon: Date {
        let thisJulianDay = floor(self.JulianDate)
        let result = Date.date(JulianDate: thisJulianDay)
        return result
    } // var previousGMTNoon

    var nextGMTNoon: Date {
        let thisJulianDay = floor(self.JulianDate)
        let nextJulianDay = thisJulianDay + 1
        let result = Date.date(JulianDate: nextJulianDay)
        return result
    } // var nextGMTNoon
} // extension Date

extension Date {
    func solarCorrected(locationData:  ASALocation, transitionEvent:  ASASolarEvent) -> (date:  Date, transition:  Date??) {
        let timeZone = locationData.timeZone
        let events = self.solarEvents(location: locationData.location, events: [transitionEvent], timeZone: timeZone)

        let sunset = events[transitionEvent]
        var result: (date:  Date, transition:  Date??)
        if sunset == nil {
            // Guarding against there being no Sunset
            result = (self.sixPM(timeZone: timeZone), sunset)
            assert(result.date >= self)
        } else if sunset! == nil {
            // Guarding against there being no Sunset
            result = (self.sixPM(timeZone: timeZone), sunset)
            if !(result.date >= self) {
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
