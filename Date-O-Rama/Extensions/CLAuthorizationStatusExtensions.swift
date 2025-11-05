//
//  CLAuthorizationStatusExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import CoreLocation
import Foundation

public extension CLAuthorizationStatus {
    var authorizedAtLeastWhenInUse:  Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined:
            return true // Provisional
        case .restricted, .denied:
            return false
        @unknown default:
            return false
        } // switch self
    } // var authorizedAtLeastWhenInUse
} // extension CLAuthorizationStatus
