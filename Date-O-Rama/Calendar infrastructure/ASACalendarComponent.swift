//
//  ASACalendarComponent.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-07-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASACalendarComponent {
// MARK:  - Specifying Years and Months
    
    case era
//    Identifier for the era unit.
    
    case year
//    Identifier for the year unit.
    
    case yearForWeekOfYear
//    Identifier for the week-counting year unit.
    
    case quarter
//    Identifier for the quarter of the calendar.
    
    case month
//    Identifier for the month unit.
    
    
    // MARK: - Specifying Weeks and Days
    
    case weekOfYear
//    Identifier for the week of the year unit.
    
    case weekOfMonth
//    Identifier for the week of the month calendar unit.
    
    case weekday
//    Identifier for the weekday unit.
    
    case weekdayOrdinal
//    Identifier for the weekday ordinal unit.
    
    case day
//    Identifier for the day unit.
    
    
//    MARK:  - Specifying Hours, Minutes, and Seconds
    
    case hour
//    Identifier for the hour unit.
    
    case minute
//    Identifier for the minute unit.
    
    case second
//    Identifier for the second unit.
    
    case nanosecond
//    Identifier for the nanosecond unit.
    
    case fractionalHour
    
    case dayHalf
    
    
//    Specifying Calendars and Time Zones
    
    case calendar
//    Identifier for the calendar unit.
    
    case timeZone
//    Identifier for the time zone unit.
} // enum ASACalendarComponent

extension ASACalendarComponent {
    func calendarComponent() -> Calendar.Component? {
        switch self {
        case .era:
            return .era
        case .year:
            return .year
        case .yearForWeekOfYear:
            return .yearForWeekOfYear
        case .quarter:
            return .quarter
        case .month:
            return .month
        case .weekOfYear:
            return .weekOfYear
        case .weekOfMonth:
            return .weekOfMonth
        case .weekday:
            return .weekday
        case .weekdayOrdinal:
            return .weekdayOrdinal
        case .day:
            return .day
        case .hour:
            return .hour
        case .minute:
            return .minute
        case .second:
            return .second
        case .nanosecond:
            return .nanosecond
        case .calendar:
            return .calendar
        case .timeZone:
            return .timeZone
        case .fractionalHour:
            return nil
        case .dayHalf:
            return nil
        } // switch self
    } // func calendarComponent() -> Calendar.Component?
} // extension ASACalendarComponent


extension String {
    func calendarComponent() -> ASACalendarComponent? {
        switch self {
        case "y":
            return .year
            
        case "M":
            return .month
            
        case "d":
            return .day
            
        default:
            return nil
        } // switch self
    } // func calendarComponent() -> ASACalendarComponent?
} // extension String
