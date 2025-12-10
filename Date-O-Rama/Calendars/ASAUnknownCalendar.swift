//
//  ASAUnknownCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/12/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

public class ASAUnknownCalendar: ASACalendar {
    var calendarCode: ASACalendarCode
    
    var canSplitTimeFromDate: Bool = true
    
    var defaultDateFormat: ASADateFormat = .full
    
    var defaultTimeFormat: ASATimeFormat = .medium
    
    var supportedDateFormats: Array<ASADateFormat> = []
    
    var supportedWatchDateFormats: Array<ASADateFormat> = []
    
    var supportedTimeFormats: Array<ASATimeFormat> = []
    
    var supportsLocales: Bool = false
    
    var supportsLocations: Bool = false
    
    var supportsTimes: Bool = false
    
    var supportsTimeZones: Bool = false
    
    var transitionType: ASATransitionType = .midnight
    
    var usesISOTime: Bool = false
    
    init(calendarCode: ASACalendarCode) {
        self.calendarCode = calendarCode
    } // init(calendarCode: ASACalendarCode)
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        return ""
    }
    
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        return Date.distantPast
    }
    
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        return Date.distantPast
    }
    
    func supports(calendarComponent: ASACalendarComponent) -> Bool {
        return false
    }
    
    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        return ("", "", ASADateComponents(calendar: self, locationData: locationData))
    }
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        return false
    }
    
    func date(dateComponents: ASADateComponents) -> Date? {
        return nil
    }
    
    func component(_ component: ASACalendarComponent, from date: Date, locationData: ASALocation) -> Int {
        return -1
    }
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        return ASADateComponents(calendar: self, locationData: locationData)
    }
    
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        return nil
    }
    
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        return nil
    }
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        return nil
    }
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        return nil
    }
    
    func localModifiedJulianDay(date: Date, locationData: ASALocation) -> Int {
        return -1
    }
    
    func cycleNumberFormat(locale: Locale) -> ASANumberFormat {
        return .system
    }
}
