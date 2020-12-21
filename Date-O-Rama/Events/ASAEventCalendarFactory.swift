//
//  ASAEventCalendarFactory.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

class ASAEventCalendarFactory {
    class func eventCalendar(eventSourceCode:  String) -> ASAEventCalendar? {
        let result = ASAEventCalendar()
        result.eventsFileName = eventSourceCode
        result.locationData = ASALocationManager.shared.deviceLocationData
        result.usesDeviceLocation = true
        return result
    } //class func eventCalendar(eventSourceCode:  ASAEventSourceCode) -> ASAEventCalendar?
    
//    class func eventCalendarSource(eventSourceCode:  String) -> ASAUnlocatedEventCalendar? {
//        return ASAUnlocatedEventCalendar(fileName: eventSourceCode)
//    }
} // class ASAEventCalendarFactory
