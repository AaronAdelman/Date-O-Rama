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

struct ASAEvent {
    var uuid = UUID()
    var title:  String
    var startDate:  Date?
    var calendar:  ASACalendar
    var timeZone: TimeZone?
} // struct ASAEvent


// MARK: -

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    var color:  UIColor { get }
    var defaultMajorDateFormat:  ASAMajorDateFormat { get }

    func defaultDateGeekCode(majorDateFormat:  ASAMajorDateFormat) -> String
    func dateTimeString(now:  Date, localeIdentifier:  String, majorDateFormat:  ASAMajorDateFormat, dateGeekFormat:  String, majorTimeFormat: ASAMajorTimeFormat, timeGeekFormat:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func dateTimeString(now:  Date, localeIdentifier:  String, LDMLString:  String, location:  CLLocation?, timeZone:  TimeZone?) -> String
    func LDMLDetails() -> Array<ASALDMLDetail>
    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent>
    func supportsLocales() -> Bool
    func supportsDateFormats() -> Bool
    func supportsTimeZones() -> Bool
    func supportsLocations() -> Bool
    func supportsEventDetails() -> Bool
    func supportsTimes() -> Bool
    func startOfNextDay(now:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date
    func supportedMajorDateFormats() -> Array<ASAMajorDateFormat>
} // protocol ASACalendar
