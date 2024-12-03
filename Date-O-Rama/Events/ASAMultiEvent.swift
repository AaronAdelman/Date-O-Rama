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
        let locations = self.events.compactMap { $0.location }
        return locations.asFormattedList
    }
    
    var availability: EKEventAvailability = .notSupported
    
    var startDate: Date! {
        return self.events[0].startDate
    }
    
    var endDate: Date! {
        return self.events[0].endDate
    }
    
    var startDateString: String? {
        let index = self.events.firstIndex(where: {$0.startDateString != nil})
        if index != nil {
            return self.events[index!].startDateString
        } else {
            return nil
        }
    }
    
    var endDateString: String? {
        let index = self.events.firstIndex(where: {$0.endDateString != nil})
        if index != nil {
            return self.events[index!].endDateString
        } else {
            return nil
        }
    }
    
    var secondaryStartDateString: String? {
        let index = self.events.firstIndex(where: {$0.secondaryStartDateString != nil})
        if index != nil {
            return self.events[index!].secondaryStartDateString
        } else {
            return nil
        }
    }
    
    var secondaryEndDateString: String? {
        let index = self.events.firstIndex(where: {$0.secondaryEndDateString != nil})
        if index != nil {
            return self.events[index!].secondaryEndDateString
        } else {
            return nil
        }
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
    
//    var url: URL? = nil
    
    var urls: Array<URL> {
        var temp: Array<URL> = []
        for event in events {
            for url in event.urls {
                if !temp.contains(url) {
                    temp.append(url)
                }
            } // for url
        } // for event
        return temp
    } // var urls: Array<URL>
    
//    var hasNotes: Bool = false
//
//    var notes: String? = nil
    
    var allNotes: Array<String> {
        var temp: Array<String> = []
        for event in events {
            for notes in event.allNotes {
                if !temp.contains(notes) {
                    temp.append(notes)
                }
            } // for notes
        } // for event
        return temp
    } // var allNotes: Array<String>
    
    var color: Color = .primary
    
    var colors: Array<Color> {
        return self.events.map { $0.color }
    }

    var calendarTitleWithLocation: String {
        return self.events.map { $0.calendarTitleWithLocation }.asFormattedList ?? ""
    }
    
    var longCalendarTitle: String {
        return self.events.map { $0.calendarTitle }.asFormattedList ?? ""
    }
    
    var calendarTitle: String {
        let numberOfEvents = self.events.count
        if numberOfEvents >= 4 {
            let firstEventTitle = self.events[0].calendarTitle
            let numberOfExtraEvents = numberOfEvents - 1
            return String.localizedStringWithFormat("%@ + %d", firstEventTitle, numberOfExtraEvents)
        } else {
            return self.longCalendarTitle
        }
    }
    
    var calendarCode: ASACalendarCode {
        return self.events[0].calendarCode
    }
    
    var geoLocation: CLLocation? = nil
    
    var isReadOnly: Bool = true
    
    var regionCodes: Array<String>? = nil
    
    var excludeRegionCodes: Array<String>? = nil
        
    var emoji: String? {
        if self.events.count == 0 {
            return nil
        }
        
        for event in self.events {
            let emoji = event.emoji
            if emoji != nil {
                return emoji
            }
        }
        
        return nil
    }
    
    var fileEmoji: String? {
        let fileEmojis = self.events.map { $0.fileEmoji }
        var reduced: String?
        for fileEmoji in fileEmojis {
            if fileEmoji != nil {
                reduced = reduced == nil ? fileEmoji! : reduced! + fileEmoji!
            }
        }
        
        return reduced
    }
    
    var type: ASAEventSpecificationType {
        self.events[0].type
    }
    
    init(event: ASAEventCompatible) {
        self.events = [event]
    }
    
    public mutating func append(event: ASAEventCompatible) {
        self.events.append(event)
        self.events.sort(by: { $0.calendarTitle < $1.calendarTitle })
    } // func append(event: ASAEventCompatible)
    
    var numberOfSubevents: Int {
        return self.events.count
    }
}
