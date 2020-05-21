//
//  ASAHebrewCalendarSupplement.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI

class ASAHebrewCalendarSupplement {
    class func eventDetails(startDate:  Date, endDate:  Date, location:  CLLocation, timeZone:  TimeZone) -> Array<ASAEvent> {
        debugPrint(#file, #function, startDate, endDate, location, timeZone)
        var now = startDate.oneDayBefore
        var result:  Array<ASAEvent> = []
        repeat {
            let temp = ASAHebrewCalendarSupplement.eventDetails(date: now, location: location, timeZone: timeZone)
            for event in temp {
                if !(event.endDate < startDate || event.startDate >= endDate) {
                    result.append(event)
                }
            } // for event in tempResult
            now = now.oneDayAfter
        } while now < endDate
        
        return result
    }
    
    fileprivate static func calendarTitle() -> String {
        return NSLocalizedString("Jewish calendar", comment: "")
    } // static func calendarTitle() -> String
    
    fileprivate static func calendarColor() -> Color {
        return Color(UIColor.systemBlue)
    } // static func calendarColor() -> Color
    
    class func eventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone) -> Array<ASAEvent> {
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let previousDate = date.oneDayBefore
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset
//            , .dusk
        ], timeZone:  timeZone )
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה

        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .dawn, .recognition, .dusk], timeZone:  timeZone )
        
        // According to the גר״א
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        let nightLength = sunrise.timeIntervalSince(previousSunset)
        let midnight =  previousSunset.addingTimeInterval(0.5 * nightLength)
        
        let dayLength = sunset.timeIntervalSince(sunrise)
        let hourLength = dayLength / 12.0
        
        let dawn           = events[.dawn]!! // עלות השחר
        let recognition    = events[.recognition]!! // משיכיר
        //        let hour01         = sunrise.addingTimeInterval( 1    * hourLength)
        //        let hour02         = sunrise.addingTimeInterval( 2    * hourLength)
        let hour03         = sunrise.addingTimeInterval( 3    * hourLength) // סוף זמן קריאת שמע
        let hour04         = sunrise.addingTimeInterval( 4    * hourLength) // סוף זמן תפילה
        //        let hour05         = sunrise.addingTimeInterval( 5    * hourLength)
        let hour06         = sunrise.addingTimeInterval( 6    * hourLength) // חצות
        let hour06½        = sunrise.addingTimeInterval( 6.5  * hourLength) // מנחה גדולה
        //        let hour07         = sunrise.addingTimeInterval( 7    * hourLength)
        //        let hour08         = sunrise.addingTimeInterval( 8    * hourLength)
        //        let hour09         = sunrise.addingTimeInterval( 9    * hourLength)
        let hour09½        = sunrise.addingTimeInterval( 9.5  * hourLength) // מנחה קטנה
        //        let hour10         = sunrise.addingTimeInterval(10    * hourLength)
        let hour10¾        = sunrise.addingTimeInterval(10.75 * hourLength) // פלג המנחה
        //        let hour11         = sunrise.addingTimeInterval(11    * hourLength)
        let candelLighting = sunset.addingTimeInterval(-18 * 60) // הדלקת נרות
        let dusk           = events[.dusk]!! // צאת הכוכבים
        
        // According to the מגן אברהם
        let otherDawn = sunrise.sunriseToOtherDawn() // עלות השחר
        let otherDusk = sunset.sunsetToOtherDusk() // צאת הכוכבים
        let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
        let otherHourLength = otherDayLength / 12.0
        
        //        let otherHour01  = otherDawn.addingTimeInterval( 1    * otherHourLength)
        //        let otherHour02  = otherDawn.addingTimeInterval( 2    * otherHourLength)
        let otherHour03  = otherDawn.addingTimeInterval( 3    * otherHourLength) // סוף זמן קריאת שמע
        let otherHour04  = otherDawn.addingTimeInterval( 4    * otherHourLength) // סוף זמן תפילה
        //        let otherHour05  = otherDawn.addingTimeInterval( 5    * otherHourLength)
        //        let otherHour06  = otherDawn.addingTimeInterval( 6    * otherHourLength) // חצות
        let otherHour06½ = otherDawn.addingTimeInterval( 6.5  * otherHourLength) // מנחה גדולה
        //        let otherHour07  = otherDawn.addingTimeInterval( 7    * otherHourLength)
        //        let otherHour08  = otherDawn.addingTimeInterval( 8    * otherHourLength)
        //        let otherHour09  = otherDawn.addingTimeInterval( 9    * otherHourLength)
        let otherHour09½ = otherDawn.addingTimeInterval( 9.5  * otherHourLength) // מנחה קטנה
        //        let otherHour10  = otherDawn.addingTimeInterval(10    * otherHourLength)
        let otherHour10¾ = otherDawn.addingTimeInterval(10.75 * otherHourLength) // פלג המנחה
        //        let otherHour11  = otherDawn.addingTimeInterval(11    * otherHourLength)
        
        return [
//            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: previousSunset, endDate: previousSunset, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
//            ASAEvent(title: NSLocalizedString(DUSK_KEY, comment: ""), startDate: previousDusk, endDate: previousDusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
//            ASAEvent(title: NSLocalizedString(OTHER_DUSK_KEY, comment: ""), startDate: previousOtherDusk, endDate: previousOtherDusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(MIDNIGHT_KEY, comment: ""), startDate: midnight, endDate: midnight, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(DAWN_KEY, comment: ""), startDate: dawn, endDate: dawn, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_DAWN_KEY, comment: ""), startDate: otherDawn, endDate: otherDawn, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(RECOGNITION_KEY, comment: ""), startDate: recognition, endDate: recognition, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(SUNRISE_KEY, comment: ""), startDate: sunrise, endDate: sunrise, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_03_KEY, comment: ""), startDate: otherHour03, endDate: otherHour03, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(HOUR_03_KEY, comment: ""), startDate: hour03, endDate: hour03, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_04_KEY, comment: ""), startDate: otherHour04, endDate: otherHour04, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(HOUR_04_KEY, comment: ""), startDate: hour04, endDate: hour04, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(NOON_KEY, comment: ""), startDate: hour06, endDate: hour06, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(HOUR_06½_KEY, comment: ""), startDate: hour06½, endDate: hour06½, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_06½_KEY, comment: ""), startDate: otherHour06½, endDate: otherHour06½, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(HOUR_09½_KEY, comment: ""), startDate: hour09½, endDate: hour09½, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_09½_KEY, comment: ""), startDate: otherHour09½, endDate: otherHour09½, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(HOUR_10¾_KEY, comment: ""), startDate: hour10¾, endDate: hour10¾, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_HOUR_10¾_KEY, comment: ""), startDate: otherHour10¾, endDate: otherHour10¾, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(CANDLELIGHTING_KEY, comment: ""), startDate: candelLighting, endDate: candelLighting, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: sunset, endDate: sunset, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(DUSK_KEY, comment: ""), startDate: dusk, endDate: dusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
            ASAEvent(title: NSLocalizedString(OTHER_DUSK_KEY, comment: ""), startDate: otherDusk, endDate: otherDusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  calendarTitle()),
        ]
    } // func HebrewEventDetails(date:  Date, location:  CLLocation) -> Array<ASADetail>
}
