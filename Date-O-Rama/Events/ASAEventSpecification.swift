//
//  ASAEventSpecification.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

class ASAEventSpecification: Codable {
    var template: String?
    var inherits: String?
    
    var titles:  Dictionary<String, String>?
    var locations: Dictionary<String, String>?
    
    var isAllDay:  Bool {
        return self.type.isAllDay
    } // var isAllDay

    var calendarCode:  ASACalendarCode?
    var startDateSpecification: ASADateSpecification
    var endDateSpecification: ASADateSpecification?
    
    /// The specification for the first occurrence of this event
    var firstDateSpecification: ASADateSpecification?
    
    var regionCodes:  Array<String>?
    var excludeRegionCodes:  Array<String>?
        
    var urls: Dictionary<String, URL>? // URLs for the calendar item, indexed by locale code.
    var notes: Dictionary<String, String>? // The notes associated with the calendar item, indexed by locale code.
    
    var category: ASAEventCategory?
    var emoji: String?
    
    var type: ASAEventSpecificationType

    enum CodingKeys: String, CodingKey {
        case startDateSpecification = "start"
        case endDateSpecification   = "end"
        case firstDateSpecification = "1st"
        case template, inherits, titles, locations, calendarCode, regionCodes, excludeRegionCodes, urls, notes, category, emoji, type
    } // enum CodingKeys
} // extension ASAEventSpecification


// MARK:  -

extension Array where Element == String {
    /// Matching for region code
    /// - Parameters:
    ///   - regionCode: An ISO or MARC region code.  This may include "xb" (northern hemisphere) or "xc" (southern hemisphere)
    ///   - latitude: Latitude in degrees north of the equator
    /// - Returns: Whether the region code is in the array.  Note that if the latitude passed is correct, "xb" and "xc" will match, too.
    func matches(regionCode: String, latitude: CLLocationDegrees) -> Bool {
        let result: Bool = self.contains(regionCode)
//        debugPrint(#file, #function, "Contains code:", regionCode, result)
        if result {
            return true
        }
        
        if self.contains(REGION_CODE_Northern_Hemisphere) {
            let result: Bool = latitude > 0.0
            if result {
//                debugPrint(#file, #function, "Northern Hemisphere", latitude, result)
                return true
            }
        }
        
        if self.contains(REGION_CODE_Southern_Hemisphere) {
            let result: Bool = latitude < 0.0
            if result {
//                debugPrint(#file, #function, "Southern Hemisphere", latitude, result)
                return true
            }
        }
        
        return false
    } // func matches(regionCode: String, latitude: CLLocationDegrees) -> Bool
} // extension Array where Element == String

extension ASAEventSpecification {
    func match(regionCode:  String?, latitude: CLLocationDegrees) -> Bool {
        if regionCode == nil {
            if self.regionCodes != nil && self.regionCodes != [] {
                return false
            }
            
            return true
        } else {
            if self.regionCodes != nil {
                let result = self.regionCodes!.matches(regionCode: regionCode!, latitude: latitude)
                return result
            }
            
            if self.excludeRegionCodes != nil {
                let result = !self.excludeRegionCodes!.matches(regionCode: regionCode!, latitude: latitude)
                return result
            }
            
            return true
        }
    } // func match(regionCode:  String?) -> Bool

    func eventTitle(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String? {
        if self.titles != nil {
            return self.titles!.value(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocaleIdentifier)
        }

        return nil
    } // func eventTitle(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String?

    func eventLocation(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String? {
        if self.locations != nil {
            return self.locations!.value(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocaleIdentifier)
        }

        return nil
    } // func eventLocation(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String?
    
    func eventURL(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> URL? {
        if self.urls != nil {
            return self.urls!.value(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocaleIdentifier)
        }

        return nil
    } // func eventURL(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String?
    
    func eventNotes(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String? {
        if self.notes != nil {
            return self.notes!.value(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFileDefaultLocaleIdentifier)
        }

        return nil
    } // func eventNotes(requestedLocaleIdentifier:  String, eventsFileDefaultLocaleIdentifier:  String) -> String?
    
    var recurrenceRules: [EKRecurrenceRule]? {
        var result: [EKRecurrenceRule] = []
                
        if startDateSpecification.year == nil {
            if startDateSpecification.yearDivisor != nil {
                // Event repeats once every specific number of years
                result.append(EKRecurrenceRule(recurrenceWith: .yearly, interval: startDateSpecification.yearDivisor!, end: nil))
            } else {
                // Event repeats every year
                if startDateSpecification.month == nil {
                    // Event repeats at least once every month
                    
                    if startDateSpecification.day == nil {
                        if startDateSpecification.weekdays == nil {
                            // Event repeats every day
                            result.append(EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil))
                        } else {
                            // Event repeats every week
                            result.append(EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil))
                        }

                    } else {
                        // Event repeats every month on a specific day
                        result.append(EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil))
                    }
                } else {
                    // Event repeats every year
                    result.append(EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil))
                }
            }
        }
        
        if result.count == 0 {
            return nil
        }
        
        return result
    } // var recurrenceRules
    
    func matchesTemplateEventSpecification(templateEventSpecification: ASAEventSpecification) -> Bool {
        assert(self.inherits != nil)
        assert(templateEventSpecification.template != nil)
        
        return self.inherits == templateEventSpecification.template
    }
} // extension ASAEventSpecification


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
