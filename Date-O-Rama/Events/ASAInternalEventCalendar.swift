//
//  ASAInternalEventCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

class ASAInternalEventCalendar:  ASALocatedObject {
    var eventSource:  ASAInternalEventSource?
    
    public func dictionary() -> Dictionary<String, Any> {
        
        return [:]
    }
    
    public class func newInternalEventCalendar(dictionary:  Dictionary<String, Any>) -> ASAInternalEventCalendar {
        
        return ASAInternalEventCalendar()
    }
    
    public func eventCalendarName() -> String {
        return self.eventSource!.eventCalendarName(locationData:  locationData)
    }
    
    func eventDetails(startDate:  Date, endDate:  Date) -> Array<ASAEvent> {
        if eventSource == nil || self.locationData.location == nil {
        return []
        }
        
        return self.eventSource!.eventDetails(startDate: startDate, endDate: endDate, location: self.locationData.location!, timeZone: self.effectiveTimeZone, eventCalendarName: eventCalendarName())
    } // func eventDetails(startDate:  Date, endDate:  Date) -> Array<ASAEvent>
} // class ASAInternalEventCalendar
