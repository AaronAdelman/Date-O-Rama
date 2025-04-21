//
//  ASAClockCellDateEventVisibility.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/10/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

enum ASAClockCellDateEventVisibility: Int, CaseIterable {
    case none           = 0
    case oneDay         = 1
    case oneWeekOrLess  = 14
    case oneMonthOrLess = 45
    case oneYearOrLess  = 400
    case all            = 1000000000

    var cutoff: TimeInterval {
        switch self {
        case .none:
            return 0.0
        case .oneDay:
            return 1.1 * Date.SECONDS_PER_DAY
        case .oneWeekOrLess:
            return 14.1 * Date.SECONDS_PER_DAY
        case .oneMonthOrLess:
            return 45.1 * Date.SECONDS_PER_DAY
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
            raw = "Showing ASAClockCellDateEventVisibility.none"
        case .oneDay:
            raw = "Showing ASAClockCellDateEventVisibility.oneDay"
        case .oneWeekOrLess:
            raw = "Showing ASAClockCellDateEventVisibility.oneWeekOrLess"
        case .oneMonthOrLess:
            raw = "Showing ASAClockCellDateEventVisibility.oneMonthOrLess"
        case .oneYearOrLess:
            raw = "Showing ASAClockCellDateEventVisibility.oneYearOrLess"
        case .all:
            raw = "Showing ASAClockCellDateEventVisibility.all"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var showingText
    
    var text: String {
        var raw: String
        switch self {
        case .none:
            raw = "ASAClockCellDateEventVisibility.none"
        case .oneDay:
            raw = "ASAClockCellDateEventVisibility.oneDay"
        case .oneWeekOrLess:
            raw = "ASAClockCellDateEventVisibility.oneWeekOrLess"
        case .oneMonthOrLess:
            raw = "ASAClockCellDateEventVisibility.oneMonthOrLess"
        case .oneYearOrLess:
            raw = "ASAClockCellDateEventVisibility.oneYearOrLess"
        case .all:
            raw = "ASAClockCellDateEventVisibility.all"
        } // switch self
        return NSLocalizedString(raw, comment: "")
    } // var text
    
    static let defaultValue = ASAClockCellDateEventVisibility.oneWeekOrLess
} // enum ASAClockCellDateEventVisibility
