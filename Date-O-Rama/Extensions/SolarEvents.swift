//
//  SolarEvents.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-23.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

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

fileprivate let SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON = (50.0 / 60.0)
//fileprivate let CIVIL_DEGREES_BELOW_HORIZON               = 6.0
//fileprivate let NAUTICAL_DEGREES_BELOW_HORIZON           = 12.0
//fileprivate let ASTRONOMICAL_DEGREES_BELOW_HORIZON       = 18.0

struct ASASolarEvent:  Hashable {
    // This struct encapsulates parameters for Solar events of interest
    var degreesBelowHorizon:  Double       // Sun’s center degrees below horizon
    var rising:  Bool
    var offset:  TimeInterval // Seconds after the Sun reaches the requested apparent position
    
    static var sunrise             = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: true, offset: 0)
    static var sunset              = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: false, offset: 0)
//    static var civilDawn           = ASASolarEvent(degreesBelowHorizon: CIVIL_DEGREES_BELOW_HORIZON, rising: true, offset: 0)
//    static var civilDusk           = ASASolarEvent(degreesBelowHorizon: CIVIL_DEGREES_BELOW_HORIZON, rising: false, offset: 0)
//    static var nauticalDawn        = ASASolarEvent(degreesBelowHorizon: NAUTICAL_DEGREES_BELOW_HORIZON, rising: true, offset: 0)
//    static var nauticalDusk        = ASASolarEvent(degreesBelowHorizon: NAUTICAL_DEGREES_BELOW_HORIZON, rising: false, offset: 0)
//    static var astronomicalDawn    = ASASolarEvent(degreesBelowHorizon: ASTRONOMICAL_DEGREES_BELOW_HORIZON, rising: true, offset: 0)
//    static var astronomicalDusk    = ASASolarEvent(degreesBelowHorizon: ASTRONOMICAL_DEGREES_BELOW_HORIZON, rising: false, offset: 0)
//    static var dawn16Point1Degrees = ASASolarEvent(degreesBelowHorizon: 16.1, rising: true, offset: 0) // עלות השחר
//    static var recognition = ASASolarEvent(degreesBelowHorizon: 11.0, rising: true, offset: 0) // משיכיר
//    static var dusk8Point5Degrees  = ASASolarEvent(degreesBelowHorizon: 8.5, rising: false, offset: 0) // צאת הכוכבים
    
    static var dawn72Minutes        = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: true, offset: -72 * 60)
    static var dusk72Minutes        = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: false, offset: 72 * 60)
    
//    static var candleLighting       = ASASolarEvent(degreesBelowHorizon: SUNRISE_AND_SUNSET_DEGREES_BELOW_HORIZON, rising: false, offset: -18 * 60)
} // struct ASASolarEvent


extension Date {
    func solarEvents(latitude:  Double, longitude:  Double, events:  Array<ASASolarEvent>, timeZone:  TimeZone) -> Dictionary<ASASolarEvent, Date?> {

        // 1. first calculate the day of the year
        
//        var calendar = Calendar(identifier: .gregorian)
        Date.gregorianCalendar.timeZone = timeZone
//        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let N:  Int = Date.gregorianCalendar.ordinality(of: .day, in: .year, for: self)!
        
        // 2. convert the longitude to hour value and calculate an approximate time
        
        let lngHour:  Double = longitude / 15.0
        
        let t_rising =  Double(N) + ((6.0 - lngHour) / 24.0)
        let t_setting = Double(N) + ((18.0 - lngHour) / 24.0)
        
        // Now switch to a function
        var result:  Dictionary<ASASolarEvent, Date?> = [:]
        for event in events {
            var tempResult = solarEventsContinued(t: event.rising ? t_rising : t_setting, latitude: latitude, degreesBelowHorizon: event.degreesBelowHorizon, risingDesired: event.rising, date: self, lngHour: lngHour, offset: event.offset)
            if !event.rising && tempResult != nil {
                let midnightToday = Date.gregorianCalendar.startOfDay(for:self)
                let noon = midnightToday.addingTimeInterval(12 * 60 * 60)
                if tempResult! < noon {
                    // Something went wrong, and we got a result for the previous day
                    tempResult = tempResult!.oneDayAfter
                }
            }
            result[event] = tempResult
        } // for event in events
        
        return result
    } // func solarEvents(latitude:  Double, longitude:  Double, events:  Array<ASASolarEvent>) -> Dictionary<ASASolarEvent, Date?>
} // extension Date

func solarEventsContinued(t:  Double, latitude:  Double, degreesBelowHorizon:  Double, risingDesired:  Bool, date:  Date, lngHour:  Double, offset:  TimeInterval) -> Date? {
    // 3. calculate the Sun's mean anomaly
    let M = (0.9856 * t) - 3.289
    
    // 4. calculate the Sun's true longitude
    var L = M + (1.916 * sin(degrees:  M)) + (0.020 * sin(degrees:  2.0 * M)) + 282.634
    //     NOTE: L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
    L = L.normalizedTo(lower: 0.0, upper: 360.0)
    
    // 5a. calculate the Sun's right ascension
    var RA = atan(degrees:  0.91764 * tan(degrees:  L))
    // NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
    RA = RA.normalizedTo(lower: 0.0, upper: 360.0)
    
    // 5b. right ascension value needs to be in the same quadrant as L
    let Lquadrant  = (floor( L/90.0)) * 90.0
    let RAquadrant = (floor(RA/90.0)) * 90.0
    RA = RA + (Lquadrant - RAquadrant)
    
    // 5c. right ascension value needs to be converted into hours
    
    RA = RA / 15.0
    
    // 6. calculate the Sun's declination
    let sinDec = 0.39782 * sin(degrees:  L)
    let cosDec = cos(degrees:  asin(degrees:  sinDec))
    
    // 7a. calculate the Sun's local hour angle
    let zenith = degreesBelowHorizon + 90
    let cosH = (cos(degrees:  zenith) - (sinDec * sin(degrees:  latitude))) / (cosDec * cos(degrees: latitude))
    
    if (cosH >  1.0) {
        //      the sun never rises on this location (on the specified date)
        return nil
    }
    if (cosH < -1.0) {
        //      the sun never sets on this location (on the specified date)
        return nil
    }
    
    // 7b. finish calculating H and convert into hours
    var H:  Double
    if risingDesired {
        H = 360.0 - acos(degrees:  cosH)
    } else {
        H = acos(degrees:  cosH)
    }
    
    H = H / 15.0
    
    // 8. calculate local mean time of rising/setting
    let T = H + RA - (0.06571 * t) - 6.622

    // 9. adjust back to UTC
    var UT = T - lngHour
    // NOTE: UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24
    UT = UT.normalizedTo(lower: 0.0, upper: 24.0)
    
    var gregorianCalendar = Calendar(identifier: .gregorian)
    gregorianCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let midnight = gregorianCalendar.startOfDay(for:date)
    let result = midnight.addingTimeInterval(UT * 60 * 60) + offset
    
    return result
} // func solarEventsContinued(t:  Double, latitude:  Double, degreesBelowHorizon:  Double, risingDesired:  Bool, date:  Date, lngHour:  Double) -> Date?

extension Double {
    func normalizedTo(lower:  Double, upper:  Double) -> Double {
        var temp = self
        while temp < lower {
            temp += upper
        } // while temp < lower
        
        while temp >= upper {
            temp -= upper
        } // while temp >= upper
        
        return temp
    } // func normalizedTo(lower:  Double, upper:  Double) -> Double
} // func normalizedTo(lower:  Double, upper:  Double) -> Double


// MARK: - Trigonometric functions that take degrees as inputs
// Based on https://stackoverflow.com/questions/28598307/make-swift-assume-degrees-for-trigonometry-calculations

func sin(degrees: Double) -> Double {
    return sin(degrees * Double.pi / 180.0)
}

func cos(degrees: Double) -> Double {
    return cos(degrees * Double.pi / 180.0)
}

func tan(degrees: Double) -> Double {
    return tan(degrees * Double.pi / 180.0)
}

func atan(degrees: Double) -> Double {
    return atan(degrees) * 180.0 / Double.pi
}

func asin(degrees: Double) -> Double {
    return asin(degrees) * 180.0 / Double.pi
}

func acos(degrees: Double) -> Double {
    return acos(degrees) * 180.0 / Double.pi
}
