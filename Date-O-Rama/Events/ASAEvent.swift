//
//  ASAEvent.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-12.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit


struct ASAEvent:  ASASingleEvent {
    var eventIdentifier: String! = "\(UUID())"
    var title: String!
    var location: String?
    var startDate: Date!
    var endDate: Date!
    var startDateString: String?
    var endDateString: String?
    var secondaryStartDateString: String?
    var secondaryEndDateString: String?
    var isAllDay: Bool
    var timeZone: TimeZone?
    var url: URL?
    var hasNotes: Bool {
        return self.notes != nil
    }
    var notes: String?
    var color:  Color
    var colors: Array<Color> {
        return [self.color]
    }
    var uuid = UUID()
    var calendarTitleWithLocation:  String
    var calendarTitle: String
    
    var longCalendarTitle: String {
        return calendarTitle
    }
    
    var calendarCode: ASACalendarCode
    var locationData:  ASALocation
    
    var geoLocation: CLLocation? {
//        return self.locationData.location
        return nil
    } // var geoLocation: CLLocation?
    
    var status: EKEventStatus = .none
    
    var organizer: EKParticipant?   = nil
    var hasAttendees: Bool          = false
    var attendees: [EKParticipant]? = nil
    
    var hasAlarms: Bool    = false
    var alarms: [EKAlarm]? = nil
    
    var availability: EKEventAvailability = .notSupported
    
    var isReadOnly: Bool = true
    
    var recurrenceRules: [EKRecurrenceRule]?
    
    var hasRecurrenceRules: Bool {
        if self.recurrenceRules == nil {
            return false
        }
        
        return self.recurrenceRules!.count > 0
    }
    
    var regionCodes: Array<String>?
    var excludeRegionCodes: Array<String>?
    
    var emoji: String?
    var fileEmoji: String?
    
    var type: ASAEventSpecificationType
    
    var urls: Array<URL> {
        if url == nil {
            return []
        } else {
            return [url!]
        }
    } // var urls: Array<URL>

    var allNotes: Array<String> {
        if !hasNotes || notes == nil {
            return []
        } else {
            return [notes!]
        }
    } // var allNotes: Array<String>
} // struct ASAEvent


// MARK: -

extension ASAEvent:  Equatable {
    static func ==(lhs: ASAEvent, rhs: ASAEvent) -> Bool {
        if lhs.title != rhs.title {
            return false
        }
        if lhs.startDate != rhs.startDate {
            return false
        }
        if lhs.endDate != rhs.endDate {
            return false
        }
        if lhs.isAllDay != rhs.isAllDay {
            return false
        }
        if lhs.timeZone != rhs.timeZone {
            return false
        }
        if lhs.color != rhs.color {
            return false
        }
        if lhs.calendarTitleWithLocation != rhs.calendarTitleWithLocation {
            return false
        }
        if lhs.calendarCode != rhs.calendarCode {
            return false
        }

        return true
    } // static func ==(lhs: ASAEvent, rhs: ASAEvent) -> Bool
} // extension ASAEvent:  Equatable


// MARK: -

extension ASAEvent {
    func relevant(startDate: Date, endDate: Date) -> Bool {
        if self.startDate == nil {
            return false
        }
        
        if self.startDate == self.endDate && self.startDate == startDate {
            return true
        }
        
        if self.endDate != nil && self.endDate <= startDate {
            return false
        }
        
        if self.startDate >= endDate {
            return false
        }
        
        return true
    } // func relevant(startDate: Date, endDate: Date) -> Bool
} // extension ASAEvent
