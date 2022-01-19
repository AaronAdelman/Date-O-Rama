//
//  ASAClockCellEventVisibility.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/04/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASAClockCellEventVisibility:  String, CaseIterable {
    case none
//    case allDay
//    case nonAllDay
    case next
    case future
    case present
    case past
    case all
    case nextAndPresent
    
    var text:  String {
        var raw:  String = ""
        switch self {
        case .none:
            raw = "ASAClockCellEventVisibility.none"
//        case .allDay:
//            raw = "ASAClockCellEventVisibility.allDay"
        case .next:
            raw = "ASAClockCellEventVisibility.next"
        case .future:
            raw = "ASAClockCellEventVisibility.future"
        case .all:
            raw = "ASAClockCellEventVisibility.all"
        case .present:
            raw = "ASAClockCellEventVisibility.present"
        case .past:
            raw = "ASAClockCellEventVisibility.past"
//        case .nonAllDay:
//            raw = "ASAClockCellEventVisibility.nonAllDay"
        case .nextAndPresent:
            raw = "ASAClockCellEventVisibility.nextAndPresent"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text
    
    var showingText:  String {
        var raw:  String = ""
        switch self {
        case .none:
            raw = "Showing ASAClockCellEventVisibility.none"
//        case .allDay:
//            raw = "Showing ASAClockCellEventVisibility.allDay"
        case .next:
            raw = "Showing ASAClockCellEventVisibility.next"
        case .future:
            raw = "Showing ASAClockCellEventVisibility.future"
        case .all:
            raw = "Showing ASAClockCellEventVisibility.all"
        case .present:
            raw = "Showing ASAClockCellEventVisibility.present"
        case .past:
            raw = "Showing ASAClockCellEventVisibility.past"
//        case .nonAllDay:
//            raw = "Showing ASAClockCellEventVisibility.nonAllDay"
        case .nextAndPresent:
            raw = "Showing ASAClockCellEventVisibility.nextAndPresent"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } //
    
//    #if os(watchOS)
//    static var watchCases:  Array<ASAClockCellEventVisibility> = [
////        allDay, nonAllDay,
//        next, future, present, past, all]
//    #endif
    
    var symbolName: String {
        switch self {
        case .none:
            return "rectangle.dashed"
//        case .allDay:
//            return "calendar"
        case .next:
            return "arrowtriangle.down.fill"
        case .future:
            return "arrow.down"
        case .all:
            return "arrow.up.and.down"
        case .present:
            return "app"
        case .past:
            return "arrow.up"
//        case .nonAllDay:
//            return "rectangle"
        case .nextAndPresent:
            return "arrowtriangle.down.square"
        } // switch self
    } // var symbolName
    
    static var defaultValue = ASAClockCellEventVisibility.nextAndPresent
} // enum ASAClockCellEventVisibility
