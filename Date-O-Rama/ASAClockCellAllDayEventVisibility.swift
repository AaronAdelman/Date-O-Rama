//
//  ASAClockCellAllDayEventVisibility.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/10/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASAClockCellAllDayEventVisibility: Int, CaseIterable {
    case none           = 0
    case oneDay         = 1
    case oneWeekOrLess  = 7
    case oneMonthOrLess = 31
    case oneYearOrLess  = 400
    case all            = 1000000000

    var cutoff: TimeInterval {
        switch self {
        case .none:
            return 0.0
        case .oneDay:
            return 1.1 * Date.SECONDS_PER_DAY
        case .oneWeekOrLess:
            return 7.1 * Date.SECONDS_PER_DAY
        case .oneMonthOrLess:
            return 31.1 * Date.SECONDS_PER_DAY
        case .oneYearOrLess:
            return 400 * Date.SECONDS_PER_DAY
        case .all:
            return Double(Int.max) * Date.SECONDS_PER_DAY
        } // switch self
    } // var cutoff
    
    var showingText: String {
        var raw: String
        switch self {
        case .none:
            raw = "Showing ASAClockCellAllDayEventVisibility.none"
        case .oneDay:
            raw = "Showing ASAClockCellAllDayEventVisibility.oneDay"
        case .oneWeekOrLess:
            raw = "Showing ASAClockCellAllDayEventVisibility.oneWeekOrLess"
        case .oneMonthOrLess:
            raw = "Showing ASAClockCellAllDayEventVisibility.oneMonthOrLess"
        case .oneYearOrLess:
            raw = "Showing ASAClockCellAllDayEventVisibility.oneYearOrLess"
        case .all:
            raw = "Showing ASAClockCellAllDayEventVisibility.all"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text
    
    static var defaultValue = ASAClockCellAllDayEventVisibility.oneWeekOrLess
} // enum ASAClockCellAllDayEventVisibility
