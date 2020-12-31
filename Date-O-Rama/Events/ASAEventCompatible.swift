//
//  ASAEventCompatible.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

protocol ASAEventCompatible {
    var eventIdentifier: String! { get }
    var title:  String! { get }
    var startDate:  Date! { get }
    var endDate: Date! { get }
    var isAllDay: Bool { get }
    var timeZone: TimeZone? { get }
    var color:  Color { get }
    var calendarTitleWithLocation:  String { get }
    var calendarTitleWithoutLocation:  String { get }
    var calendarCode:  ASACalendarCode { get }
    var isEKEvent:  Bool { get }
} // protocol ASAEventCompatible


// MARK:  -

extension Array where Element == ASAEventCompatible {
    var allDayOnly:  Array<ASAEventCompatible> {
        var selectedEvents:  Array<ASAEventCompatible> = []
        for event in self {
            if event.isAllDay {
                selectedEvents.append(event)
            }
        } // for event in self
        return selectedEvents
    } // var allDayOnly
} // extension Array where Element == ASAEventCompatible
