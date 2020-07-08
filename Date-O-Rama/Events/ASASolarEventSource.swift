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
    var eventsFile:  ASAEventsFile

    init() {
        let fileURL = Bundle.main.url(forResource:"Solar events", withExtension: "json")!

        let jsonData = (try? Data(contentsOf: fileURL))!
        let newJSONDecoder = JSONDecoder()
        let eventsFile = try? newJSONDecoder.decode(ASAEventsFile.self, from: jsonData)
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
        
        var result:  Array<ASAEvent> = []
        for programmedEvent in self.eventsFile.events {
            let title = NSLocalizedString(programmedEvent.localizableTitle!, comment: "")
            let color = self.calendarColor()
            if programmedEvent.type == .degreesBelowHorizon {
                let solarEvent = ASASolarEvent(degreesBelowHorizon: programmedEvent.degreesBelowHorizon!, rising: programmedEvent.rising!, offset: programmedEvent.offset!)
                
                let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
                let date = events[solarEvent]
                
                let newEvent = ASAEvent(title: title, startDate: date!!, endDate: date!!, isAllDay: programmedEvent.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                result.append(newEvent)
            }
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
