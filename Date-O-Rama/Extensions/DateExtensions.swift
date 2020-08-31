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
    static var gregorianCalendar = Calendar(identifier: .gregorian)

        func previousMidnight(timeZone:  TimeZone) -> Date {
            Date.gregorianCalendar.timeZone = timeZone
            let midnightToday = Date.gregorianCalendar.startOfDay(for:self)
    //        print("\(String(describing: type(of: self))) \(#function) Midnight today:  \(midnightToday)")

            return midnightToday
        } // func previousMidnight(timeZone:  TimeZone) -> Date
    
    func nextMidnight(timeZone:  TimeZone) -> Date {
        Date.gregorianCalendar.timeZone = timeZone
        let midnightToday = Date.gregorianCalendar.startOfDay(for:self)
//        print("\(String(describing: type(of: self))) \(#function) Midnight today:  \(midnightToday)")

        let dateComponents:DateComponents = {
            var dateComp = DateComponents()
            dateComp.day = 1
            return dateComp
        }()
        let midnightTomorrow = Date.gregorianCalendar.date(byAdding: dateComponents, to: midnightToday)
//        print("\(String(describing: type(of: self))) \(#function) Midnight tomorrow:  \(String(describing: midnightTomorrow))")
        return midnightTomorrow!
    } // func nextMidnight(timeZone:  TimeZone) -> Date
} // extension Date

extension Date {
    func JulianDate() -> Double {
        let seconds = self.timeIntervalSince1970
        return ( seconds / 86400.0 ) + 2440587.5
    } // func JulianDate() -> Double
    
    static func date(JulianDate:  Double) -> Date {
        let seconds = (JulianDate - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } // static func date(JulianDate:  Double) -> Date
    
    func JulianDateWithTime(offsetFromJulianDay:  TimeInterval) -> Double {
        return self.JulianDate() - offsetFromJulianDay
    } // func JulianDateWithTime(offsetFromJulianDay:  TimeInterval) -> Double
    
    func JulianDateWithoutTime(offsetFromJulianDay:  TimeInterval) -> Int {
        return Int(floor(JulianDateWithTime(offsetFromJulianDay: offsetFromJulianDay)))
    } // func JulianDateWithoutTime(offsetFromJulianDay:  TimeInterval) -> Int
    
    static func date(JulianDate:  Double, offsetFromJulianDay:  TimeInterval) -> Date {
        let seconds = ((JulianDate + offsetFromJulianDay) - 2440587.5) * 86400.0
        return Date(timeIntervalSince1970: seconds)
    } //
    
    func previousGMTNoon() -> Date {
        let thisJulianDay = floor(self.JulianDate())
        let result = Date.date(JulianDate: thisJulianDay)
        return result
    } // func previousGMTNoon() -> Date
    
    func nextGMTNoon() -> Date {
        let thisJulianDay = floor(self.JulianDate())
        let nextJulianDay = thisJulianDay + 1
        let result = Date.date(JulianDate: nextJulianDay)
        return result
    } // func nextGMTNoon() -> Date
} // extension Date

extension Date {
    func solarCorrected(location:  CLLocation, timeZone:  TimeZone, transitionEvent:  ASASolarEvent) -> (date:  Date, transition:  Date??) {
        let events = self.solarEvents(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, events: [transitionEvent], timeZone: timeZone)
        
        let sunset = events[transitionEvent]
        var result: (date:  Date, transition:  Date??)
        if sunset == nil {
            // Guarding against there being no Sunset
            result = (self.sixPM(timeZone: timeZone), sunset)
        } else if sunset! == nil {
            // Guarding against there being no Sunset
            result = (self.sixPM(timeZone: timeZone), sunset)
        } else if self >= sunset!! {
            result = (self.noon(timeZone: timeZone).oneDayAfter, sunset)
        } else {
            result = (self, sunset)
        }
        
//        debugPrint(#file, #function, self, result)
        return result
    } // func solarCorrected(location:  CLLocation) -> Date
    
    func noon(timeZone:  TimeZone) -> Date {
        Date.gregorianCalendar.timeZone = timeZone
        let midnightToday = Date.gregorianCalendar.startOfDay(for:self)
        let result = midnightToday.addingTimeInterval(12 * 60 * 60)
        return result
    } // func noon(timeZone:  TimeZone) -> Date
    
    func sixPM(timeZone:  TimeZone) -> Date {
        Date.gregorianCalendar.timeZone = timeZone
        let midnightToday = Date.gregorianCalendar.startOfDay(for:self)
        let result = midnightToday.addingTimeInterval(18 * 60 * 60)
        return result
    } // func sixPM(timeZone:  TimeZone) -> Date
    
//    func sixPMYesterday(timeZone:  TimeZone) -> Date {
//        Date.gregorianCalendar.timeZone = timeZone
//        let midnightToday = Date.gregorianCalendar.startOfDay(for:self)
//        let midnightYesterday = midnightToday.addingTimeInterval(-24 * 60 * 60)
//        let result = midnightYesterday.addingTimeInterval(18 * 60 * 60)
//        return result
//    } // func sixPMYesterday()
} // extension Date

extension Date {
    var oneDayBefore:  Date {
        get {
            return self.addingTimeInterval(-24 * 60 * 60)
        } // get
    } // var oneDayBefore
    
    var oneDayAfter:  Date {
        get {
            return self.addingTimeInterval(24 * 60 * 60)
        } // get
    } // var oneDayAfter
} // extension Date

extension Date {
    func fractionalHours(startDate:  Date, endDate:  Date, numberOfHoursPerDay:  Double) -> Double {
        let seconds = self.timeIntervalSince(startDate)
        let hourLength = endDate.timeIntervalSince(startDate) / numberOfHoursPerDay
        let hours = seconds / hourLength
        return hours
    } // func fractionalHours(startDate:  Date, endDate:  Date) -> Double
    
//    func hoursMinutesAndSeconds(startDate:  Date, endDate:  Date, numberOfHoursPerDay:  Double, numberOfMinutesPerHour:  Double, numberOfSecondsPerMinute:  Double) -> (hours:  Int, minutes:  Int, seconds:  Double) {
//        let totalSISeconds = self.timeIntervalSince(startDate)
//        let hourLength = endDate.timeIntervalSince(startDate) / numberOfHoursPerDay
//        let hours = floor(totalSISeconds / hourLength)
//        let nonHourSISeconds = totalSISeconds - hours * hourLength
//        let minuteLength = hourLength / numberOfMinutesPerHour
//        let minutes = floor(nonHourSISeconds  / minuteLength)
//        let nonMinuteSISeconds = nonHourSISeconds - minutes * minuteLength
//        let secondLength = minuteLength / numberOfSecondsPerMinute
//        let seconds = nonMinuteSISeconds / secondLength
//        return (hours:  Int(hours), minutes:  Int(minutes), seconds:  seconds)
//    } // func hoursMinutesAndSeconds(startDate:  Date, endDate:  Date, numberOfHours:  Int, numberOfMinutesPerHour:  Int, numberOfSecondsPerMinute:  Int) -> (hours:  Int, minutes:  Int, seconds:  Double)
} // extension Date
