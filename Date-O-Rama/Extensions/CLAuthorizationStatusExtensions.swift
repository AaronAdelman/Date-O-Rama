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
        get {
            switch self {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
            } // switch self
        } // get
    } // var authorizedAtLeastWhenInUse
} // extension CLAuthorizationStatus
