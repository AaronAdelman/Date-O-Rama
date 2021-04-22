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
    case allDay
    case next
    case future
    case all
    
    #if os(watchOS)
    static var watchCases:  Array<ASAClockCellEventVisibility> = [allDay, next, future, all]
    
    var text:  String {
        var raw:  String = ""
        switch self {
        case .none:
            raw = "ASAClockCellEventVisibility.none"
        case .allDay:
            raw = "ASAClockCellEventVisibility.allDay"
        case .next:
            raw = "ASAClockCellEventVisibility.next"
        case .future:
            raw = "ASAClockCellEventVisibility.future"
        case .all:
            raw = "ASAClockCellEventVisibility.all"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text
    #else
    var emoji:  String {
        switch self {
        case .none:
            return "0️⃣"
            
        case .allDay:
            return "📅"
            
        case .next:
            return "🔽"
            
        case .future:
            return "⬇️"
            
        case .all:
            return "↕️"
        } // switch self
    } // var emoji
    #endif
} // enum ASAClockCellEventVisibility
