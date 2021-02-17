//
//  ASAPolarLighting.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import CoreLocation
import Foundation


enum ASAPolarLighting {
    case sunDoesNotSet
    case sunDoesNotRise
    case cannotTell

    static func given(month:  Int, latitude: CLLocationDegrees, calendarCode:  ASACalendarCode) -> ASAPolarLighting {
        if calendarCode.isHebrewCalendar {
            if month < 8 {
                // Winter in Northern Hemisphere
                if latitude > 0 {
                    return sunDoesNotRise
                } else {
                    return sunDoesNotSet
                }
            } else {
                // Summer in Northern Hemisphere
                if latitude > 0 {
                    return sunDoesNotSet
                } else {
                    return sunDoesNotRise
                }
            }
        } else {
            return cannotTell
        }
    }
} // enum ASAPolarLighting
