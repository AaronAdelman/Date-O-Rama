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

enum ASAEncodedEventType:  String, Codable {
    case degreesBelowHorizon = "degreesBelowHorizon" // Event is when the center of the Sun is a specific number of degrees below the horizon
} // enum ASAEncodedEventType

// MARK: - ASAEventsFile
struct ASAEventsFile: Codable {
    var eventSourceCode: String
    var title:  String?
    var localizableTitle:  String?
    var calendarColorRed:  CGFloat
    var calendarColorGreen:  CGFloat
    var calendarColorBlue:  CGFloat
    var calendarColorAlpha:  CGFloat
    var events: [ASAEncodedEvent]
    
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

// MARK: - Event
struct ASAEncodedEvent: Codable {
    var title:  String?
    var localizableTitle:  String?
    var type: ASAEncodedEventType
    var degreesBelowHorizon: Double?
    var rising: Bool?
    var offset: TimeInterval?
} // struct ASAEncodedEvent
