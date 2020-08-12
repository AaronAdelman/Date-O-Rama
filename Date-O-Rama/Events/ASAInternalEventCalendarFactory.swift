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
    class func eventCalendar(eventSourceCode:  String) -> ASAInternalEventCalendar? {
        
        let result = ASAInternalEventCalendar()
        result.eventSourceCode = eventSourceCode
        result.locationData = ASALocationManager.shared().locationData
        result.usesDeviceLocation = true
        return result
    } //class func eventCalendar(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventCalendar?
    
    class func eventCalendarSource(eventSourceCode:  String) -> ASAJSONFileEventSource? {
//        switch eventSourceCode {
//        case .allDayJewish:
//            return ASAJSONFileEventSource(fileName: "All-day Jewish events")
//
//        case .dailyJewish:
//            return ASAJSONFileEventSource(fileName: "Daily Jewish events")
//
//        case .solar:
//            return ASAJSONFileEventSource(fileName: "Solar events")
//
//        case .israeli:
//            return ASAJSONFileEventSource(fileName: "Israeli events")
//
//        case .lubavitch:
//            return ASAJSONFileEventSource(fileName: "Lubavitch events")
//
//        case .test:
//            return ASAJSONFileEventSource(fileName: "Test")
//
//        default:
//            return nil
//        } // switch eventSourceCode
        return ASAJSONFileEventSource(fileName: eventSourceCode)
    }
} // class ASAInternalEventCalendarFactory
