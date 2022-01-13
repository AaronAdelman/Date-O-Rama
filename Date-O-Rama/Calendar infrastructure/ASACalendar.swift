//
//  ASACalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public enum ASATransitionType {
    case sunset
    case dusk
    case midnight
    case noon
} // enum ASATransitionType

public enum ASAMiniCalendarNumberFormat {
    case system
    case shortHebrew
} // public enum ASAMiniCalendarNumberFormat


// MARK: -

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    var canSplitTimeFromDate:  Bool { get }
    var defaultDateFormat:  ASADateFormat { get }
    var defaultTimeFormat:  ASATimeFormat { get }
    var supportedDateFormats: Array<ASADateFormat> { get }
    var supportedWatchDateFormats: Array<ASADateFormat> { get }
    var supportedTimeFormats: Array<ASATimeFormat> { get }
    var supportsLocales: Bool { get }
    var supportsDateFormats: Bool { get }
    var supportsLocations: Bool { get }
    var supportsTimeFormats: Bool { get }
    var supportsTimes: Bool { get }
    var supportsTimeZones: Bool { get }
    var transitionType:  ASATransitionType { get }
    var usesISOTime:  Bool { get }
    
    func dateTimeString(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> String
    func startOfDay(for date:  Date, locationData:  ASALocation) -> Date
    func startOfNextDay(date:  Date, locationData:  ASALocation) -> Date
    
    func supports(calendarComponent:  ASACalendarComponent) -> Bool

    func dateStringTimeStringDateComponents(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat, timeFormat: ASATimeFormat, locationData:  ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)

    
    // MARK:  - Date components
    func isValidDate(dateComponents:  ASADateComponents) -> Bool
    func date(dateComponents:  ASADateComponents) -> Date?

    
    // MARK:  - Extracting Components
    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocation) -> Int // Returns the value for one component of a date.
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents // Returns all the date components of a date.
    
    
    // MARK:  - Getting Calendar Information
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? // The maximum range limits of the values that a given component can take on.
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? // Returns the minimum range limits of the values that a given component can take on.
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
    var daysPerWeek:  Int? { get }
    
    
    // MARK:  -
    
    /// Calculates time zone-dependent modified Julian day for a date in a specified time zone
    /// - Returns: A time zone-dependent modified Julian day as an integer
    func localModifiedJulianDay(date: Date, locationData:  ASALocation) -> Int

    
    // MARK:  - Symbols
    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
    
    
    // MARK:  - Workdays and weekends
    func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK:  - Mini-calendars
    func miniCalendarNumberFormat(locale: Locale) -> ASAMiniCalendarNumberFormat
} // protocol ASACalendar


// MARK:  -

extension ASACalendar {
    func maximumValue(of smallComponent: ASACalendarComponent, in largeComponent: ASACalendarComponent, for now: Date) -> Int? {
        let range = self.range(of: smallComponent, in: largeComponent, for: now)
        let result = range?.count
        return result
    } // func maximumValue(of smallComponent: ASACalendarComponent, in largeComponent: ASACalendarComponent, for now: Date) -> Int?
} // extension ASACalendar
