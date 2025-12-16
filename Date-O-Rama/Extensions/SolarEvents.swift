//
//  SolarEvents.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-23.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftAA

// MARK: - Sunrise/Sunset Algorithm

fileprivate let SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON = 0.833

/// This struct encapsulates parameters for Solar events of interest
struct ASASolarEvent:  Hashable {
    /// Sun’s center degrees below horizon
    var degreesBelowHorizon:  Double
    
    /// true if at or near Sunrise, false if at or near Sunset
    var rising:  Bool
    
    /// Seconds after the Sun reaches the requested apparent position.  Negative values indicate seconds before the Sun reaches the requested apparent position.
    var offset:  TimeInterval

    static let sunrise             = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: true, offset: 0)
    static let sunset              = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: false, offset: 0)
    static let dawn72Minutes        = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: true, offset: -72 * 60)
    static let dusk72Minutes        = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: false, offset: 72 * 60)
} // struct ASASolarEvent


extension Date {

    func solarEvents(location: CLLocation, events:  Array<ASASolarEvent>, timeZone:  TimeZone) -> Dictionary<ASASolarEvent, Date?> {
        var solarEventsGregorianCalendar = Calendar(identifier: .gregorian)

        solarEventsGregorianCalendar.timeZone = timeZone

        let now = JulianDay(self.dateToCalculateSolarEventsFor(timeZone: timeZone))
        let terra = Earth(julianDay: now, highPrecision: true)
        let coordinates = GeographicCoordinates(location)
        var result:  Dictionary<ASASolarEvent, Date?> = [:]
        var rises: Dictionary<Double, Date?> = [:]
        var sets: Dictionary<Double, Date?>  = [:]
        
        for event in events {
            var rise: Date?
            var set: Date?
            
            let possibleRise = rises[event.degreesBelowHorizon] ?? nil
            if possibleRise != nil {
                rise = possibleRise
                set  = sets[event.degreesBelowHorizon] ?? nil
            } else {
                let twilights = terra.twilights(forSunAltitude: Degree(0 - event.degreesBelowHorizon), coordinates: coordinates)
                rise = twilights.riseTime?.date
                set = twilights.setTime?.date
                rises[event.degreesBelowHorizon] = rise
                sets[event.degreesBelowHorizon]  = set
            }
            
            if event.rising {
                if rise == nil {
                    result[event] = nil
                } else {
                    result[event] = rise! + event.offset
                }
            } else {
                // !event.rising
                var tempResult: Date? = set
                if tempResult != nil {
                    let midnightToday = solarEventsGregorianCalendar.startOfDay(for:self) // TODO:  May want to rewrite this to avoid use of a Date object
                    //                debugPrint(#file, #function, "midnightToday:", midnightToday)
                    let noon = midnightToday.addingTimeInterval(12 * Date.SECONDS_PER_HOUR)
                    //                debugPrint(#file, #function, "noon:", noon)
                    if tempResult! < noon {
                        // Something went wrong, and we got a result for the previous day
                        tempResult = tempResult!.oneDayAfter
                        //                    debugPrint(#file, #function, "Reset tempResult:", tempResult as Any)
                    }
                    result[event] = tempResult! + event.offset
                } else {
                    // tempResult == nil
                    let tomorrow = JulianDay(self.oneDayAfter)
                    let terraTommorow = Earth(julianDay: tomorrow, highPrecision: true)
                    let twilights = terraTommorow.twilights(forSunAltitude: Degree(0 - event.degreesBelowHorizon), coordinates: coordinates)
                    set = twilights.setTime?.date
                    if set != nil {
                        sets[event.degreesBelowHorizon] = set
                        result[event] = set! + event.offset
                    }
                }
            }
        } // for event in events
        return result
    } // func solarEvents(latitude: CLLocationDegrees, longitude: CLLocationDegrees, events:  Array<ASASolarEvent>) -> Dictionary<ASASolarEvent, Date?>
} // extension Date

