//
//  EKRecurrenceFrequencyExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 04/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import Foundation

extension EKRecurrenceFrequency {
    var text: String {
        var rawValue = ""

        switch self {
        case .daily:
            rawValue = "EKRecurrenceFrequency_daily"

        case .weekly:
            rawValue = "EKRecurrenceFrequency_weekly"

        case .monthly:
            rawValue = "EKRecurrenceFrequency_monthly"

        case .yearly:
            rawValue = "EKRecurrenceFrequency_yearly"

        @unknown default:
            return "???"
        } // switch self
        return NSLocalizedString(rawValue, comment: "")
    } // var text
} //extension EKRecurrenceFrequency
