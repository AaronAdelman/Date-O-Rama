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
    var geoLocation: CLLocation? { get }
    var isReadOnly: Bool { get }
    
    var regionCodes:  Array<String>? { get }
    var excludeRegionCodes:  Array<String>? { get }

    var category: ASAEventCategory { get }
    var emoji: String? { get }
    var fileEmoji: String? { get }
    
    var type: ASADateSpecificationType { get }
} // protocol ASAEventCompatible


// MARK:  -

extension Array where Element == ASAEventCompatible {
    func trimmed(visibility: ASAClockCellEventVisibility, allDayEventVisibility: ASAClockCellAllDayEventVisibility, now: Date) -> Array<ASAEventCompatible> {
        var allDayTemp: Array<ASAEventCompatible> = []
        var nonAllDayTemp: Array<ASAEventCompatible> = []
        for event in self {
            if event.isAllDay {
                allDayTemp.append(event)
            } else {
                nonAllDayTemp.append(event)
            }
        }
        
        switch visibility {
        case .none:
            nonAllDayTemp = []
            
            //        case .allDay:
            //            return self.allDayOnly
            
        case .next:
            nonAllDayTemp = nonAllDayTemp.nextEvents(now: now)
            
        case .future:
            nonAllDayTemp = nonAllDayTemp.futureOnly(now: now)
            
        case .present:
            nonAllDayTemp = nonAllDayTemp.presentOnly(now: now)
            
        case .past:
            nonAllDayTemp = nonAllDayTemp.pastOnly(now: now)
            
        case .all:
            debugPrint(#file, #function, "Ignore this.")
            
            //        case .nonAllDay:
            //            return self.nonAllDayOnly
        case .nextAndPresent:
            nonAllDayTemp = nonAllDayTemp.nextAndPresentEvents(now: now)
        } // switch visibility
        
        switch allDayEventVisibility {
        case .none:
            allDayTemp = []
            
        case .all:
            debugPrint(#file, #function, "Ignore this.")
            
        default:
            let maximumDuration = allDayEventVisibility.cutoff
            allDayTemp = allDayTemp.filter {
                $0.duration <= maximumDuration
            }
        } // switch allDayEventVisibility
        
        return allDayTemp + nonAllDayTemp
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
} // extension Array where Element == ASAEventCompatible



// MARK:  -

extension ASAEventCompatible {
     func contains(now: Date) -> Bool {
        return self.startDate <= now && now < self.endDate
    } // func contains(now: Date) -> Bool

    func isAllDay(for row: ASAClock) -> Bool {
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
        if self.endDate == nil {
            return 0.0
        }
        
        return self.endDate.timeIntervalSince(self.startDate)
    } // var duration
    
    var isEKEvent:  Bool {
        return self is EKEvent
    } // var isEKEvent
} // extension ASAEventCompatible
