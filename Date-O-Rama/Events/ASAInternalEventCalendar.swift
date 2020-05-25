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
    
    func eventDetails(startDate:  Date, endDate:  Date) -> Array<ASAEvent> {
        
        return []
    } // func eventDetails(startDate:  Date, endDate:  Date) -> Array<ASAEvent>
} // class ASAInternalEventCalendar
