//
//  ASACalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-21.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

struct ASADetail {
    var name:  String
    var geekCode:  String
} // struct ASADetail


// MARK: -

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    
    func defaultDateGeekCode(majorDateFormat:  ASAMajorFormat) -> String
    func dateString(now:  Date, localeIdentifier:  String, majorDateFormat:  ASAMajorFormat, dateGeekFormat:  String, majorTimeFormat:  ASAMajorFormat, timeGeekFormat:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func dateString(now:  Date, localeIdentifier:  String, LDMLString:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func details() -> Array<ASADetail>
    func supportsLocales() -> Bool
    func supportsDateFormats() -> Bool
    func supportsTimeZones() -> Bool
    func supportsLocations() -> Bool
    func transitionToNextDay(now:  Date, location:  CLLocation?) -> Date
} // protocol ASACalendar
