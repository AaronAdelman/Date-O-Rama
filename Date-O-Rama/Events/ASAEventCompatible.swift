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

    var startDateString: String? { get }
    var endDateString: String? { get }
    var secondaryStartDateString: String? { get }
    var secondaryEndDateString: String? { get }
    
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
    var colors:  Array<Color> { get }
    var calendarTitleWithLocation:  String { get }
    var calendarTitleWithoutLocation:  String { get }
    var calendarCode:  ASACalendarCode { get }
    var geoLocation: CLLocation? { get }
    var isReadOnly: Bool { get }
    
    var regionCodes:  Array<String>? { get }
    var excludeRegionCodes:  Array<String>? { get }

    var emoji: String? { get }
    var fileEmoji: String? { get }
    
    var type: ASAEventSpecificationType { get }
} // protocol ASAEventCompatible


// MARK:  -

extension Array where Element == ASAEventCompatible {
    func trimmed(dateEventVisibility: ASAClockCellDateEventVisibility, now: Date) -> Array<ASAEventCompatible> {
        var temp: Array<ASAEventCompatible> = self

        switch dateEventVisibility {
        case .none:
            temp = []
            
        case .all:
            debugPrint(#file, #function, "Ignore this.")
            
        default:
            let maximumDuration = dateEventVisibility.cutoff
            temp = temp.filter {
                $0.duration <= maximumDuration
            }
        } // switch dateEventVisibility
        
        return temp
    } // func trimmed(dateEventVisibility: ASAClockCellDateEventVisibility, now: Date) -> Array<ASAEventCompatible>
    
    func trimmed(timeEventVisibility: ASAClockCellTimeEventVisibility, now: Date) -> Array<ASAEventCompatible> {
        var temp: Array<ASAEventCompatible> = self
 
        switch timeEventVisibility {
        case .none:
            temp = []
             
        case .next:
            temp = temp.nextEvents(now: now)
            
        case .future:
            temp = temp.futureOnly(now: now)
            
        case .present:
            temp = temp.presentOnly(now: now)
            
        case .past:
            temp = temp.pastOnly(now: now)
            
        case .all:
            debugPrint(#file, #function, "Ignore this.")
            
        case .nextAndPresent:
            temp = temp.nextAndPresentEvents(now: now)
        } // switch visibility
        
        return temp
    } // func trimmed(timeEventVisibility: ASAClockCellTimeEventVisibility, now: Date) -> Array<ASAEventCompatible>
    
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
            if event.contains(now: now) {
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
    } // func pastOnly(now: Date) -> Array<ASAEventCompatible>
    
    func nextEvents(now:  Date) -> Array<ASAEventCompatible> {
        var eventCalendarTitles: Array<String> = []
        for event in self {
            let eventCalendarTitle: String = event.calendarTitleWithoutLocation
            if !eventCalendarTitles.contains(eventCalendarTitle) {
                eventCalendarTitles.append(eventCalendarTitle)
            }
        }
        
        let nextEvents = self.nextEvents(eventCalendarTitles: eventCalendarTitles, now: now)
        return nextEvents
    } // func nextEvents(now:  Date) -> Array<ASAEventCompatible>
    
    fileprivate func nextEvents(eventCalendarTitles: Array<String>, now: Date) -> Array<ASAEventCompatible> {
        var nextEvents:  Array<ASAEventCompatible> = []
        
        for eventCalendarTitle in eventCalendarTitles {
            let firstIndex = self.firstIndex(where: { $0.startDate > now && $0.calendarTitleWithoutLocation == eventCalendarTitle })
            if firstIndex != nil {
                let firstItemStartDate = self[firstIndex!].startDate
                
                for i in firstIndex!..<self.count {
                    let item_i: ASAEventCompatible = self[i]
                    if item_i.startDate == firstItemStartDate && item_i.calendarTitleWithoutLocation == eventCalendarTitle {
                        nextEvents.append(item_i)
                    } else {
                        break
                    }
                } // for i
            }
        }
        
        nextEvents.sort(by: {$0.startDate < $1.startDate})
        
        return nextEvents
    } // func nextEvents(eventCalendarTitles: Array<String>, now: Date)
    
    func nextAndPresentEvents(now: Date) -> Array<ASAEventCompatible> {
        var presentEvents: Array<ASAEventCompatible> = []
        var eventCalendarTitles: Array<String> = []
        for event in self {
            let eventCalendarTitle: String = event.calendarTitleWithoutLocation
            if !eventCalendarTitles.contains(eventCalendarTitle) {
                eventCalendarTitles.append(eventCalendarTitle)
            }
            
            if event.contains(now: now) {
                presentEvents.append(event)
            }
        } // for event in self
        
        let nextEvents = self.nextEvents(eventCalendarTitles: eventCalendarTitles, now: now)
        return presentEvents + nextEvents
    } // func nextAndPresentEvents(now: Date) -> Array<ASAEventCompatible>
    
    mutating func add(event: ASAEventCompatible) {
        let index = self.firstIndex(where: {
            let titlesAreCloseEnough: Bool = ($0.title.withStraightenedCurlyQuotes.compare(event.title.withStraightenedCurlyQuotes, options: [.caseInsensitive, .diacriticInsensitive]) == ComparisonResult.orderedSame)
            let startDatesAreTheSame: Bool = $0.startDate == event.startDate
            let endDatesAreCloseEnough: Bool = abs($0.endDate.timeIntervalSince(event.endDate)) <= 1.0
            return titlesAreCloseEnough && startDatesAreTheSame && endDatesAreCloseEnough })
        if index == nil {
            self.append(event)
        } else {
            let preexistingEvent = self[index!]
            var multiEvent: ASAMultiEvent
            if !(preexistingEvent is ASAMultiEvent) {
                multiEvent = ASAMultiEvent(event: preexistingEvent)
            } else {
                multiEvent = preexistingEvent as! ASAMultiEvent
            }
            multiEvent.append(event: event)
            self[index!] = multiEvent
        }
    } // mutating func add(event: ASAEventCompatible)
    
    mutating func add(events: Array<ASAEventCompatible>) {
        for event in events {
            add(event: event)
        } // for event in events
    } // mutating func add(events: Array<ASAEventCompatible>)
} // extension Array where Element == ASAEventCompatible


// MARK:  -

extension ASAEventCompatible {
     func contains(now: Date) -> Bool {
        return self.startDate <= now && now < self.endDate
    } // func contains(now: Date) -> Bool

    func isAllDay(for clock: ASAClock, location: ASALocation) -> Bool {
        return self.isAllDay && clock.calendar.calendarCode == self.calendarCode && (location.timeZone.secondsFromGMT(for: self.startDate) == self.timeZone?.secondsFromGMT(for: self.startDate) || self.timeZone == nil)
    } // func isAllDay(for row: ASAClock) -> Bool
    
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
        
        return self.fileEmoji
    } // var emoji
    
    var duration: TimeInterval {
        if self.endDate == nil {
            return 0.0
        }
        
        return self.endDate.timeIntervalSince(self.startDate)
    } // var duration
    
    func isOnlyForRange(rangeStart: Date, rangeEnd: Date) -> Bool {
        return rangeStart <= self.startDate && (self.endDate ?? self.startDate) <= rangeEnd
    } // func isOnlyForRange(rangeStart: Date, rangeEnd: Date) -> Bool
} // extension ASAEventCompatible
