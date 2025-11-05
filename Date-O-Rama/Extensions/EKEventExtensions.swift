//
//  EKEventExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import EventKit
import Foundation
import SwiftUI

extension EKEvent:  ASASingleEvent {
    var calendarTitle: String {
        return self.calendar.title
    }
    
    var longCalendarTitle: String {
        return calendarTitle
    }

    var color: Color {
        let calendarColor = self.calendar.cgColor
        if calendarColor == nil {
            return Color("genericCalendar")
        }
        
        return Color(UIColor(cgColor: calendarColor!))
    } // var color
    
    var colors: Array<Color> {
        return [self.color]
    }

    var calendarTitleWithLocation:  String {
        return self.calendar.title
    } // var calendarTitleWithLocation

    var calendarCode: ASACalendarCode {
        return .gregorian
    } // var calendarCode
    
    var geoLocation: CLLocation? {
        return self.structuredLocation?.geoLocation
    } // var geoLocation: CLLocation?

    // Based on https://stackoverflow.com/questions/4475120/iphone-how-to-detect-if-an-ekevent-instance-can-be-modified
    var isReadOnly: Bool {
        if !self.calendar.allowsContentModifications {
            return true
        }
        
        if self.organizer != nil {
            if !self.organizer!.isCurrentUser {
                return true
            }
        }
        
        return false
    } // var isReadOnly
    
    var regionCodes: Array<String>? {
        return nil
    } // var regionCodes
    
    var excludeRegionCodes: Array<String>? {
        return nil
    } // var excludeRegionCodes
        
    var emoji: String? {
        if self.birthdayContactIdentifier != nil {
            let templatesFile = ASAEventSpecification.templateEventsFile
            if templatesFile != nil {
                let birthdayTemplate = templatesFile!.eventSpecifications.first(where: {$0.template == "*BDay*"})
                if birthdayTemplate != nil {
                    return birthdayTemplate?.emoji
                }
            }
        }
        
        return nil
    }
    
    var fileEmoji: String? {
        return nil
    }
    
    var type: ASAEventSpecificationType {
        if self.isAllDay {
            if self.endDate.timeIntervalSince(self.startDate) <= 24 * 60 * 60 {
                return .oneDay
            }
            
            return .multiDay
        } else {
            return .point
        }
    }
    
    var startDateString: String? {
        return nil
    }
    
    var endDateString: String? {
        return nil
    }
    
    var secondaryStartDateString: String? {
        return nil
    }
    
    var secondaryEndDateString: String? {
        return nil
    }
    
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
    
    var numberOfSubevents: Int {
        return 1
    }
} // extension EKEvent:  ASAEventCompatible
