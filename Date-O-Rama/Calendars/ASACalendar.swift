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

//struct ASALDMLDetail {
//    var name:  String
//    var geekCode:  String
//} // struct ASADetail

public enum ASATransitionType {
    case sunset
    case dusk
    case midnight
    case noon
} // enum ASATransitionType


// MARK: -

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    var canSplitTimeFromDate:  Bool { get }
    var defaultDateFormat:  ASADateFormat { get }
    var defaultTimeFormat:  ASATimeFormat { get }
    //    var LDMLDetails: Array<ASALDMLDetail> { get }
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
    
    //    func defaultDateGeekCode(dateFormat:  ASADateFormat) -> String
    //    func defaultTimeGeekCode(timeFormat:  ASATimeFormat) -> String
    func dateTimeString(now:  Date, localeIdentifier:  String, dateFormat:  ASADateFormat,
                        //                        dateGeekFormat: String,
                        timeFormat: ASATimeFormat,
                        //                        timeGeekFormat: String,
                        locationData:  ASALocationData) -> String
    //    func dateTimeString(now:  Date, localeIdentifier:  String, LDMLString:  String, locationData:  ASALocationData) -> String
    func startOfDay(for date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Date
    func startOfNextDay(date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Date
    
    func supports(calendarComponent:  ASACalendarComponent) -> Bool

    
    // MARK:  - Date components
    func isValidDate(dateComponents:  ASADateComponents) -> Bool
    func date(dateComponents:  ASADateComponents) -> Date?

    
    // MARK:  - Extracting Components
    func component(_ component: ASACalendarComponent, from date: Date, locationData:  ASALocationData) -> Int // Returns the value for one component of a date.
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents // Returns all the date components of a date.
    
    
    // MARK:  - Getting Calendar Information
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? // The maximum range limits of the values that a given component can take on.
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? // Returns the minimum range limits of the values that a given component can take on.
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
    
    //    func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent? // Returns which component contains the specified component for specifying a date.  E.g., in many calendars days are contained within months, months are contained within years, and years are contained within eras.

    func veryShortStandaloneWeekdaySymbols(localeIdentifier:  String) -> Array<String>
} // protocol ASACalendar
