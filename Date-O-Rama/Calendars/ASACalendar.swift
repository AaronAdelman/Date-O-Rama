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

struct ASALDMLDetail {
    var name:  String
    var geekCode:  String
} // struct ASADetail


// MARK: -

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    var canSplitTimeFromDate:  Bool { get }
    var defaultMajorDateFormat:  ASAMajorDateFormat { get }
    var defaultMajorTimeFormat:  ASAMajorTimeFormat { get }
    var LDMLDetails: Array<ASALDMLDetail> { get }
    var supportedMajorDateFormats: Array<ASAMajorDateFormat> { get }
    var supportedMajorTimeFormats: Array<ASAMajorTimeFormat> { get }
    var supportsEventDetails: Bool { get }
    var supportsLocales: Bool { get }
    var supportsDateFormats: Bool { get }
    var supportsLocations: Bool { get }
    var supportsTimeFormats: Bool { get }
    var supportsTimes: Bool { get }
    var supportsTimeZones: Bool { get }
    
    func defaultDateGeekCode(majorDateFormat:  ASAMajorDateFormat) -> String
    func defaultTimeGeekCode(majorTimeFormat:  ASAMajorTimeFormat) -> String
    func dateTimeString(now:  Date, localeIdentifier:  String, majorDateFormat:  ASAMajorDateFormat, dateGeekFormat:  String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func dateTimeString(now:  Date, localeIdentifier:  String, LDMLString:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func startOfDay(for date: Date, location:  CLLocation?, timeZone:  TimeZone) -> Date
    func startOfNextDay(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date
    
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
    
    func containingComponent(of component:  ASACalendarComponent) -> ASACalendarComponent? // Returns which component contains the specified component for specifying a date.  E.g., in many calendars days are contained within months, months are contained within years, and years are contained within eras.

} // protocol ASACalendar
