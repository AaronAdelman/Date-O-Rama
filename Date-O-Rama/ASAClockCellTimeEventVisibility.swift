//
//  ASAClockCellTimeEventVisibility.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 22/04/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASAClockCellTimeEventVisibility:  String, CaseIterable {
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
            raw = "ASAClockCellTimeEventVisibility.none"
//        case .allDay:
//            raw = "ASAClockCellTimeEventVisibility.allDay"
        case .next:
            raw = "ASAClockCellTimeEventVisibility.next"
        case .future:
            raw = "ASAClockCellTimeEventVisibility.future"
        case .all:
            raw = "ASAClockCellTimeEventVisibility.all"
        case .present:
            raw = "ASAClockCellTimeEventVisibility.present"
        case .past:
            raw = "ASAClockCellTimeEventVisibility.past"
//        case .nonAllDay:
//            raw = "ASAClockCellTimeEventVisibility.nonAllDay"
        case .nextAndPresent:
            raw = "ASAClockCellTimeEventVisibility.nextAndPresent"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text
    
    var showingText:  String {
        var raw:  String = ""
        switch self {
        case .none:
            raw = "Showing ASAClockCellTimeEventVisibility.none"
//        case .allDay:
//            raw = "Showing ASAClockCellTimeEventVisibility.allDay"
        case .next:
            raw = "Showing ASAClockCellTimeEventVisibility.next"
        case .future:
            raw = "Showing ASAClockCellTimeEventVisibility.future"
        case .all:
            raw = "Showing ASAClockCellTimeEventVisibility.all"
        case .present:
            raw = "Showing ASAClockCellTimeEventVisibility.present"
        case .past:
            raw = "Showing ASAClockCellTimeEventVisibility.past"
//        case .nonAllDay:
//            raw = "Showing ASAClockCellTimeEventVisibility.nonAllDay"
        case .nextAndPresent:
            raw = "Showing ASAClockCellTimeEventVisibility.nextAndPresent"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } //
    
//    #if os(watchOS)
//    static var watchCases:  Array<ASAClockCellTimeEventVisibility> = [
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
    
    static let defaultValue = ASAClockCellTimeEventVisibility.nextAndPresent
} // enum ASAClockCellTimeEventVisibility
