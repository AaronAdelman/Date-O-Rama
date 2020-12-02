//
//  ASAClocksViewGroupingOption.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASAClocksViewGroupingOption:  String, CaseIterable {
//    case plain
    case byFormattedDate
    case byCalendar
    case byPlaceName
    case westToEast
    case eastToWest
    case northToSouth
    case southToNorth
    case byTimeZoneWestToEast
    case byTimeZoneEastToWest

    func text() -> String {
        var raw:  String

        switch self {
//        case .plain:
//            raw = "Plain"

        case .byFormattedDate:
            raw = "By Formatted Date"

        case .byCalendar:
            raw = "By Calendar"

        case .byPlaceName:
            raw = "By Place Name"

        case .westToEast:
            raw = "West to East"

        case .eastToWest:
            raw = "East to West"

        case .southToNorth:
            raw = "South to North"

        case .northToSouth:
            raw = "North to South"

        case .byTimeZoneWestToEast:
            raw = "By Time Zone, West to East"

        case .byTimeZoneEastToWest:
            raw = "By Time Zone, East to West"

        } // switch self

        return NSLocalizedString(raw, comment: "")
    } // func text() -> String

    static var allOptions:  Array<ASAClocksViewGroupingOption> = [
        .byCalendar,
        .byFormattedDate,
        .byPlaceName,
        .byTimeZoneWestToEast,
        .byTimeZoneEastToWest,
        .eastToWest,
        .westToEast,
        .northToSouth,
        .southToNorth
    ]
} // enum ASAClocksViewGroupingOption
