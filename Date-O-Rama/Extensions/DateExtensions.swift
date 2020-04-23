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
    } // func nextMidnight() -> Date
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
    
    func nextGMTNoon() -> Date {
        let thisJulianDay = floor(self.JulianDate())
        let nextJulianDay = thisJulianDay + 1
        let result = Date.date(JulianDate: nextJulianDay)
        return result
    } // func nextGMTNoon() -> Date
} // extension Date

extension Date {
    func solarCorrected(location:  CLLocation) -> Date {
        let events = self.solarEvents(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, events: [.sunset])
        
        let sunset = events[.sunset]
        if sunset == nil {
            // Guarding against there being no Sunset
            return self // TODO:  FIX THIS!
        }
        if self > sunset!! {
            return self.nextGMTNoon()
        } else {
            return self
        }
    }
}
