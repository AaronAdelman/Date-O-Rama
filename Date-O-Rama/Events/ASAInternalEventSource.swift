//
//  ASAInternalEventSource.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

protocol ASAInternalEventSource {
    var eventSourceCode:  ASAInternalEventSourceCode { get }

    func eventDetails(startDate:  Date, endDate:  Date, locationData:  ASALocationData, eventCalendarName:  String) -> Array<ASAEvent>
    func eventCalendarName(locationData:  ASALocationData) -> String
    func eventSourceName() -> String
} // protocol ASAInternalEventSource
