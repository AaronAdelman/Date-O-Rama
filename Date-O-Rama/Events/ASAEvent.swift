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

protocol ASAEventCompatible {
    var eventIdentifier: String! { get }
    var title:  String! { get }
    var startDate:  Date! { get }
    var endDate: Date! { get }
    var isAllDay: Bool { get }
    var timeZone: TimeZone? { get }
    var color:  Color { get }
    var calendarTitle:  String { get }
    var calendarCode:  ASACalendarCode { get }
    var isEKEvent:  Bool { get }
} // protocol ASAEventCompatible


// MARK: -

struct ASAEvent:  ASAEventCompatible {
    var eventIdentifier: String! = "\(UUID())"
    var title: String!
    var startDate: Date!
    var endDate: Date!
    var isAllDay: Bool
    var timeZone: TimeZone?
    var color:  Color
    var uuid = UUID()
    var calendarTitle: String
    var isEKEvent: Bool = false
    var calendarCode: ASACalendarCode
} // struct ASAEvent

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
        if lhs.calendarTitle != rhs.calendarTitle {
            return false
        }
        if lhs.calendarCode != rhs.calendarCode {
            return false
        }

        return true
    } // static func ==(lhs: ASAEvent, rhs: ASAEvent) -> Bool
} // extension ASAEvent:  Equatable


extension ASAEvent {
    func relevant(startDate: Date, endDate: Date) -> Bool {
        if self.startDate == self.endDate && self.startDate == startDate {
            return true
        }
        
        if self.endDate <= startDate {
            return false
        }
        
        if self.startDate >= endDate {
            return false
        }
        
        return true
    } // func relevant(startDate: Date, endDate: Date) -> Bool
} // extension ASAEvent


// MARK: -

extension EKEvent:  ASAEventCompatible {
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
    
    var calendarTitle:  String {
        get {
            return self.calendar.title
        } // get
    } // var calendarTitle
    
    var calendarCode: ASACalendarCode {
        get {
            return .Gregorian
        } // get
    } // var calendarCode
} // extension EKEvent:  ASAEventCompatible
