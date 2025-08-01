//
//  ASAProcessedTime.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

struct ASAMiniProcessedClock: ASAProcessedClockProtocol {
    var timeString:  String?
    var calendarType: ASACalendarType
    var transitionType:  ASATransitionType
    var hour:  Int?
    var minute:  Int?
    var second:  Int?
    var fractionalHour: Double?
    var dayHalf: ASADayHalf?
    
    init(clock:  ASAClock, now:  Date, location: ASALocation, usesDeviceLocation: Bool) {
        let (dateString, timeString, dateComponents) = clock.dateStringTimeStringDateComponents(now: now, location: location)
        self.hour   = dateComponents.hour
        self.minute = dateComponents.minute
        self.second = dateComponents.second
        self.fractionalHour = dateComponents.solarHours
        self.dayHalf = dateComponents.dayHalf
        self.timeString = timeString ?? dateString
        self.transitionType = clock.calendar.transitionType
        self.calendarType = clock.calendar.calendarCode.type
    }
} // struct ASAMiniProcessedClock
