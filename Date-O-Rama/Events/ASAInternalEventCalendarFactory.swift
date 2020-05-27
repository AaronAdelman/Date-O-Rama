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
//        result.eventSource =  ASAInternalEventCalendarFactory.eventCalendarSource(eventSourceCode:  eventSourceCode)
        result.eventSourceCode = eventSourceCode
        result.locationData = ASALocationManager.shared().locationData
        result.usesDeviceLocation = true
        return result
    } //class func eventCalendar(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventCalendar?
    
    class func eventCalendarSource(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventSource? {
        switch eventSourceCode {
        case .dailyJewish:
            return ASADailyJewishEventSource()
            
        case .solar:
            return ASASolarEventSource()
            
        default:
            return nil
        } // switch eventSourceCode
    }
} // class ASAInternalEventCalendarFactory
