//
//  EKEventAvailabilityExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

extension EKEventAvailability {
    var text: String {
        var rawValue = ""
        
        switch self {
        case .notSupported:
            rawValue = "EKEventAvailability.notSupported"
        
        case .busy:
            rawValue = "EKEventAvailability.busy"

        case .free:
            rawValue = "EKEventAvailability.free"

        case .tentative:
            rawValue = "EKEventAvailability.tentative"

        case .unavailable:
            rawValue = "EKEventAvailability.unavailable"

        @unknown default:
            rawValue = "EKEventAvailability.@unknown default"
        } // switch self
        
        return NSLocalizedString(rawValue, comment: "")
    }
} // extension EKEventAvailability
