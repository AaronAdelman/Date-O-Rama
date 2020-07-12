//
//  ASAJSONFileEventSource.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

class ASAJSONFileEventSource:  ASAInternalEventSource {
    var eventsFile:  ASAInternalEventsFile

    init(fileName:  String) {
        let fileURL = Bundle.main.url(forResource:fileName, withExtension: "json")!

        let jsonData = (try? Data(contentsOf: fileURL))!
        let newJSONDecoder = JSONDecoder()
        let eventsFile = try? newJSONDecoder.decode(ASAInternalEventsFile.self, from: jsonData)
        self.eventsFile = eventsFile!
    }
    
    var eventSourceCode: ASAInternalEventSourceCode {
        get {
            return ASAInternalEventSourceCode.init(rawValue: self.eventsFile.eventSourceCode)!
        }
    }
    
    func eventDetails(startDate: Date, endDate: Date, location: CLLocation, timeZone: TimeZone, eventCalendarName: String) -> Array<ASAEvent> {
        debugPrint(#file, #function, startDate, endDate, location, timeZone)
        var now = startDate.oneDayBefore
        var result:  Array<ASAEvent> = []
        var oldNow = now
        repeat {
            let temp = self.eventDetails(date: now, location: location, timeZone: timeZone, eventCalendarName: eventCalendarName)
            for event in temp {
                debugPrint(#file, #function, startDate, endDate, event.title ?? "No title", event.startDate ?? "No start date", event.endDate ?? "No end date")

                if !(event.endDate < startDate || event.startDate >= endDate) {
                    result.append(event)
                }
            } // for event in tempResult
            oldNow = now
            now = now.oneDayAfter
        } while oldNow < endDate
        
        return result
    } // func eventDetails(startDate: Date, endDate: Date, location: CLLocation, timeZone: TimeZone, eventCalendarName: String) -> Array<ASAEvent>
    
    fileprivate func calendarColor() -> Color {
        return Color(self.eventsFile.calendarColor)
    } // static func calendarColor() -> Color
    
    func eventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone, eventCalendarName: String) -> Array<ASAEvent> {
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let previousDate = date.oneDayBefore
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk72Minutes], timeZone:  timeZone)
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        let previousOtherDusk:  Date = previousEvents[.dusk72Minutes]!!
        
        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
        
        // According to the גר״א
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        let nightLength = sunrise.timeIntervalSince(previousSunset)
        let nightHourLength = nightLength / 12.0

        let dayLength = sunset.timeIntervalSince(sunrise)
        let hourLength = dayLength / 12.0

        // According to the מגן אברהם
        let otherDawn = events[.dawn72Minutes]!! // עלות השחר
        let otherDusk = events[.dusk72Minutes]!! // צאת הכוכבים
        
        let otherNightLength = otherDawn.timeIntervalSince(previousOtherDusk)
        let otherNightHourLength = otherNightLength / 12.0

        let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
        let otherHourLength = otherDayLength / 12.0

        var result:  Array<ASAEvent> = []
        for eventSpecification in self.eventsFile.eventSpecifications {
            let title = NSLocalizedString(eventSpecification.localizableTitle!, comment: "")
            let color = self.calendarColor()
            
            switch eventSpecification.startDateSpecification.type {
            case .degreesBelowHorizon:
                let solarEvent = ASASolarEvent(degreesBelowHorizon: eventSpecification.startDateSpecification.degreesBelowHorizon!, rising: eventSpecification.startDateSpecification.rising!, offset: eventSpecification.startDateSpecification.offset!)
                
                let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
                let date = events[solarEvent]
                
                let newEvent = ASAEvent(title: title, startDate: date!!, endDate: date!!, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                result.append(newEvent)
                
            case .solarTimeSunriseSunset:
                let hours = eventSpecification.startDateSpecification.solarHours!
                let dayHalf = eventSpecification.startDateSpecification.dayHalf!
                switch dayHalf {
                case .night:
                    let date = previousSunset + hours * nightHourLength
                    let newEvent = ASAEvent(title: title, startDate: date, endDate: date, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                    result.append(newEvent)
                    
                case .day:
                    let date = sunrise + hours * hourLength
                    let newEvent = ASAEvent(title: title, startDate: date, endDate: date, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                    result.append(newEvent)
                } // switch dayHalf
                
            case .solarTimeDawn72MinutesDusk72Minutes:
                let hours = eventSpecification.startDateSpecification.solarHours!
                let dayHalf = eventSpecification.startDateSpecification.dayHalf!
                switch dayHalf {
                case .night:
                    let date = previousOtherDusk + hours * otherNightHourLength
                    let newEvent = ASAEvent(title: title, startDate: date, endDate: date, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                    result.append(newEvent)
                    
                case .day:
                    let date = otherDawn + hours * otherHourLength
                    let newEvent = ASAEvent(title: title, startDate: date, endDate: date, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                    result.append(newEvent)
                } // switch dayHalf

            } // switch programmedEvent.type
        } // for programmedEvent in self.eventsFile.events
        return result
    } // func eventDetails(date:  Date, location:  CLLocation, timeZone:  TimeZone, eventCalendarName: String) -> Array<ASAEvent>
    
    func eventCalendarName(locationData:  ASALocationData) -> String {
        return "\(NSLocalizedString(self.eventsFile.localizableTitle!, comment: "")) • \(locationData.formattedOneLineAddress())"
    } // func eventCalendarName(locationData:  ASALocationData) -> String
    
    func eventSourceName() -> String {
        return NSLocalizedString(self.eventsFile.localizableTitle!, comment:  "")
    } // func eventSourceName() -> String} // class ASASolarEventSource:  ASAInternalEventSource
}
