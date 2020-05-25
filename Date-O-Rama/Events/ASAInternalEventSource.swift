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

    func eventDetails(startDate:  Date, endDate:  Date, location:  CLLocation, timeZone:  TimeZone, eventCalendarName:  String) -> Array<ASAEvent>
} // protocol ASAInternalEventSource
