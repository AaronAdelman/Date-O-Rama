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
        func previousMidnight(timeZone:  TimeZone) -> Date {
            var gregorianCalendar = Calendar(identifier: .gregorian)
            gregorianCalendar.timeZone = timeZone
            let midnightToday = gregorianCalendar.startOfDay(for:self)
    //        print("\(String(describing: type(of: self))) \(#function) Midnight today:  \(midnightToday)")

            return midnightToday
        } // func previousMidnight(timeZone:  TimeZone) -> Date
    
    func nextMidnight(timeZone:  TimeZone) -> Date {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = timeZone
        let midnightToday = gregorianCalendar.startOfDay(for:self)
//        print("\(String(describing: type(of: self))) \(#function) Midnight today:  \(midnightToday)")

        let dateComponents:DateComponents = {
            var dateComp = DateComponents()
            dateComp.day = 1
            return dateComp
        }()
        let midnightTomorrow = gregorianCalendar.date(byAdding: dateComponents, to: midnightToday)
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
    func solarCorrected(location:  CLLocation, timeZone:  TimeZone) -> Date {
        let events = self.solarEvents(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, events: [.sunset], timeZone: timeZone)
        
        let sunset = events[.sunset]
        if sunset == nil {
            // Guarding against there being no Sunset
            return self.sixPM(timeZone: timeZone)
        }
        if self >= sunset!! {
            return self.nextGMTNoon()
        } else {
            return self
        }
    } // func solarCorrected(location:  CLLocation) -> Date
    
    func sixPM(timeZone:  TimeZone) -> Date {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = timeZone
        let midnightToday = gregorianCalendar.startOfDay(for:self)
        let result = midnightToday.addingTimeInterval(18 * 60 * 60)
        return result
    } // func sixPM()
    
    func sixPMYesterday(timeZone:  TimeZone) -> Date {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = timeZone
        let midnightToday = gregorianCalendar.startOfDay(for:self)
        let midnightYesterday = midnightToday.addingTimeInterval(-24 * 60 * 60)
        let result = midnightYesterday.addingTimeInterval(18 * 60 * 60)
        return result
    } // func sixPMYesterday()
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
    
    func hoursMinutesAndSeconds(startDate:  Date, endDate:  Date, numberOfHoursPerDay:  Double, numberOfMinutesPerHour:  Double, numberOfSecondsPerMinute:  Double) -> (hours:  Int, minutes:  Int, seconds:  Double) {
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
