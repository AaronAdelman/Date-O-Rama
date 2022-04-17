//
//  ASAMultiEvent.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 19/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit


struct ASAMultiEvent:  ASAEventCompatible {
    var events: Array<ASAEventCompatible> = []
    
    var isAllDay: Bool {
        return self.events[0].isAllDay
    }
    
    var eventIdentifier: String! = "\(UUID())"

    var title: String! {
        if self.events.isEmpty {
            return "???"
        }
        
        return self.events[0].title
    }
    
    var location: String? {
        let locations = self.events.map { $0.location }
        var reduced: Array<String> = []
        for location in locations {
            if location != nil {
                reduced.append(location!)
            }
        }
        
        return reduced.asFormattedList
    }
    
    var availability: EKEventAvailability = .notSupported
    
    var startDate: Date! {
        return self.events[0].startDate
    }
    
    var endDate: Date! {
        return self.events[0].endDate
    }
    
    var organizer: EKParticipant? = nil
    
    var hasAttendees: Bool = false
    
    var attendees: [EKParticipant]? = nil
    
    var hasAlarms: Bool = false
    
    var alarms: [EKAlarm]? = nil
    
    var hasRecurrenceRules: Bool = false
    
    var recurrenceRules: [EKRecurrenceRule]? = nil
    
    var status: EKEventStatus = .none
    
    var timeZone: TimeZone? {
        return self.events[0].timeZone
    }
    
    var url: URL? = nil
    
    var hasNotes: Bool = false
    
    var notes: String? = nil
    
    var color: Color = .primary
    
    var colors: Array<Color> {
        return self.events.map { $0.color }
    }

    var calendarTitleWithLocation: String {
        return self.events.map { $0.calendarTitleWithLocation }.asFormattedList ?? ""
    }
    
    var calendarTitleWithoutLocation: String {
        return self.events.map { $0.calendarTitleWithoutLocation }.asFormattedList ?? ""
    }
    
    var calendarCode: ASACalendarCode {
        return self.events[0].calendarCode
    }
    
    var geoLocation: CLLocation? = nil
    
    var isReadOnly: Bool = true
    
    var regionCodes: Array<String>? = nil
    
    var excludeRegionCodes: Array<String>? = nil
    
    var category: ASAEventCategory = .generic
    
    var emoji: String? {
        if self.events.count == 0 {
            return nil
        }
        
        return self.events[0].emoji
    }
    
    var fileEmoji: String? {
        let fileEmojis = self.events.map { $0.fileEmoji }
        var reduced: Array<String> = []
        for fileEmoji in fileEmojis {
            if fileEmoji != nil {
                reduced.append(fileEmoji!)
            }
        }
        
        return reduced.asFormattedList
    }
    
    var type: ASAEventSpecificationType {
        self.events[0].type
    }
    
    init(event: ASAEventCompatible) {
        self.events = [event]
    }
    
    public mutating func append(event: ASAEventCompatible) {
        self.events.append(event)
    } // func append(event: ASAEventCompatible)
}
