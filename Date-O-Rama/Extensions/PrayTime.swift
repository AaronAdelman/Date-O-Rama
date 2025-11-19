//
//  PrayTime.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 21/07/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

/*
 
 PrayTime Prayer Times Calculator (ver 1.2)
 Copyright (C) 2007-2010 PrayTimes.org
 
 Heavily refactored Swift code by Aaron Solomon Adelman
 Objective C Code By: Hussain Ali Khan
 Original JS Code By: Hamid Zarrabi-Zadeh
 
 License: GNU LGPL v3.0
 
 TERMS OF USE:
 Permission is granted to use this code, with or
 without modification, in any website or application
 provided that credit is given to the original work
 with a link back to PrayTimes.org.
 
 This program is distributed in the hope that it will
 be useful, but WITHOUT ANY WARRANTY.
 
 PLEASE DO NOT REMOVE THIS COPYRIGHT BLOCK.
 
 */

import Foundation
import CoreLocation

// MARK:  - Public types

// Calculation Methods
enum ASACalculationMethod: String, Codable {
    case Jafari         // Ithna Ashari
    case Karachi        // University of Islamic Sciences, Karachi
    case ISNA           // Islamic Society of North America (ISNA)
    case MWL            // Muslim World League (MWL)
    case Makkah         // Umm al-Qura, Makkah
    case Egypt          // Egyptian General Authority of Survey
    case Tehran         // Institute of Geophysics, University of Tehran
} // enum ASACalculationMethod

// Juristic Methods
enum ASAJuristicMethodForAsr: String, Codable {
    case Shafii     // Shafii (standard)
    case Hanafi     // Hanafi
} // enum ASAJuristicMethodForAsr

// Adjusting Methods for Higher Latitudes
enum ASAAdjustingMethodForHigherLatitudes: String, Codable {
    case none          // No adjustment
    case midnight      // middle of night
    case oneSeventh    // 1/7th of night
    case angleBased    // angle/60th of night
} // enum ASAAdjustingMethodForHigherLatitudes

enum ASAIslamicPrayerTimeEvent {
    case Fajr
    case Sunrise
    case Dhuhr
    case Asr
    case Sunset
    case Maghrib
    case Isha
} // enum ASAIslamicPrayerTimeEvent


// MARK: - Public extension

extension Date {
    func prayerTimesMidnightTransition(latitude: CLLocationDegrees, longitude: CLLocationDegrees, calcMethod: ASACalculationMethod, asrJuristic: ASAJuristicMethodForAsr, dhuhrMinutes: Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes, events: Array<ASAIslamicPrayerTimeEvent>) -> Dictionary<ASAIslamicPrayerTimeEvent, Date>! {
        //        debugPrint(#file, #function, year, month, day, latitude, longitude
        //        )
        
        var JDate = self.julianDate
        var baseDate: Date
        if self.addingTimeInterval(1.0).previousMidnight(timeZoneOffset: 0.0) == self {
            baseDate = self
        } else {
            baseDate = self.previousMidnight(timeZoneOffset: 0.0)
        }
        
        let lonDiff:Double = longitude/(15.0 * 24.0)
        JDate = JDate - lonDiff
        let result = computeDates(calcMethod: calcMethod, asrJuristic: asrJuristic, dhuhrMinutes: dhuhrMinutes, adjustHighLats: adjustHighLats, JDate: JDate, lat: latitude, lng: longitude, baseDate: baseDate, events: events)
        
        //        debugPrint(#file, #function, year, month, day, latitude, longitude,
        ////                    tZone,
        //                   "Returning:", result as Any)
        
        return result
    } // func prayerTimesMidnightTransition(latitude: Double, longitude: Double, calcMethod: ASACalculationMethod, asrJuristic: ASAJuristicMethodForAsr, dhuhrMinutes: Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes, events: Array<ASAIslamicPrayerTimeEvent>) -> Dictionary<ASAIslamicPrayerTimeEvent, Date>!
    
    /// Calculates Islamic prayer times, assuming the date starts at Sunset
    /// - Parameters:
    ///   - latitude: Latitude (degrees)
    ///   - longitude: Longitude (degrees)
    ///   - calcMethod: Calculation method; there are several views on the correct times for various events
    ///   - asrJuristic: Shafii or Hanafi method for calculation of Asr
    ///   - dhuhrMinutes: Minutes added to Dhuhr
    ///   - adjustHighLats: Adjustment method for high latitudes
    ///   - events: An array of Islamic prayer times (specifications) to be calculated
    /// - Returns: A dictionary of the requested Islamic prayer times
    func prayerTimesSunsetTransition(latitude: CLLocationDegrees, longitude: CLLocationDegrees, calcMethod: ASACalculationMethod, asrJuristic: ASAJuristicMethodForAsr, dhuhrMinutes: Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes, events: Array<ASAIslamicPrayerTimeEvent>) -> Dictionary<ASAIslamicPrayerTimeEvent, Date>! {
        var previousDayEvents: Array<ASAIslamicPrayerTimeEvent> = []
        var thisDayEvents: Array<ASAIslamicPrayerTimeEvent> = []
        
        for event in events {
            switch event {
            case .Sunset, .Maghrib, .Isha:
                previousDayEvents.append(event)
                
            case .Fajr, .Sunrise, .Dhuhr, .Asr:
                thisDayEvents.append(event)
            } //switch event
        } // for event in events
        
        //        debugPrint(#file, #function, previousDayEvents, thisDayEvents)
        
        var previousDayOutput: Dictionary<ASAIslamicPrayerTimeEvent, Date> = [:]
        var thisDayOutput: Dictionary<ASAIslamicPrayerTimeEvent, Date> = [:]
        
        if previousDayEvents.count > 0 {
            let previousDate = self.previousGMTNoon
            previousDayOutput = previousDate.prayerTimesMidnightTransition(latitude: latitude, longitude: longitude, calcMethod: calcMethod, asrJuristic: asrJuristic, dhuhrMinutes: dhuhrMinutes, adjustHighLats: adjustHighLats, events: previousDayEvents)
            previousDayOutput[.Sunrise] = nil
        }
        
        //        debugPrint(#file, #function, previousDayOutput)
        
        if thisDayEvents.count > 0 {
            thisDayOutput = self.prayerTimesMidnightTransition(latitude: latitude, longitude: longitude, calcMethod: calcMethod, asrJuristic: asrJuristic, dhuhrMinutes: dhuhrMinutes, adjustHighLats: adjustHighLats, events: thisDayEvents)
            thisDayOutput[.Sunset] = nil
        }
        
        //        debugPrint(#file, #function, thisDayOutput)
        
        var result = thisDayOutput
        for (key, value) in previousDayOutput {
            result[key] = value
        }  // for (key, value) in previousDayOutput
        
        // Assertions to make sure we have not made any mistakes.
        if result[.Sunset] != nil && result[.Maghrib] != nil {
            assert(result[.Sunset]! <= result[.Maghrib]!)
        }
        if result[.Isha] != nil && result[.Maghrib] != nil {
            assert(result[.Maghrib]! <= result[.Isha]!)
        }
        if result[.Isha] != nil && result[.Fajr] != nil {
            assert(result[.Isha]! <= result[.Fajr]!)
        }
        
        if result[.Sunrise] != nil && result[.Fajr] != nil {
            assert(result[.Fajr]! <= result[.Sunrise]!)
        }
        if result[.Sunrise] != nil && result[.Dhuhr] != nil {
            assert(result[.Sunrise]! <= result[.Dhuhr]!)
        }
        if result[.Asr] != nil && result[.Dhuhr] != nil {
            assert(result[.Dhuhr]! <= result[.Asr]!)
        }
        
        return result
    } // func prayerTimesSunsetTransition(latitude: Double, longitude: Double, calcMethod: ASACalculationMethod, asrJuristic: ASAJuristicMethodForAsr, dhuhrMinutes: Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes, events: Array<ASAIslamicPrayerTimeEvent>) -> Dictionary<ASAIslamicPrayerTimeEvent, Date>!
} // extension Date


// MARK:  - Types and extensions for polishing the original API

struct ASAMethodParameters {
    var fajrDegrees: Double
    var maghribFlag: Bool
    var maghribDegrees: Double
    var ishaFlag: Bool
    var ishaDegrees: Double
} // struct ASAMethodParameters

extension ASACalculationMethod {
    /// Calc Method Parameters
    var methodParams: ASAMethodParameters {
        switch self {
        case .Jafari:
//            let Jvalues: Array<Double> = [
//                16,
//                0,
//                4,
//                0,
//                14
//            ]
//            return Jvalues
            return ASAMethodParameters(fajrDegrees: 16, maghribFlag: false, maghribDegrees: 4, ishaFlag: false, ishaDegrees: 14)
            
        case .Karachi:
//            let Kvalues: Array<Double> = [
//                18,
//                1,
//                0,
//                0,
//                18
//            ]
//            return Kvalues
        return ASAMethodParameters(fajrDegrees: 18, maghribFlag: true, maghribDegrees: 0, ishaFlag: false, ishaDegrees: 18)
            
        case .ISNA:
//            let Ivalues: Array<Double> = [
//                15,
//                1,
//                0,
//                0,
//                15
//            ]
//            return Ivalues
          return ASAMethodParameters(fajrDegrees: 15, maghribFlag: true, maghribDegrees: 0, ishaFlag: false, ishaDegrees: 15)
            
        case .MWL:
//            let Mvalues: Array<Double> = [
//                18,
//                1,
//                0,
//                0,
//                17
//            ]
//            return Mvalues
        return ASAMethodParameters(fajrDegrees: 18, maghribFlag: true, maghribDegrees: 0, ishaFlag: false, ishaDegrees: 17)
            
        case .Makkah:
//            let Mavalues: Array<Double> = [
//                18.5,
//                1,
//                0,
//                1,
//                90
//            ]
//            return Mavalues
            return ASAMethodParameters(fajrDegrees: 18.5, maghribFlag: true, maghribDegrees: 0, ishaFlag: true, ishaDegrees: 90)
            
        case .Egypt:
//            let Evalues: Array<Double> = [
//                19,
//                1,
//                0,
//                0,
//                17.5
//            ]
//            return Evalues
            return ASAMethodParameters(fajrDegrees: 19, maghribFlag: true, maghribDegrees: 0, ishaFlag: false, ishaDegrees: 17.5)
            
        case .Tehran:
//            let Tvalues: Array<Double> = [
//                17.7,
//                0,
//                4.5,
//                0,
//                14
//            ]
//            return Tvalues
            return ASAMethodParameters(fajrDegrees: 17.7, maghribFlag: false, maghribDegrees: 4.5, ishaFlag: false, ishaDegrees: 14)
        } // return self
    } // var methodParams
} // extension ASACalculationMethod

//let FAJR_PARAMETER      = 0
//let MAGHRIB_PARAMETER_1 = 1
//let MAGHRIB_PARAMETER_2 = 2
//let ISHA_PARAMETER_1    = 3
//let ISHA_PARAMETER_2    = 4

extension ASAJuristicMethodForAsr {
    var value: Double {
        switch self {
        case .Shafii:
            return 1.0
            
        case .Hanafi:
        return 2.0
        }
    }
}


// MARK:  - Trigonometric Functions

// range reduce angle in degrees.
func fixangle(a: Double) -> Double {
    
    var result = a - (360 * (floor(a / 360.0)))
    
    result = result < 0 ? (result + 360) : result
    return result
}

// range reduce hours to 0..23
func fixhour(a: Double) -> Double {
    var result = a - 24.0 * floor(a / 24.0)
    result = result < 0 ? (result + 24) : result
    return result
}

// radian to degree
func radiansToDegrees(alpha: Double) -> Double {
    return ((alpha*180.0)/Double.pi)
}

// degree arctan2
func arctan2(degreesY y: Double, degreesX x: Double) -> Double {
    let val:Double = atan2(y, x)
    return radiansToDegrees(alpha: val)
}

// degree arccot
func arccot(degrees x: Double) -> Double {
    let val:Double = atan2(1.0, x)
    return radiansToDegrees(alpha: val)
}


// MARK:  -  Calculation Functions

// References:
// http://www.ummah.net/astronomy/saltime
// http://aa.usno.navy.mil/faq/docs/SunApprox.html


// compute declination angle of sun and equation of time
func sunPosition(jd: Double) -> (declinationAngleOfSun: Double, equationOfTime: Double) {
    
    let D:Double = jd - 2451545
    let g:Double = fixangle(a: (357.529 + 0.98560028 * D))
    let q:Double = fixangle(a: (280.459 + 0.98564736 * D))
    let L:Double = fixangle(a: (q + (1.915 * sin(degrees: g)) + (0.020 * sin(degrees: (2 * g)))))
    
    let e:Double = 23.439 - (0.00000036 * D)
    let d:Double = asin(degrees: (sin(degrees: e) * sin(degrees: L)))
    var RA: Double = (arctan2(degreesY: (cos(degrees: e) * sin(degrees: L)), degreesX: cos(degrees: L))) / 15.0
    RA = fixhour(a: RA)
    
    let EqT:Double = q/15.0 - RA
    
    let sPosition = (d, EqT)
    
    return sPosition
}

// compute mid-day (Dhuhr, Zawal) time
func computeMidDay(t: Double, JDate: Double) -> Double {
    let T: Double = sunPosition(jd: (JDate + t)).equationOfTime
    let Z:Double = fixhour(a: (12 - T))
    return Z
}

// compute time for a given angle G
func computeTime(G: Double, andTime t: Double, JDate: Double, lat: CLLocationDegrees, lng: CLLocationDegrees) -> Double {
    let D: Double = sunPosition(jd: (JDate + t)).declinationAngleOfSun
    let Z:Double = computeMidDay(t: t, JDate: JDate)
    let V:Double = (acos(degrees: (-sin(degrees: G) - (sin(degrees: D) * sin(degrees: lat))) / (cos(degrees: D) * cos(degrees: lat)))) / 15.0
    
    return Z + (G > 90 ? -V : V)
}

// compute the time of Asr
// Shafii: step=1, Hanafi: step=2
func computeAsr(step:Double, andTime t:Double, JDate: Double, lat: CLLocationDegrees, lng: CLLocationDegrees) -> Double {
    let D: Double = sunPosition(jd: (JDate + t)).declinationAngleOfSun
    let G:Double = -arccot(degrees: (step + tan(degrees: abs(lat - D))))
    return computeTime(G: G, andTime:t, JDate: JDate, lat: lat, lng: lng)
}

// MARK:  -  Misc Functions


// compute the difference between two times
func timeDiff(time1:Double, andTime2 time2:Double) -> Double {
    return fixhour(a: (time2 - time1))
}


// MARK:  -  Compute Prayer Times

// compute prayer times at given julian date
func computeTime(calcMethod: ASACalculationMethod, asrJuristic: ASAJuristicMethodForAsr, JDate: Double, lat: CLLocationDegrees, lng: CLLocationDegrees, event: ASAIslamicPrayerTimeEvent) -> Double! {
    let t: Dictionary<ASAIslamicPrayerTimeEvent, Double> =  //default times
        [
            .Fajr: 5.0 / 24.0,
            .Sunrise : 6.0 / 24.0,
            .Dhuhr : 12.0 / 24.0,
            .Asr : 13.0 / 24.0,
            .Sunset : 18.0 / 24.0,
            .Maghrib : 18.0 / 24.0,
            .Isha : 18.0 / 24.0
        ]
    
    let idk: Double = calcMethod.methodParams.fajrDegrees
    
    switch event {
    case .Fajr:
        let Fajr: Double    = computeTime(G: (180 - idk), andTime: t[.Fajr]!, JDate: JDate, lat: lat, lng: lng)
        return Fajr
        
    case .Sunrise:
        let Sunrise: Double = computeTime(G: (180 - 0.833), andTime: t[.Sunrise]!, JDate: JDate, lat: lat, lng: lng)
        return Sunrise
        
    case .Dhuhr:
        let Dhuhr: Double   = computeMidDay(t: t[.Dhuhr]!, JDate: JDate)
        return Dhuhr
        
    case .Asr:
        let Asr: Double     = computeAsr(step: asrJuristic.value, andTime: t[.Asr]!, JDate: JDate, lat: lat, lng: lng)
        return Asr
        
    case .Sunset:
        let Sunset: Double  = computeTime(G: 0.833, andTime: t[.Sunset]!, JDate: JDate, lat: lat, lng: lng)
        return Sunset
        
    case .Maghrib:
        let Maghrib: Double = computeTime(G: calcMethod.methodParams.maghribDegrees, andTime: t[.Maghrib]!, JDate: JDate, lat: lat, lng: lng)
        return Maghrib
        
    case .Isha:
        let Isha: Double    = computeTime(G: calcMethod.methodParams.ishaDegrees, andTime: t[.Isha]!, JDate: JDate, lat: lat, lng: lng)
        return Isha
        
    } // switch event
}

func computeDates(calcMethod: ASACalculationMethod, asrJuristic: ASAJuristicMethodForAsr, dhuhrMinutes: Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes, JDate: Double, lat: CLLocationDegrees, lng: CLLocationDegrees, baseDate: Date, events: Array<ASAIslamicPrayerTimeEvent>) -> Dictionary<ASAIslamicPrayerTimeEvent, Date>! {
    // We need to make sure events that are not requested but needed to compute other events are automagically included.
    var emendedEvents = events
    if emendedEvents.contains(.Isha) && !emendedEvents.contains(.Maghrib) {
        emendedEvents.append(.Maghrib)
    }
    if emendedEvents.contains(.Maghrib) && !emendedEvents.contains(.Sunset) {
        emendedEvents.append(.Sunset)
    }
    
    if adjustHighLats != .none {
        if !emendedEvents.contains(.Sunrise) {
            emendedEvents.append(.Sunrise)
        }
        
        if !emendedEvents.contains(.Sunset) {
            emendedEvents.append(.Sunset)
        }
    }
    
    var t1: Dictionary<ASAIslamicPrayerTimeEvent, Double> = [:]
    for key in emendedEvents {
        t1[key] = computeTime(calcMethod: calcMethod, asrJuristic: asrJuristic, JDate: JDate, lat: lat, lng: lng, event: key)
    }
    
    let t2 = adjustTimes(times: t1, calcMethod: calcMethod, dhuhrMinutes: dhuhrMinutes, adjustHighLats: adjustHighLats, lat: lat, lng: lng)
    
    var t3: Dictionary<ASAIslamicPrayerTimeEvent, Date> = [:]
    for (key, value) in t2 ?? [:] {
        t3[key] = adjustTimeDate(time: value, baseDate: baseDate)
    }
    
    return t3
}

// adjust times in a prayer time array
func adjustTimes(times: Dictionary<ASAIslamicPrayerTimeEvent, Double>!, calcMethod: ASACalculationMethod, dhuhrMinutes: Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes, lat: CLLocationDegrees, lng: CLLocationDegrees) -> Dictionary<ASAIslamicPrayerTimeEvent, Double>! {
    var time: Double = 0, Dtime: Double, Dtime1: Double, Dtime2: Double
    
    var result: Dictionary<ASAIslamicPrayerTimeEvent, Double> = times
    
    for i in result.keys {
        time = result[i]! - lng / 15.0
        
        result[i] = time
    }
    
    if result[.Dhuhr] != nil {
        Dtime = result[.Dhuhr]! + (dhuhrMinutes / 60.0) //Dhuhr
        
        result[.Dhuhr] = Dtime
    }
    
    if result[.Maghrib] != nil {
        let maghribFlag: Bool = calcMethod.methodParams.maghribFlag
        
        if maghribFlag == true { // Maghrib
            Dtime1 = result[.Sunset]! + (calcMethod.methodParams.maghribDegrees / 60.0)
            result[.Maghrib] = Dtime1
        }
    }
    
    if result[.Isha] != nil {
        if calcMethod.methodParams.ishaFlag == true { // Isha
            Dtime2 = result[.Maghrib]! + (calcMethod.methodParams.ishaDegrees / 60.0)
            result[.Isha] = Dtime2
        }
    }
    
    if adjustHighLats != .none {
        result = adjustHighLatTimes(times: result, calcMethod: calcMethod, adjustHighLats: adjustHighLats)
    }
    return result
}

func adjustTimeDate(time: Double!, baseDate: Date) -> Date! {
    let resultDate = baseDate.addingTimeInterval(time * 60.0 * 60.0)
    return resultDate
}


// adjust Fajr, Isha and Maghrib for locations in higher latitudes
func adjustHighLatTimes(times: Dictionary<ASAIslamicPrayerTimeEvent, Double>, calcMethod: ASACalculationMethod, adjustHighLats: ASAAdjustingMethodForHigherLatitudes) -> Dictionary<ASAIslamicPrayerTimeEvent, Double>! {
    
    let sunriseTime: Double = times[.Sunrise]!
    let sunsetTime: Double = times[.Sunset]!
    
    let nightTime:Double = timeDiff(time1: sunsetTime, andTime2:sunriseTime) // sunset to sunrise
    
    var result = times
    
    if result[.Fajr] != nil {
        // Adjust Fajr
        let fajrTime: Double = times[.Fajr]!
        let fajrDegrees:Double = calcMethod.methodParams.fajrDegrees
        
        let FajrDiff:Double = nightPortion(angle: fajrDegrees, adjustHighLats: adjustHighLats) * nightTime
        
        if fajrTime.isNaN || (timeDiff(time1: fajrTime, andTime2:sunriseTime) > FajrDiff) {
            result[.Sunrise] = sunriseTime - FajrDiff
        }
    }
    
    if result[.Isha] != nil {
        // Adjust Isha
        let ishaTime: Double = times[.Isha]!
        let ishaFlag: Bool = calcMethod.methodParams.ishaFlag
        let ishaDegrees: Double = calcMethod.methodParams.ishaDegrees
        let IshaAngle: Double = (ishaFlag == false) ? ishaDegrees: 18
        let IshaDiff: Double = nightPortion(angle: IshaAngle, adjustHighLats: adjustHighLats) * nightTime
        if ishaTime.isNaN || timeDiff(time1: sunsetTime, andTime2: ishaTime) > IshaDiff {
            result[.Isha] = sunsetTime + IshaDiff
        }
    }
    
    if result[.Maghrib] != nil {
        // Adjust Maghrib
        let maghribTime: Double = times[.Maghrib]!
        let maghribFlag: Bool = calcMethod.methodParams.maghribFlag
        let maghribDegrees: Double = calcMethod.methodParams.maghribDegrees
        let MaghribAngle: Double = (maghribFlag == false) ? maghribDegrees : 4
        let MaghribDiff: Double = nightPortion(angle: MaghribAngle, adjustHighLats: adjustHighLats) * nightTime
        if maghribTime.isNaN || timeDiff(time1: sunsetTime, andTime2: maghribTime) > MaghribDiff {
            result[.Maghrib] = sunsetTime + MaghribDiff
        }
    }
    
    return result
}


// the night portion used for adjusting times in higher latitudes
func nightPortion(angle:Double, adjustHighLats: ASAAdjustingMethodForHigherLatitudes) -> Double {
    var calc:Double = 0
    
    if adjustHighLats == .angleBased
    {calc = (angle)/60.0}
    else if adjustHighLats == .midnight
    {calc = 0.5}
    else if adjustHighLats == .oneSeventh
    {calc = 0.14286}
    
    return calc
}
