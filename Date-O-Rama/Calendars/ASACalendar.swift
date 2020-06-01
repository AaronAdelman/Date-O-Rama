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
//    var color:  UIColor { get }
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
//    func eventDetails(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Array<ASAEvent>
    func startOfDay(for date: Date, location:  CLLocation?, timeZone:  TimeZone) -> Date
    func startOfNextDay(date:  Date, location:  CLLocation?, timeZone:  TimeZone) -> Date
} // protocol ASACalendar
