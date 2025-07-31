//
//  ASAProcessedTime.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

struct ASAProcessedTime: Hashable, Identifiable {
    let id = UUID()
    var timeString:  String?
    var transitionType:  ASATransitionType
    
    init(clock:  ASAClock, now:  Date, location: ASALocation, usesDeviceLocation: Bool) {
        let (dateString, timeString, dateComponents) = clock.dateStringTimeStringDateComponents(now: now, location: location)
        self.timeString = timeString ?? dateString
        self.transitionType = clock.calendar.transitionType
    }
} // struct ASAProcessedTimes
