//
//  ASAClockDistilation.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

protocol ASAProcessedClockProtocol {
    var timeString:  String? { get }
    var calendarType:  ASACalendarType { get }
    var transitionType:  ASATransitionType { get }
    var hour:  Int? { get }
    var minute:  Int? { get }
    var second:  Int? { get }
    var fractionalHour: Double? { get }
    var dayHalf: ASADayHalf? { get }
} // protocol ASAClockDistilation

enum ASADayPart {
    case day
    case night
    case unknown
} // enum ASADayPart

extension Array where Element: ASAProcessedClockProtocol {
    var dayPart: ASADayPart {
        // NOTE:  At some point I may want to make this based on the position of the Sun in the sky rather than clock time.
        
        let clock1 = self.first(where: { $0.transitionType == .sunset || $0.transitionType == .dusk })
        if clock1 != nil && clock1?.dayHalf != nil {
            return clock1!.dayHalf! == .day ? .day : .night
        }
        
        let clock2 = self.first(where: { $0.transitionType == .midnight })
        if clock2 != nil && clock2?.hour != nil {
            let hour = clock2!.hour!
            return (hour >= 6 && hour < 18) ? .day : .night
        }
        
        return .unknown
    } // var dayPart: ASADayPart
} // extension Array where Element == ASAProcessedClockProtocol

extension ASADayPart {
    var locationColor: Color {
        switch self {
        case .day:
            return Color("dayBackground")
        case .night:
            return Color("nightBackground")

        case .unknown:
            return Color("unknownBackground")
        }
    }
}
