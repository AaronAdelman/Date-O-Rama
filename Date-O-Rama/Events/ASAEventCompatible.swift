//
//  ASAEventCompatible.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation
import EventKit

protocol ASAEventCompatible {
    var eventIdentifier: String! { get }
    var title:  String! { get }
    var location: String? { get }
    
    var availability: EKEventAvailability { get } // The availability setting for the event.
    
    var startDate:  Date! { get }
    var endDate: Date! { get }
    var isAllDay: Bool { get }
    
    var organizer: EKParticipant? { get } // The organizer associated with the event.
    var hasAttendees: Bool { get } // A Boolean value that indicates whether the calendar item has attendees.
    var attendees: [EKParticipant]? { get } // The attendees associated with the calendar item, as an array of EKParticipant objects.
    
    var hasAlarms: Bool { get }// A Boolean value that indicates whether the calendar item has alarms.
    var alarms: [EKAlarm]? { get } // The alarms associated with the calendar item, as an array of EKAlarm objects.
    
    var hasRecurrenceRules: Bool { get } // A Boolean value that indicates whether the calendar item has recurrence rules.
    var recurrenceRules: [EKRecurrenceRule]? { get } // The recurrence rules for the calendar item.
    
    var status: EKEventStatus { get } // The status of the event.
    var timeZone: TimeZone? { get }
    var url: URL? { get } // The URL for the calendar item.
    var hasNotes: Bool { get } // A Boolean value that indicates whether the calendar item has notes.
    var notes: String? { get } // The notes associated with the calendar item.
    var color:  Color { get }
    var calendarTitleWithLocation:  String { get }
    var calendarTitleWithoutLocation:  String { get }
    var calendarCode:  ASACalendarCode { get }
    var isEKEvent:  Bool { get }
    var geoLocation: CLLocation? { get }
    var isReadOnly: Bool { get }
    
    var regionCodes:  Array<String>? { get }
    var excludeRegionCodes:  Array<String>? { get }

    var category: ASAEventCategory { get }
    var emoji: String? { get }
    var fileEmoji: String? { get }
    
    var type: ASATimeSpecificationType { get }
} // protocol ASAEventCompatible


// MARK:  -

extension Array where Element == ASAEventCompatible {
    func forVisibility(_ visibility: ASAClockCellEventVisibility, now: Date) -> Array<ASAEventCompatible> {
        switch visibility {
        case .none:
            return []

        case .allDay:
            return self.allDayOnly
            
        case .next:
            return self.nextEvents(now: now)
            
        case .future:
            return self.futureOnly(now: now)
            
        case .present:
            return self.presentOnly(now: now)
            
        case .past:
            return self.pastOnly(now: now)
            
        case .all:
            return self
            
        case .nonAllDay:
            return self.nonAllDayOnly
        } // switch visibility
    } // func forVisibility(visibility: ASAClockCellEventVisibility, now: Date) -> Array<ASAEventCompatible>
    
    var allDayOnly:  Array<ASAEventCompatible> {
        var selectedEvents:  Array<ASAEventCompatible> = []
        for event in self {
            if event.isAllDay {
                selectedEvents.append(event)
            }
        } // for event in self
        return selectedEvents
    } // var allDayOnly
    
    var nonAllDayOnly:  Array<ASAEventCompatible> {
        var selectedEvents:  Array<ASAEventCompatible> = []
        for event in self {
            if !event.isAllDay {
                selectedEvents.append(event)
            }
        } // for event in self
        return selectedEvents
    } // var nonAllDayOnly

    func futureOnly(now: Date) -> Array<ASAEventCompatible> {
        var selectedEvents:  Array<ASAEventCompatible> = []

        for event in self {
            if event.startDate >= now {
                selectedEvents.append(event)
            }
        } // for event in self
        return selectedEvents
    } // func futureOnly(now: Date) -> Array<ASAEventCompatible>
    
    func presentOnly(now: Date) -> Array<ASAEventCompatible> {
        var selectedEvents:  Array<ASAEventCompatible> = []

        for event in self {
            if event.startDate <= now && now < event.endDate {
                selectedEvents.append(event)
            }
        } // for event in self
        return selectedEvents
    } // func presentOnly(now: Date) -> Array<ASAEventCompatible>
    
    func pastOnly(now: Date) -> Array<ASAEventCompatible> {
        var selectedEvents:  Array<ASAEventCompatible> = []

        for event in self {
            if event.endDate <= now {
                selectedEvents.append(event)
            }
        } // for event in self
        return selectedEvents
    } //
} // extension Array where Element == ASAEventCompatible


// MARK:  -

extension ASAEventCompatible {
    func isAllDay(for row: ASARow) -> Bool {
        return self.isAllDay && row.calendar.calendarCode == self.calendarCode && (row.locationData.timeZone.secondsFromGMT(for: self.startDate) == self.timeZone?.secondsFromGMT(for: self.startDate) || self.timeZone == nil)
    } // func isAllDay(for row: ASARow) -> Bool
    
    var hasParticipants: Bool {
        return self.hasAttendees || self.organizer != nil
    }
    
    var participants: [EKParticipant]? {
        if !self.hasParticipants {
            return nil
        }
        
        var result: [EKParticipant] = []
        if self.organizer != nil {
            result = [self.organizer!]
        }
        if self.hasAttendees {
            for attendee in self.attendees! {
                let doppelgänger = result.first(where: {
                    $0.url == attendee.url
                })
                
                if doppelgänger == nil {
                    result.append(attendee)
                }
            } // for attendee in self.attendees!
        }
        return result
    } // var participants: [EKParticipant]?
    
    var currentUser: EKParticipant? {
        if self.hasParticipants {
            for participant in self.participants! {
                if participant.isCurrentUser {
                    return participant
                }
            } // for participant in self.participants!
        }
        
        return nil
    } // var currentUser: EKParticipant?
    
    var symbol: String? {
        let emoji: String? = self.emoji
        if emoji != nil {
            return emoji!
        }
        
        let categoryEmoji: String? = self.category.emoji
        if categoryEmoji != nil {
            return categoryEmoji!
        }
        
        return self.fileEmoji
    } // var emoji
    
    var duration: TimeInterval {
        return self.endDate.timeIntervalSince(self.startDate)
    } // var duration
} // extension ASAEventCompatible
