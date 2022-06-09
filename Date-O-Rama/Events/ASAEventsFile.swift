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
import EventKit
import SwiftUI


// MARK: - ASAEventsFile

struct ASAEventsFile: Codable {
    var titles:  Dictionary<String, String>
    var defaultLocale:  String
    
    var calendarColor: Color
    var calendarCode:  ASACalendarCode
    var otherCalendarCodes:  Array<ASACalendarCode>?
    var emoji: String?
    var eventSpecifications: Array<ASAEventSpecification>
} // struct ASAEventsFile


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
    
    func title(localeIdentifier:  String) -> String {
        return self.titles[localeIdentifier] ?? "???"
    }
    
    func autolocalizableRegionCode() -> String? {
        let titles = self.titles

        let LOCALIZED_KEY = "*"
        let regionCode = titles[LOCALIZED_KEY]
        return regionCode
    }
    
    func eventCalendarNameWithoutPlaceName(localeIdentifier:  String) -> String {
        let userLocaleIdentifier = localeIdentifier == "" ? Locale.autoupdatingCurrent.identifier : localeIdentifier

        let regionCode = autolocalizableRegionCode()
        if regionCode != nil {
            let locale = Locale(identifier: userLocaleIdentifier)
            return locale.localizedString(forRegionCode: regionCode!) ?? "???"
        }
        
        let titles = self.titles
        
        let firstAttempt = titles[userLocaleIdentifier]
        if firstAttempt != nil {
            return firstAttempt!
        }

        let userLanguageCode = userLocaleIdentifier.localeLanguageCode
        if userLanguageCode != nil {
            let secondAttempt = titles[userLanguageCode!]
            if secondAttempt != nil {
                return secondAttempt!
            }
        }

        let thirdAttempt = titles["en"]
        if thirdAttempt != nil {
            return thirdAttempt!
        }

        return "???"
    } // func eventCalendarNameWithoutPlaceName(localeIdentifier:  String) -> String
} // extension ASAEventsFile
