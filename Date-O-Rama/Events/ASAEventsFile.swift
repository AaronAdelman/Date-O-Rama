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
    var supportedLocales:  Array<String>
    var titles:  Dictionary<String, String>
    var defaultLocale:  String
    
    var calendarColor: Color
    var calendarCode:  ASACalendarCode
    var otherCalendarCodes:  Array<ASACalendarCode>?
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
} // extension ASAEventsFile
