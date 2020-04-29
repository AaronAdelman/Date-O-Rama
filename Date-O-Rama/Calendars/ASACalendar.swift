//
//  ASACalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

struct ASALDMLDetail {
    var name:  String
    var geekCode:  String
} // struct ASADetail

struct ASAEventDetail {
    var key:  String
    var value:  Date?
} // struct ASAEventDetail



// MARK: -

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    
    func defaultDateGeekCode(majorDateFormat:  ASAMajorFormat) -> String
    func dateString(now:  Date, localeIdentifier:  String, majorDateFormat:  ASAMajorFormat, dateGeekFormat:  String, majorTimeFormat:  ASAMajorFormat, timeGeekFormat:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func dateString(now:  Date, localeIdentifier:  String, LDMLString:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func LDMLDetails() -> Array<ASALDMLDetail>
    func eventDetails(date:  Date, location:  CLLocation?) -> Array<ASAEventDetail>
    func supportsLocales() -> Bool
    func supportsDateFormats() -> Bool
    func supportsTimeZones() -> Bool
    func supportsLocations() -> Bool
    func supportsEventDetails() -> Bool
    func timeZone(location:  CLLocation?) -> TimeZone
    func transitionToNextDay(now:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date
} // protocol ASACalendar
