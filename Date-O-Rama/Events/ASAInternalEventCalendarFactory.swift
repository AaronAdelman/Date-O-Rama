//
//  ASAInternalEventCalendarFactory.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

class ASAInternalEventCalendarFactory {
    class func eventCalendar(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventCalendar? {
        
        let result = ASAInternalEventCalendar()
        result.eventSourceCode = eventSourceCode
        result.locationData = ASALocationManager.shared().locationData
        result.usesDeviceLocation = true
        return result
    } //class func eventCalendar(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventCalendar?
    
    class func eventCalendarSource(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventSource? {
        switch eventSourceCode {
        case .dailyJewish:
            return ASAJSONFileEventSource(fileName: "Daily Jewish events")

        case .solar:
            return ASAJSONFileEventSource(fileName: "Solar events")
            
        default:
            return nil
        } // switch eventSourceCode
    }
} // class ASAInternalEventCalendarFactory
