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
        
        switch eventSourceCode {
        case .dailyJewish:
            let result = ASAInternalEventCalendar()
            result.eventSource = ASADailyJewishEventSource()
            result.locationData = ASALocationManager.shared().locationData
            result.usesDeviceLocation = true
            return result
            
        default:
            return nil
        } // switch eventSourceCode
    } //class func eventCalendar(eventSourceCode:  ASAInternalEventSourceCode) -> ASAInternalEventCalendar?
} // class ASAInternalEventCalendarFactory
