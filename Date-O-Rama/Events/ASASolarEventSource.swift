//
//  ASASolarEventSource.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

class ASASolarEventSource:  ASAInternalEventSource {
    var eventSourceCode: ASAInternalEventSourceCode = .solar
    
        func eventDetails(startDate: Date, endDate: Date, location: CLLocation, timeZone: TimeZone, eventCalendarName: String) -> Array<ASAEvent> {
            debugPrint(#file, #function, startDate, endDate, location, timeZone)
            var now = startDate.oneDayBefore
            var result:  Array<ASAEvent> = []
            repeat {
                let temp = self.eventDetails(date: now, location: location, timeZone: timeZone, eventCalendarName: eventCalendarName)
                for event in temp {
                    if !(event.endDate < startDate || event.startDate >= endDate) {
                        result.append(event)
                    }
                } // for event in tempResult
                now = now.oneDayAfter
            } while now < endDate
            
            return result
        }
        
        fileprivate func calendarColor() -> Color {
            return Color(UIColor.systemYellow)
        } // static func calendarColor() -> Color
        
         func eventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone, eventCalendarName: String) -> Array<ASAEvent> {
            let latitude  = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .civilDawn, .civilDusk, .nauticalDawn, .nauticalDusk, .astronomicalDawn, .astronomicalDusk], timeZone:  timeZone )
            
            let sunrise:  Date = events[.sunrise]!! // נץ
            let sunset:  Date = events[.sunset]!! // שקיעה
            
            let civilDawn:  Date = events[.civilDawn]!!
            let civilDusk:  Date = events[.civilDusk]!!

            let nauticalDawn:  Date = events[.nauticalDawn]!!
            let nauticalDusk:  Date = events[.nauticalDusk]!!

            let astronomicalDawn:  Date = events[.astronomicalDawn]!!
            let astronomicalDusk:  Date = events[.astronomicalDusk]!!

            return [
                ASAEvent(title: NSLocalizedString(ASTRONOMICAL_DAWN_KEY, comment: ""), startDate: astronomicalDawn, endDate: astronomicalDawn, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),
                ASAEvent(title: NSLocalizedString(NAUTICAL_DAWN_KEY, comment: ""), startDate: nauticalDawn, endDate: nauticalDawn, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),
                ASAEvent(title: NSLocalizedString(CIVIL_DAWN_KEY, comment: ""), startDate: civilDawn, endDate: civilDawn, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),

                ASAEvent(title: NSLocalizedString(SUNRISE_KEY, comment: ""), startDate: sunrise, endDate: sunrise, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),

                ASAEvent(title: NSLocalizedString(SUNSET_KEY, comment: ""), startDate: sunset, endDate: sunset, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),
                
                ASAEvent(title: NSLocalizedString(CIVIL_DUSK_KEY, comment: ""), startDate: civilDusk, endDate: civilDusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),
                ASAEvent(title: NSLocalizedString(NAUTICAL_DUSK_KEY, comment: ""), startDate: nauticalDusk, endDate: nauticalDusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName),
                ASAEvent(title: NSLocalizedString(ASTRONOMICAL_DUSK_KEY, comment: ""), startDate: astronomicalDusk, endDate: astronomicalDusk, isAllDay: false, timeZone: timeZone, color: calendarColor(), calendarTitle:  eventCalendarName)
            ]
        } // func eventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone, eventCalendarName: String) -> Array<ASAEvent>
    
    func eventCalendarName(locationData:  ASALocationData) -> String {
        return "\(NSLocalizedString("Solar events", comment: "")) • \(locationData.formattedOneLineAddress())"
    } // func eventCalendarName(locationData:  ASALocationData) -> String
    
    func eventSourceName() -> String {
        return NSLocalizedString("Daily solar events", comment:  "")
    } // func eventSourceName() -> String} // class ASASolarEventSource:  ASAInternalEventSource
}
