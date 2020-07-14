//
//  ASADateComponents.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-07-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

struct ASADateComponents {
    // MARK:  - Initializing Date Components
    
    var calendar:  ASACalendar
    var locationData:  ASALocationData
    
    
    // MARK:  - Validating a Date
    // WARNING:  Do not call these methods from any variation on ASACalendar!
    
    var isValidDate: Bool {
        get {
            return self.calendar.isValidDate(dateComponents: self)
        } // get
    } // var isValidDate
    // Indicates whether the current combination of properties represents a date which exists in the current calendar.
    
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
    
    
    // MARK:  - Accessing Calendar Components
    func value(for value: ASACalendarComponent) -> Int? {
        //    Returns the value of one of the properties, using an enumeration value instead of a property name.
        
        switch value {
        case .era:
            return self.era
        case .year:
            return self.year
        case .yearForWeekOfYear:
            return self.yearForWeekOfYear
        case .quarter:
            return self.quarter
        case .month:
            return self.month
        case .weekOfYear:
            return self.weekOfYear
        case .weekOfMonth:
            return self.weekOfMonth
        case .weekday:
            return self.weekday
        case .weekdayOrdinal:
            return self.weekdayOrdinal
        case .day:
            return self.day
        case .hour:
            return self.hour
        case .minute:
            return self.minute
        case .second:
            return self.second
        case .nanosecond:
            return self.nanosecond
        case .calendar, .timeZone:
            debugPrint(#file, #function, "Some wiseguy seems to think a calendar or time zone is an integer.")
            return nil // Cannot be cast to Int?
        } // switch value
    } // func value(for value: ASACalendarComponent) -> Int?
    
    mutating func setValue(_ value:  Int?, for component: ASACalendarComponent) {
        //    Set the value of one of the properties, using an enumeration value instead of a property name.
        
        switch component {
        case .era:
            self.era = value
        case .year:
            self.year = value
        case .yearForWeekOfYear:
            self.yearForWeekOfYear = value
        case .quarter:
            self.quarter = value
        case .month:
            self.month = value
        case .weekOfYear:
            self.weekOfYear = value
        case .weekOfMonth:
            self.weekOfMonth = value
        case .weekday:
            self.weekday = value
        case .weekdayOrdinal:
            self.weekdayOrdinal = value
        case .day:
            self.day = value
        case .hour:
            self.hour = value
        case .minute:
            self.minute = value
        case .second:
            self.second = value
        case .nanosecond:
            self.nanosecond = value
        case .calendar, .timeZone:
            debugPrint(#file, #function, "Some wiseguy seems to think a calendar or time zone is an integer.")
        } // switch component
    } // mutating func setValue(_ value:  Int?, for component: ASACalendarComponent)
} // struct ASADateComponents


// MARK: -

extension ASADateComponents {
    func ApplesDateComponents() -> DateComponents {
        let calendarIdentifier = self.calendar.calendarCode.equivalentCalendarIdentifier()
        
        let calendar = Calendar(identifier: calendarIdentifier)
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
    
    static func new(with ApplesDateComponents:  DateComponents, calendar:  ASACalendar, locationData:  ASALocationData) -> ASADateComponents {
        let result = ASADateComponents(calendar: calendar, locationData: locationData, era: ApplesDateComponents.era, year: ApplesDateComponents.year, yearForWeekOfYear: ApplesDateComponents.yearForWeekOfYear, quarter: ApplesDateComponents.quarter, month: ApplesDateComponents.month, isLeapMonth: ApplesDateComponents.isLeapMonth, weekOfMonth: ApplesDateComponents.weekOfMonth, weekOfYear: ApplesDateComponents.weekOfYear, weekday: ApplesDateComponents.weekday, weekdayOrdinal: ApplesDateComponents.weekdayOrdinal, day: ApplesDateComponents.day, hour: ApplesDateComponents.hour, minute: ApplesDateComponents.minute, second: ApplesDateComponents.second, nanosecond: ApplesDateComponents.nanosecond)
        return result
    } // static func new(with ApplesDateComponents:  DateComponents, calendar:  ASACalendar, locationData:  ASALocationData) -> ASADateComponents
} // extension ASADateComponents
