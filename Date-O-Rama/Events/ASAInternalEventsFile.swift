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
    
    var calendarCode:  ASACalendarCode?
    
    var isAllDay:  Bool
    
    var startDateSpecification:  ASADateSpecification
    var endDateSpecification:  ASADateSpecification?
    
    // TODO:  Do something with these properties
    var url: URL? // The URL for the calendar item.
    var hasNotes: Bool // A Boolean value that indicates whether the calendar item has notes.
    var notes: String? // The notes associated with the calendar item.
} // struct ASAInternalEventSpecification

struct ASADateSpecification:  Codable {
    var type: ASATimeSpecificationType
    
    // For degrees below horizon events
    var degreesBelowHorizon: Double?
    var rising: Bool?
    var offset: TimeInterval?
    
    // For solar time events
    var solarHours:  Double?
    var dayHalf:  ASATimeSpecificationDayHalf?
} // struct ASADateSpecification
