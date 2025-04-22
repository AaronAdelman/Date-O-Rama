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
    fileprivate static var solarEventsGregorianCalendar = Calendar(identifier: .gregorian)

    func solarEvents(location: CLLocation, events:  Array<ASASolarEvent>, timeZone:  TimeZone) -> Dictionary<ASASolarEvent, Date?> {
        Date.solarEventsGregorianCalendar.timeZone = timeZone

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
                    let midnightToday = Date.solarEventsGregorianCalendar.startOfDay(for:self)
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
        
//        let latitude = location.coordinate.latitude
//        let longitude = location.coordinate.longitude
//
//        // 1. first calculate the day of the year
//
//        Date.solarEventsGregorianCalendar.timeZone = timeZone
//
//        let N:  Int = Date.solarEventsGregorianCalendar.ordinality(of: .day, in: .year, for: self)!
//        //        debugPrint(#file, #function, "N:", N)
//
//        // 2. convert the longitude to hour value and calculate an approximate time
//
//        let lngHour:  Double = longitude / 15.0
//
//        let t_rising =  Double(N) + ((6.0 - lngHour) / 24.0)
//        let t_setting = Double(N) + ((18.0 - lngHour) / 24.0)
//        //        debugPrint(#file, #function, "lngHour:", lngHour, "t_rising:", t_rising, "t_setting:", t_setting)
//
//        // Now switch to a function
//        var result:  Dictionary<ASASolarEvent, Date?> = [:]
//        for event in events {
//            //            debugPrint(#file, #function, "event:", event)
//            var tempResult = solarEventsContinued(t: event.rising ? t_rising : t_setting, latitude: latitude, degreesBelowHorizon: event.degreesBelowHorizon, risingDesired: event.rising, date: self, lngHour: lngHour, offset: event.offset, timeZone:  timeZone)
//            //            debugPrint(#file, #function, "tempResult:", tempResult as Any)
//            if !event.rising && tempResult != nil {
//                let midnightToday = Date.solarEventsGregorianCalendar.startOfDay(for:self)
//                //                debugPrint(#file, #function, "midnightToday:", midnightToday)
//                let noon = midnightToday.addingTimeInterval(12 * Date.SECONDS_PER_HOUR)
//                //                debugPrint(#file, #function, "noon:", noon)
//                if tempResult! < noon {
//                    // Something went wrong, and we got a result for the previous day
//                    tempResult = tempResult!.oneDayAfter
//                    //                    debugPrint(#file, #function, "Reset tempResult:", tempResult as Any)
//                }
//            }
//            result[event] = tempResult
//        } // for event in events

        return result
    } // func solarEvents(latitude: CLLocationDegrees, longitude: CLLocationDegrees, events:  Array<ASASolarEvent>) -> Dictionary<ASASolarEvent, Date?>
} // extension Date

//func solarEventsContinued(t:  Double, latitude: CLLocationDegrees, degreesBelowHorizon:  Double, risingDesired:  Bool, date:  Date, lngHour:  Double, offset:  TimeInterval, timeZone:  TimeZone) -> Date? {
//    // 3. calculate the Sun's mean anomaly
//    let M = (0.9856 * t) - 3.289
//
//    // 4. calculate the Sun's true longitude
//    var L = M + (1.916 * sin(degrees:  M)) + (0.020 * sin(degrees:  2.0 * M)) + 282.634
//    //     NOTE: L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
//    L = L.normalizedTo(lower: 0.0, upper: 360.0)
//
//    // 5a. calculate the Sun's right ascension
//    var RA = atan(degrees:  0.91764 * tan(degrees:  L))
//    // NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
//    RA = RA.normalizedTo(lower: 0.0, upper: 360.0)
//
//    // 5b. right ascension value needs to be in the same quadrant as L
//    let Lquadrant  = (floor( L/90.0)) * 90.0
//    let RAquadrant = (floor(RA/90.0)) * 90.0
//    RA = RA + (Lquadrant - RAquadrant)
//
//    // 5c. right ascension value needs to be converted into hours
//
//    RA = RA / 15.0
//
//    // 6. calculate the Sun's declination
//    let sinDec = 0.39782 * sin(degrees:  L)
//    let cosDec = cos(degrees:  asin(degrees:  sinDec))
//
//    // 7a. calculate the Sun's local hour angle
//    let zenith = degreesBelowHorizon + 90
//    let cosH = (cos(degrees:  zenith) - (sinDec * sin(degrees:  latitude))) / (cosDec * cos(degrees: latitude))
//
//    if (cosH >  1.0) {
//        //      the sun never rises on this location (on the specified date)
//        return nil
//    }
//    if (cosH < -1.0) {
//        //      the sun never sets on this location (on the specified date)
//        return nil
//    }
//
//    // 7b. finish calculating H and convert into hours
//    var H:  Double
//    if risingDesired {
//        H = 360.0 - acos(degrees:  cosH)
//    } else {
//        H = acos(degrees:  cosH)
//    }
//
//    H = H / 15.0
//
//    // 8. calculate local mean time of rising/setting
//    let T = H + RA - (0.06571 * t) - 6.622
//
//    // 9. adjust back to UTC
//    var UT = T - lngHour
//    // NOTE: UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24
//    UT = UT.normalizedTo(lower: 0.0, upper: 24.0)
//
//    let midnight = date.previousMidnight(timeZoneOffset:  0)
//    var result = midnight.addingTimeInterval(UT * Date.SECONDS_PER_HOUR) + offset
//
//    let localNextMidnight = date.nextMidnight(timeZone:  timeZone)
//    if result >= localNextMidnight {
//        // Uh-oh!  Too late!
//        result = result.oneDayBefore
//    }
//
//    return result
//} // func solarEventsContinued(t:  Double, latitude: CLLocationDegrees, degreesBelowHorizon:  Double, risingDesired:  Bool, date:  Date, lngHour:  Double) -> Date?
//
//extension Double {
//    func normalizedTo(lower:  Double, upper:  Double) -> Double {
//        var temp = self
//        while temp < lower {
//            temp += upper
//        } // while temp < lower
//
//        while temp >= upper {
//            temp -= upper
//        } // while temp >= upper
//
//        return temp
//    } // func normalizedTo(lower:  Double, upper:  Double) -> Double
//} // func normalizedTo(lower:  Double, upper:  Double) -> Double
//

