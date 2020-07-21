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

extension EKEvent:  ASAEventCompatible {
    var isEKEvent: Bool {
        get {
            return true
        } // get
    } // var isEKEvent
    
    var color: Color {
        get {
            let calendarColor = self.calendar.cgColor ?? CGColor(genericGrayGamma2_2Gray: 0.5, alpha: 1.0)
            return Color(UIColor(cgColor: calendarColor))
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
