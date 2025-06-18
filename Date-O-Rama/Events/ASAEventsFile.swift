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
    /// A key is a language code, the corresponding value being the title in that language.  If a key is "*", then the corresponding value is a country/region code which is automatically localized to the appropriate name of the country/region.
    var titles:  Dictionary<String, String>
    var defaultLocale:  String
    
    var calendarColor: Color
    var calendarCode:  ASACalendarCode
    var otherCalendarCodes:  Array<ASACalendarCode>?
    var emoji: String?

    /// Default URLs for calendar items, indexed by locale code.
    var urls: Dictionary<String, URL>?

    var eventSpecifications: Array<ASAEventSpecification>
    var templateSpecifications: Array<ASAEventSpecification>?
    
    /// The specification for the first possible occurrence of any event in this events file
    var firstDateSpecification: ASADateSpecification?
    
    enum CodingKeys: String, CodingKey {
        case titles
        case defaultLocale
        case calendarColor
        case calendarCode
        case otherCalendarCodes
        case emoji
        case urls
        case eventSpecifications    = "events"
        case templateSpecifications = "templates"
        case firstDateSpecification = "first"
    }
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
            newJSONDecoder.allowsJSON5 = true

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
    
    var symbol: String? {
        let emoji = self.emoji
        if emoji != nil {
            return self.emoji
        }
       
        let regionCode = self.autolocalizableRegionCode()
        if regionCode != nil {
            return regionCode!.flag
        }
        return nil
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
    
    var numberOfEventSpecifications: Int {
        var sum = 0
        
        for eventSpecification in self.eventSpecifications {
            if eventSpecification.titles != nil {
                sum += 1
            }
            
            if eventSpecification.nonoverlappingSubEvents != nil {
                sum += eventSpecification.nonoverlappingSubEvents!.count
            }
            
            if eventSpecification.overlappingSubEvents != nil {
                sum += eventSpecification.overlappingSubEvents!.count
            }
        } // for eventSpecification
        
        return sum
    }
} // extension ASAEventsFile
