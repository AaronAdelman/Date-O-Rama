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

// Based on http://edwilliams.org/sunrise_sunset_algorithm.htm?fbclid=IwAR1xVwKgo6rHtb42u0kl7IE3BA04dUAJfO3EN5JXlNXpV-CEH7JpIo9dys4
// Includes original text to allow more easily checking against the original.

// Source:
//     Almanac for Computers, 1990
//     published by Nautical Almanac Office
//     United States Naval Observatory
//     Washington, DC 20392
//
// Inputs:
//     day, month, year:      date of sunrise/sunset
//     latitude, longitude:   location for sunrise/sunset
//     zenith:                Sun's zenith for sunrise/sunset
//       offical      = 90 degrees 50'
//       civil        = 96 degrees
//       nautical     = 102 degrees
//       astronomical = 108 degrees
//
//     NOTE: longitude is positive for East and negative for West
//         NOTE: the algorithm assumes the use of a calculator with the
//         trig functions in "degree" (rather than "radian") mode. Most
//         programming languages assume radian arguments, requiring back
//         and forth convertions. The factor is 180/pi. So, for instance,
//         the equation RA = atan(0.91764 * tan(L)) would be coded as RA
//         = (180/pi)*atan(0.91764 * tan((pi/180)*L)) to give a degree
//         answer with a degree input for L.

//fileprivate let SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON = (50.0 / 60.0)
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

