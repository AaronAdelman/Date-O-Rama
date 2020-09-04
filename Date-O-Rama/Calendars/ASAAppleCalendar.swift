//
//  ASAAppleCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ASAAppleCalendar:  ASACalendar {
    var defaultMajorDateFormat:  ASAMajorDateFormat = .full  // TODO:  Rethink this when dealing with watchOS
        
    var calendarCode:  ASACalendarCode
    
    var dateFormatter = DateFormatter()
        
    private var ApplesCalendar:  Calendar
    
    init(calendarCode:  ASACalendarCode) {
        self.calendarCode = calendarCode
        let calendarIdentifier = self.calendarCode.equivalentCalendarIdentifier()
        ApplesCalendar = Calendar(identifier: calendarIdentifier)
        dateFormatter.calendar = ApplesCalendar
    } // init(calendarCode:  ASACalendarCode)
    
    func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorDateFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        
        if localeIdentifier == "" {
            self.dateFormatter.locale = Locale.current
        } else {
            self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        if timeZone == nil {
            self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.dateFormatter.timeZone = timeZone
        }
        
        if majorTimeFormat == .localizedLDML || majorDateFormat == .localizedLDML {
            let dateFormat = DateFormatter.dateFormat(fromTemplate:dateGeekFormat + timeGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            return self.dateFormatter.string(from: now)
        }
        
        switch majorTimeFormat {
        case .localizedLDML:
            let timeFormat = DateFormatter.dateFormat(fromTemplate:timeGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(timeFormat)
            
        case .none:
            self.dateFormatter.timeStyle = .none
            
        case .full:
            self.dateFormatter.timeStyle = .full
            
        case .long:
            self.dateFormatter.timeStyle = .long
            
        case .medium:
            self.dateFormatter.timeStyle = .medium
            
        case .short:
            self.dateFormatter.timeStyle = .short
            
        default:
            self.dateFormatter.timeStyle = .medium // TODO:  EXPAND ON THIS!
        } // switch majorTimeFormat
        
        switch majorDateFormat {
        case .localizedLDML:
            let dateFormat = DateFormatter.dateFormat(fromTemplate:dateGeekFormat, options: 0, locale: self.dateFormatter.locale)!
            self.dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            
        case .none:
            self.dateFormatter.dateStyle = .none
            
        case .full:
            self.dateFormatter.dateStyle = .full
            
        case .long:
            self.dateFormatter.dateStyle = .long
            
        case .medium:
            self.dateFormatter.dateStyle = .medium
            
        case .short:
            self.dateFormatter.dateStyle = .short
            
        default:
            self.dateFormatter.dateStyle = .full
        } // switch majorDateFormat
        
        return self.dateFormatter.string(from: now)
    } // func dateTimeString(now: Date, localeIdentifier: String, majorDateFormat: ASAMajorFormat, dateGeekFormat: String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat: String, location: CLLocation?) -> String
    
    func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?, timeZone:  TimeZone?) -> String {
        // TODO:  Update when times are supported!
        
        self.dateFormatter.dateFormat = LDMLString
        if timeZone == nil {
            self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        } else {
            self.dateFormatter.timeZone = timeZone
        }
        
        let result = self.dateFormatter.string(from: now)
        
        return result
    } // func dateTimeString(now: Date, localeIdentifier:  String, LDMLString: String, location: CLLocation?) -> String
    
    func defaultDateGeekCode(majorDateFormat: ASAMajorDateFormat) -> String {
        return "eee, d MMM y"
    } // func defaultDateGeekCode(majorDateFormat: ASAMajorFormat) -> String
    
    func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String {
        return "HH:mm:ss"
    } // func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String
    
    var LDMLDetails: Array<ASALDMLDetail> {
        get {
            if self.calendarCode == .Chinese {
                return [
                    ASALDMLDetail(name: "HEADER_G", geekCode: "GGGG"),
                    ASALDMLDetail(name: "HEADER_y", geekCode: "y"),
                    ASALDMLDetail(name: "HEADER_M", geekCode: "MMMM"),
                    ASALDMLDetail(name: "HEADER_d", geekCode: "d"),
                    ASALDMLDetail(name: "HEADER_E", geekCode: "eeee"),
                    ASALDMLDetail(name: "HEADER_Q", geekCode: "QQQQ"),
                    ASALDMLDetail(name: "HEADER_Y", geekCode: "Y"),
                    ASALDMLDetail(name: "HEADER_w", geekCode: "w"),
                    ASALDMLDetail(name: "HEADER_W", geekCode: "W"),
                    ASALDMLDetail(name: "HEADER_F", geekCode: "F"),
                    ASALDMLDetail(name: "HEADER_D", geekCode: "D"),
                    ASALDMLDetail(name: "HEADER_U", geekCode: "UUUU"),
                    //                        ASALDMLDetail(name: "HEADER_r", geekCode: "r"),
                    //            ASADetail(name: "HEADER_g", geekCode: "g")
                ]
            }
            
            return [
                ASALDMLDetail(name: "HEADER_G", geekCode: "GGGG"),
                ASALDMLDetail(name: "HEADER_y", geekCode: "y"),
                ASALDMLDetail(name: "HEADER_M", geekCode: "MMMM"),
                ASALDMLDetail(name: "HEADER_d", geekCode: "d"),
                ASALDMLDetail(name: "HEADER_E", geekCode: "eeee"),
                ASALDMLDetail(name: "HEADER_Q", geekCode: "QQQQ"),
                ASALDMLDetail(name: "HEADER_Y", geekCode: "Y"),
                ASALDMLDetail(name: "HEADER_w", geekCode: "w"),
                ASALDMLDetail(name: "HEADER_W", geekCode: "W"),
                ASALDMLDetail(name: "HEADER_F", geekCode: "F"),
                ASALDMLDetail(name: "HEADER_D", geekCode: "D"),
                //            ASADetail(name: "HEADER_U", geekCode: "UUUU"),
                //            ASALDMLDetail(name: "HEADER_r", geekCode: "r"),
                //            ASADetail(name: "HEADER_g", geekCode: "g")
            ]
        } // get
    } // var LDMLDetails: Array<ASALDMLDetail>
        
    var supportsLocales: Bool = true
    
    func startOfDay(for date: Date, location: CLLocation?, timeZone: TimeZone) -> Date {
        //        return date.previousMidnight(timeZone:  timeZone)
        self.ApplesCalendar.timeZone = timeZone
        return self.ApplesCalendar.startOfDay(for: date)
    } // func startOfDay(for date: Date, location: CLLocation?, timeZone: TimeZone) -> Date
    
    func startOfNextDay(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date {
        //        return date.nextMidnight(timeZone:  timeZone)
        self.ApplesCalendar.timeZone = timeZone
        return self.ApplesCalendar.startOfDay(for: date.oneDayAfter)
    } // func startOfNextDay(now:  Date, location:  CLLocation, timeZone:  TimeZone) -> Date
    
    var supportsDateFormats: Bool = true
    
    var supportsTimeZones: Bool = true
    
    var supportsLocations: Bool = false
    
    var supportsEventDetails: Bool = false
    
    var supportsTimes: Bool = true
    
    var supportedMajorDateFormats: Array<ASAMajorDateFormat> = [
        .full,
        .long,
        .medium,
        .short,
        .localizedLDML
    ]
    
    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> = [.full, .long, .medium, .short, .localizedLDML]
    
    var supportsTimeFormats: Bool = true
    
    var canSplitTimeFromDate:  Bool = true
    
    var defaultMajorTimeFormat:  ASAMajorTimeFormat = .full
    
    
    // MARK: - Date components
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let ApplesDateComponents = dateComponents.ApplesDateComponents()
        return ApplesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        let ApplesDateComponents = dateComponents.ApplesDateComponents()

        return ApplesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    
    // MARK:  - Extracting Components
    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int {
        // Returns the value for one component of a date.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return -1
        }
        
        let calendar = self.ApplesCalendar
        return calendar.component(ApplesComponent!, from: date)
    } // func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int

    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents {
        // Returns all the date components of a date.
        var ApplesComponents = Set<Calendar.Component>()
        for component in components {
            let ApplesCalendarComponent = component.calendarComponent()
            if ApplesCalendarComponent != nil {
                ApplesComponents.insert(ApplesCalendarComponent!)
            }
        } // for component in components
        
        let calendar = self.ApplesCalendar
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
//        case .year:
//            return .era
//            
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
            
        default:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent:  ASACalendarComponent) -> Bool
} // class ASAAppleCalendar
