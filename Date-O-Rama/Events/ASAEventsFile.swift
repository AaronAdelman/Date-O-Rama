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


// MARK: - ASAEventsFile

struct ASAEventsFile: Codable {
    var supportedLocales:  Array<String>
    var titles:  Dictionary<String, String>
    var defaultLocale:  String
    
    var calendarColorRed:  CGFloat
    var calendarColorGreen:  CGFloat
    var calendarColorBlue:  CGFloat
    var calendarColorAlpha:  CGFloat
    var calendarCode:  ASACalendarCode
    var otherCalendarCodes:  Array<ASACalendarCode>?
    var eventSpecifications: Array<ASAInternalEventSpecification>
    
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
    var titles:  Dictionary<String, String>?
    
    var isAllDay:  Bool {
        get {
            return self.startDateSpecification.type == .allDay || self.startDateSpecification.type == .allMonth || self.startDateSpecification.type == .allYear
        } // get
    } // var isAllDay

    var calendarCode:  ASACalendarCode?
    var startDateSpecification:  ASADateSpecification
    var endDateSpecification:  ASADateSpecification?
    
    var includeISOCountryCodes:  Array<String>?
    var excludeISOCountryCodes:  Array<String>?
        
    var url: URL? // The URL for the calendar item.
    var notes: String? // The notes associated with the calendar item.

//    var hasNotes: Bool // A Boolean value that indicates whether the calendar item has notes.
//        {
//        get {
//            return self.notes != nil
//        } // get
//    } // var hasNotes
} // extension ASAInternalEventSpecification

extension ASAInternalEventSpecification {
    func match(ISOCountryCode:  String?) -> Bool {
        if ISOCountryCode == nil {
            if self.includeISOCountryCodes != nil && self.includeISOCountryCodes != [] {
                return false
            }
            
            return true
        } else {
            if self.includeISOCountryCodes != nil {
                let result = self.includeISOCountryCodes!.contains(ISOCountryCode!)
                return result
            }
            
            if self.excludeISOCountryCodes != nil {
                let result = !self.excludeISOCountryCodes!.contains(ISOCountryCode!)
                return result
            }
            
            return true
        }
    } // func match(ISOCountryCode:  String?) -> Bool
} // extension ASAInternalEventSpecification

extension ASAInternalEventSpecification {
    func eventTitle(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String? {
        if self.titles != nil {
            let titles = self.titles!

            let userLocaleIdentifier = requestedLocaleIdentifier == "" ? Locale.autoupdatingCurrent.identifier : requestedLocaleIdentifier
            let firstAttempt = titles[userLocaleIdentifier]
            if firstAttempt != nil {
                return firstAttempt
            }

            let userLanguageCode = userLocaleIdentifier.localeLanguageCode
            if userLanguageCode != nil {
                let secondAttempt = titles[userLanguageCode!]
                if secondAttempt != nil {
                    return secondAttempt
                }
            }

            let thirdAttempt = titles[eventsFileDefaultLocaleIdentifier]
            if thirdAttempt != nil {
                return thirdAttempt
            }

            let fourthAttempt = titles["en"]
            if fourthAttempt != nil {
                return fourthAttempt
            }
        }

        return nil
    } // eventsFileDefaultLocaleIdentifier:  String) -> String?
} // extension ASAInternalEventSpecification


// MARK: -

enum ASAWeekday:  Int, Codable {
    case sunday    = 1
    case monday    = 2
    case tuesday   = 3
    case wednesday = 4
    case thursday  = 5
    case friday    = 6
    case saturday  = 7
} // enum ASAWeekday


// MARK:  -

extension ASAEventsFile {
    static func builtIn(fileName: String) -> (ASAEventsFile?, Error?) {
        do {
            let fileURL = Bundle.main.url(forResource:fileName, withExtension: "json")
            if fileURL == nil {
                debugPrint(#file, #function, fileName, "Could not open!")
                return (nil, nil)
            }

            let jsonData = (try? Data(contentsOf: fileURL!))!
            let newJSONDecoder = JSONDecoder()

            let eventsFile = try newJSONDecoder.decode(ASAEventsFile.self, from: jsonData)
            return (eventsFile, nil)
        } catch {
            debugPrint(#file, #function, fileName, error)
            return (nil, error)
        }
    } // static func builtIn(fileName: String) -> ASAEventsFile?
} // extension ASAEventsFile
