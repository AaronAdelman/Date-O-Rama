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
} // struct ASAEvent

extension EKEvent:  ASAEventCompatible {
    var color: Color {
        get {
            let calendarColor = self.calendar.cgColor ?? CGColor(genericGrayGamma2_2Gray: 0.5, alpha: 1.0)
            return Color(UIColor(cgColor: calendarColor))
        } // get
    } // var color: Color
    
    
}
