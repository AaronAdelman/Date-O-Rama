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

extension EKEvent:  ASAEventCompatible {
    var calendarTitleWithoutLocation: String {
        return self.calendar.title
    }

    var isEKEvent: Bool {
        get {
            return true
        } // get
    } // var isEKEvent

    var color: Color {
        get {
            let calendarColor = self.calendar.cgColor
            if calendarColor == nil {
                return Color("genericCalendar")
            }

            return Color(UIColor(cgColor: calendarColor!))
        } // get
    } // var color

    var calendarTitleWithLocation:  String {
        get {
            return self.calendar.title
        } // get
    } // var calendarTitleWithLocation

    var calendarCode: ASACalendarCode {
        get {
            return .Gregorian
        } // get
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
    
    var category: ASAEventCategory {
        if self.birthdayContactIdentifier != nil {
            return .birthday
        } else {
            return .generic
        }
    } // var category
} // extension EKEvent:  ASAEventCompatible
