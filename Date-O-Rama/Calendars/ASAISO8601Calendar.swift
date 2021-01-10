//
//  ASAISO8601Calendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ASAISO8601Calendar:  ASACalendar {
    var calendarCode: ASACalendarCode = .ISO8601
    var defaultDateFormat:  ASADateFormat = .ISO8601YearMonthDay
    
    lazy var dateFormatter = DateFormatter()
    lazy var ISODateFormatter = ISO8601DateFormatter()
    
    private var ApplesCalendar:  Calendar
    
    init() {
        let title = self.calendarCode.equivalentCalendarIdentifier
        ApplesCalendar = Calendar(identifier: title)
        dateFormatter.calendar = ApplesCalendar

        self.ISODateFormatter.timeZone = TimeZone.current
    } // init()

    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String {
        var dateString:  String
        
        var formatterOptions:  ISO8601DateFormatter.Options = []
        switch dateFormat {
        case .none:
            formatterOptions = []
        case .full:
            formatterOptions = [.withFullDate]
        case .ISO8601YearMonthDay:
            formatterOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        case .ISO8601YearWeekDay:
            formatterOptions = [.withYear, .withWeekOfYear, .withDay, .withDashSeparatorInDate]
        case .ISO8601YearDay:
            formatterOptions = [.withYear, .withDay, .withDashSeparatorInDate]
        default:
            formatterOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        } // switch dateFormat
        
        switch timeFormat {
        case .medium :
            formatterOptions.insert(.withTime)
            formatterOptions.insert(.withColonSeparatorInTime)
        default:
            debugPrint("")
        } // switch timeFormat
        
        self.ISODateFormatter.formatOptions = formatterOptions

        let timeZone = locationData.timeZone
        self.ISODateFormatter.timeZone = timeZone

        dateString = self.ISODateFormatter.string(from: now)
        return dateString
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
    
    
    // MARK: -
        
    var supportsLocales: Bool = false
    
    func startOfDay(for date: Date, locationData:  ASALocation) -> Date {
        //        return date.previousMidnight(timeZone:  timeZone)
        let timeZone = locationData.timeZone
        self.ApplesCalendar.timeZone = timeZone
        return self.ApplesCalendar.startOfDay(for: date)
    } // func startOfDay(for date: Date, locationData:  ASALocation) -> Date

    func startOfNextDay(date:  Date, locationData:  ASALocation) -> Date {
        //        return date.nextMidnight(timeZone:  timeZone)
        self.ApplesCalendar.timeZone = locationData.timeZone
        return self.ApplesCalendar.startOfDay(for: date.oneDayAfter)
    } // func startOfNextDay(now:  Date, locationData:  ASALocation) -> Date

    var supportsDateFormats: Bool = true
    
    var supportsTimeZones: Bool = true
    
    var supportsLocations: Bool = true
        
    var supportsTimes: Bool = true
    
    var supportedDateFormats: Array<ASADateFormat> = [
//        .full,
        .ISO8601YearMonthDay,
        .ISO8601YearWeekDay,
        .ISO8601YearDay
    ]

    var supportedWatchDateFormats: Array<ASADateFormat> = [
        .ISO8601YearMonthDay,
        .ISO8601YearWeekDay,
        .ISO8601YearDay
    ]
    
    var supportedTimeFormats: Array<ASATimeFormat> = [
        .medium
    ]
    
    var supportsTimeFormats: Bool = true
    
    var canSplitTimeFromDate:  Bool = true
    
    var defaultTimeFormat:  ASATimeFormat = .medium
    
    // MARK: -
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let ApplesDateComponents = dateComponents.ApplesDateComponents()
        return ApplesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        let ApplesDateComponents = dateComponents.ApplesDateComponents()

        return ApplesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    
    // MARK:  - Extracting Components
    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int {
        // Returns the value for one component of a date.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return -1
        }
        
        var calendar = self.ApplesCalendar
        calendar.timeZone = locationData.timeZone 
        return calendar.component(ApplesComponent!, from: date)
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents {
        var ApplesComponents = Set<Calendar.Component>()
        for component in components {
            let ApplesCalendarComponent = component.calendarComponent()
            if ApplesCalendarComponent != nil {
                ApplesComponents.insert(ApplesCalendarComponent!)
            }
        } // for component in components
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = locationData.timeZone 
        let ApplesDateComponents = calendar.dateComponents(ApplesComponents, from: date)
        return ASADateComponents.new(with: ApplesDateComponents, calendar: self, locationData: locationData)
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents
    
    
    // MARK:  - Getting Calendar Information
    
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
         // The maximum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.ApplesCalendar.maximumRange(of: ApplesComponent!)
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.ApplesCalendar.minimumRange(of: ApplesComponent!)
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        let ApplesSmaller = smaller.calendarComponent()
        let ApplesLarger = larger.calendarComponent()
        if ApplesSmaller == nil || ApplesLarger == nil {
            return nil
        }
        return self.ApplesCalendar.ordinality(of: ApplesSmaller!, in: ApplesLarger!, for: date)
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        let ApplesSmaller = smaller.calendarComponent()
        let ApplesLarger = larger.calendarComponent()
        if ApplesSmaller == nil || ApplesLarger == nil {
            return nil
        }
        return self.ApplesCalendar.range(of: ApplesSmaller!, in: ApplesLarger!, for: date)
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>?
    
//    func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent? {
//        // Returns which component contains the specified component for specifying a date.  E.g., in many calendars days are contained within months, months are contained within years, and years are contained within eras.
//        switch component {
//        case .month:
//            return .year
//            
//        case .day:
//            return .month
//            
//        default:
//            return nil
//        } // switch component
//    } // func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent?
    
    
    // MARK: -
    func supports(calendarComponent:  ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era, .year, .yearForWeekOfYear, .quarter, .month, .weekOfYear, .weekOfMonth, .weekday, .weekdayOrdinal, .day:
            return true
            
        case .hour, .minute, .second, .nanosecond:
            return true
            
        case .calendar, .timeZone:
            return true
            
//        default:
//            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool


    // MARK: -

    public var transitionType:  ASATransitionType = .midnight

    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String> {
        return ["1", "2", "3", "4", "5", "6", "7"]
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>

    var usesISOTime:  Bool = true

    var daysPerWeek:  Int? = 7
} // class ASAISO8601Calendar
