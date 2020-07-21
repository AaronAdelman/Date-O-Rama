//
//  ASAEventsFile.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-07-07.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let aSAEventsFile = try? newJSONDecoder().decode(ASAEventsFile.self, from: jsonData)

import Foundation
import UIKit
import CoreLocation

enum ASATimeSpecificationType:  String, Codable {
    case allDay                              = "allDay"
    case degreesBelowHorizon                 = "degreesBelowHorizon" // Event is when the center of the Sun is a specific number of degrees below the horizon
    case solarTimeSunriseSunset              = "solarTimeSunriseSunset" // Solar time, day lasts from sunrise to sunset
    case solarTimeDawn72MinutesDusk72Minutes = "solarTimeDawn72MinutesDusk72Minutes" // Solar time, day lasts from dawn (sunrise - 72 minutes) to dusk (sunset + 72 minutes)
} // enum ASATimeSpecificationType

enum ASATimeSpecificationDayHalf:  String, Codable {
    case night = "night"
    case day   = "day"
} // enum ASATimeSpecificationDayHalf


// MARK: - ASAInternalEventsFile

struct ASAInternalEventsFile: Codable {
    var eventSourceCode: ASAInternalEventSourceCode
    var title:  String?
    var localizableTitle:  String?
    var calendarColorRed:  CGFloat
    var calendarColorGreen:  CGFloat
    var calendarColorBlue:  CGFloat
    var calendarColorAlpha:  CGFloat
    var calendarCode:  ASACalendarCode?
    var eventSpecifications: [ASAInternalEventSpecification]
    
    var calendarColor: UIColor {
        get {
            return UIColor(red: self.calendarColorRed, green: self.calendarColorGreen, blue: self.calendarColorBlue, alpha: self.calendarColorAlpha)
        }
        set {
            var red:  CGFloat   = 0.0
            var green:  CGFloat = 0.0
            var blue:  CGFloat  = 0.0
            var alpha:  CGFloat = 0.0
            _ = newValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.calendarColorRed   = red
            self.calendarColorGreen = green
            self.calendarColorBlue  = blue
            self.calendarColorAlpha = alpha
        }
    }
} // struct ASAEventsFile


// MARK: - ASAInternalEventSpecification

class ASAInternalEventSpecification: Codable {
    var title:  String?
    var localizableTitle:  String?
    
    var isAllDay:  Bool {
        get {
            return self.startDateSpecification.type == .allDay
        } // get
    } // var isAllDay
    
    var startDateSpecification:  ASADateSpecification
    var endDateSpecification:  ASADateSpecification?
    
    var includeISOCountryCodes:  Array<String>?
    var excludeISOCountryCodes:  Array<String>?
    
//    var recurrenceRules: [ASARecurrenceRule]? // The recurrence rules for the calendar item.
    
    // TODO:  Do something with these properties
    var url: URL? // The URL for the calendar item.
    var notes: String? // The notes associated with the calendar item.

    var hasNotes: Bool // A Boolean value that indicates whether the calendar item has notes.
        {
        get {
            return self.notes != nil
        } // get
    } // var hasNotes

//    var hasRecurrenceRules: Bool // A Boolean value that indicates whether the calendar item has recurrence rules.
//        {
//        get {
//            return self.recurrenceRules != nil
//        } // get
//    } // var hasRecurrenceRules
} // extension ASAInternalEventSpecification

extension ASAInternalEventSpecification {
    func match(ISOCountryCode:  String?) -> Bool {
        if ISOCountryCode == nil {
            return true
        }
        
        if self.includeISOCountryCodes != nil {
            if self.includeISOCountryCodes!.contains(ISOCountryCode!) {
                return true
            }
        }
        
        if self.excludeISOCountryCodes != nil {
            if self.excludeISOCountryCodes!.contains(ISOCountryCode!) {
                return false
            }
        }
        
        return true
    } // func match(ISOCountryCode:  String?) -> Bool
} // extension ASAInternalEventSpecification


struct ASADateSpecification:  Codable {
    var year:  Int?  // Will be ignored if not relevant
    var month:  Int? // Will be ignored if not relevant
    var day:  Int?
    var weekday:  ASAWeekday?

    var type: ASATimeSpecificationType
    
    // For degrees below horizon events
    var degreesBelowHorizon: Double?
    var rising: Bool?
    var offset: TimeInterval?
    
    // For solar time events
    var solarHours:  Double?
    var dayHalf:  ASATimeSpecificationDayHalf?
} // struct ASADateSpecification

//struct ASARecurrenceRule:  Codable {
//    var frequency:  ASARecurrenceFrequency // The frequency of the recurrence rule.
//    var interval: Int // Specifies how often the recurrence rule repeats over the unit of time indicated by its frequency.  (Only meaningful for daily and weekly frequency)
//
//    var daysOfTheWeek: [ASARecurrenceDayOfWeek]? // The days of the week associated with the recurrence rule, as an array of EKRecurrenceDayOfWeek objects.
//    var daysOfTheMonth: [Int]?                   // The days of the month associated with the recurrence rule, as an array of NSNumber objects.
//    var daysOfTheYear: [Int]?                    // The days of the year associated with the recurrence rule, as an array of NSNumber objects.
//    var weeksOfTheYear: [Int]?                   // The weeks of the year associated with the recurrence rule, as an array of NSNumber objects.
//    var monthsOfTheYear: [Int]?                  // The months of the year associated with the recurrence rule, as an array of NSNumber objects.
//} // struct ASARecurrenceRule
//
//enum ASARecurrenceFrequency:  String, Codable {
//    case daily   = "daily"   // Indicates a daily recurrence rule.
//    case weekly  = "weekly"  // Indicates a weekly recurrence rule.
//    case monthly = "monthly" // Indicates a monthly recurrence rule.
//    case yearly  = "yearly"  // Indicates a yearly recurrence rule.
//} // enum ASARecurrenceFrequency
//
//struct ASARecurrenceDayOfWeek:  Codable {
//    var dayOfTheWeek: ASAWeekday // The day of the week.
//    var weekNumber: Int // The week number of the day of the week.  Values range from –53 to 53. A negative value indicates a value from the end of the range. 0 indicates the week number is irrelevant.
//} // struct ASARecurrenceDayOfWeek

enum ASAWeekday:  Int, Codable {
    case sunday    = 1
    case monday    = 2
    case tuesday   = 3
    case wednesday = 4
    case thursday  = 5
    case friday    = 6
    case saturday  = 7
} // enum ASAWeekday
