//
//  ASADateComponents.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-07-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

struct ASADateComponents:  Equatable {
    // MARK:  - Initializing Date Components
    
    var calendar:  ASACalendar
    var locationData:  ASALocation
    
    
    // MARK:  - Validating a Date
    
    var date: Date? {
        get {
            return self.calendar.date(dateComponents: self)
        } // get
    } // var date
    // The date calculated from the current components using the stored calendar.
    
    
    // MARK:  - Accessing Months and Years
    
    var era: Int?
    // An era or count of eras.
    
    var year: Int?
    //    A year or count of years.
    
    var yearForWeekOfYear: Int?
    //    The year corresponding to a week-counting week.
    
    var quarter: Int?
    //    A quarter or count of quarters.
    
    var month: Int?
    //    A month or count of months.
    
    var isLeapMonth: Bool?
    //    Set to true if these components represent a leap month.
    
    
    // MARK: - Accessing Weeks and Days
    
    var weekOfMonth: Int?
    //    A week of the month or a count of weeks of the month.
    
    var weekOfYear: Int?
    //    A week of the year or count of the weeks of the year.
    
    var weekday: Int?
    //    A weekday or count of weekdays.
    
    var weekdayOrdinal: Int?
    //    A weekday ordinal or count of weekday ordinals.
    
    var day: Int?
    //    A day or count of days.
    
    
    // MARK:  - Accessing Hours and Seconds
    
    var hour: Int?
    //    An hour or count of hours.
    
    var minute: Int?
    //    A minute or count of minutes.
    
    var second: Int?
    //    A second or count of seconds.
    
    var nanosecond: Int?
    //    A nanosecond or count of nanoseconds.
    
    var solarHours: Double?
    var dayHalf: ASADayHalf?
    
    
    // MARK: - Equatable
    
    static func == (lhs: ASADateComponents, rhs: ASADateComponents) -> Bool {
        if lhs.era != rhs.era
        || lhs.year != rhs.year
            || lhs.year != rhs.year
            || lhs.yearForWeekOfYear != rhs.yearForWeekOfYear
            || lhs.quarter != rhs.quarter
            || lhs.month != rhs.month
            || lhs.weekOfYear != rhs.weekOfYear
            || lhs.weekOfMonth != rhs.weekOfMonth
            || lhs.weekday != rhs.weekday
            || lhs.weekdayOrdinal != rhs.weekdayOrdinal
            || lhs.day != rhs.day
            || lhs.hour != rhs.hour
            || lhs.minute != rhs.minute
            || lhs.second != rhs.second
            || lhs.nanosecond != rhs.nanosecond
            || lhs.calendar.calendarCode != lhs.calendar.calendarCode
            || lhs.locationData != rhs.locationData {
            return false
        }
        
        return true
    }
} // struct ASADateComponents


// MARK: -

extension ASADateComponents {
    func ApplesDateComponents() -> DateComponents {
        let title = self.calendar.calendarCode.equivalentCalendarIdentifier!
        
        let calendar = Calendar(identifier: title)
        var dateComponents = DateComponents()
        
        dateComponents.calendar = calendar
        dateComponents.timeZone = self.locationData.timeZone
        
        dateComponents.era               = self.era
        dateComponents.year              = self.year
        dateComponents.yearForWeekOfYear = self.yearForWeekOfYear
        dateComponents.quarter           = self.quarter
        dateComponents.month             = self.month
        dateComponents.isLeapMonth       = self.isLeapMonth
        
        dateComponents.weekOfMonth       = self.weekOfMonth
        dateComponents.weekOfYear        = self.weekOfYear
        dateComponents.weekday           = self.weekday
        dateComponents.weekdayOrdinal    = self.weekdayOrdinal
        dateComponents.day               = self.day
        
        dateComponents.hour              = self.hour
        dateComponents.minute            = self.minute
        dateComponents.second            = self.second
        dateComponents.nanosecond        = self.nanosecond
        
        return dateComponents
    } // func DateComponents() -> DateComponents
    
    static func new(with ApplesDateComponents:  DateComponents, calendar:  ASACalendar, locationData:  ASALocation) -> ASADateComponents {
        let result = ASADateComponents(calendar: calendar, locationData: locationData, era: ApplesDateComponents.era, year: ApplesDateComponents.year, yearForWeekOfYear: ApplesDateComponents.yearForWeekOfYear, quarter: ApplesDateComponents.quarter, month: ApplesDateComponents.month, isLeapMonth: ApplesDateComponents.isLeapMonth, weekOfMonth: ApplesDateComponents.weekOfMonth, weekOfYear: ApplesDateComponents.weekOfYear, weekday: ApplesDateComponents.weekday, weekdayOrdinal: ApplesDateComponents.weekdayOrdinal, day: ApplesDateComponents.day, hour: ApplesDateComponents.hour, minute: ApplesDateComponents.minute, second: ApplesDateComponents.second, nanosecond: ApplesDateComponents.nanosecond)
        return result
    } // static func new(with ApplesDateComponents:  DateComponents, calendar:  ASACalendar, locationData:  ASALocation) -> ASADateComponents
} // extension ASADateComponents


// MARK:  - Start and end date specifications

extension ASADateComponents {
    var EYMD: Array<Int?> {
        return [self.era, self.year, self.month, self.day]
    } // var EYMD
    
    var EYM: Array<Int?> {
        return [self.era, self.year, self.month]
    } // var EYM
    
    var EY: Array<Int?> {
        return [self.era, self.year]
    } // var EY
    
    /// Seconds since the start of day.  WARNING:  The assumption is that these are ISO seconds!
    var secondsSinceStartOfDay: Double? {
        guard let hour = self.hour else {
            return nil
        }
        guard let minute = self.minute else {
            return nil
        }
        guard let second = self.second else {
            return nil
        }
        let result: Double = Double((hour * 60 + minute) * 60 + second)
        return result
    } // var secondsSinceStartOfDay
} // extension ASADateComponents

