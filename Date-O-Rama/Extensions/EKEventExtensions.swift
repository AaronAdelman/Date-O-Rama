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
