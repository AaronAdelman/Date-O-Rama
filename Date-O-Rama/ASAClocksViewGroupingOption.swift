//
//  ASAClocksViewGroupingOption.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASAClocksViewGroupingOption:  String, CaseIterable {
    case byFormattedDate
    case byCalendar
    case byPlaceName
    case byCountry
    case westToEast
    case eastToWest
    case northToSouth
    case southToNorth
    case byTimeZoneWestToEast
    case byTimeZoneEastToWest

    func text() -> String {
        var raw:  String

        switch self {
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

        case .byCountry:
            raw = "By Country or Region"
        } // switch self

        return NSLocalizedString(raw, comment: "")
    } // func text() -> String

    static var primaryOptions:  Array<ASAClocksViewGroupingOption> = [
        .byCalendar,
        .byFormattedDate,
        .byPlaceName,
        .byCountry,
        .byTimeZoneWestToEast,
        .byTimeZoneEastToWest
    ]

    var compatibleOptions:  Array<ASAClocksViewGroupingOption> {
        switch self {
        case .byFormattedDate:
            return [.byCalendar, .byPlaceName, .byCountry, .byTimeZoneWestToEast, .byTimeZoneEastToWest, .eastToWest, .westToEast, .northToSouth, .southToNorth]

        case .byCalendar:
            return [.byFormattedDate, .byPlaceName, .byCountry, .byTimeZoneWestToEast, .byTimeZoneEastToWest, .eastToWest, .westToEast, .northToSouth, .southToNorth]

        case .byPlaceName:
            return [.byCalendar, .byFormattedDate, .eastToWest, .westToEast, .northToSouth, .southToNorth]

        case .byCountry:
            return [.byCalendar, .byFormattedDate, .byPlaceName, .byTimeZoneWestToEast, .byTimeZoneEastToWest, .eastToWest, .westToEast, .northToSouth, .southToNorth]

        case .byTimeZoneWestToEast, .byTimeZoneEastToWest:
            return [.byCalendar, .byFormattedDate, .byPlaceName, .byCountry, .eastToWest, .westToEast, .northToSouth, .southToNorth]

        default:
            return []
        } // switch self
    } // var compatibleOptions

    var defaultCompatibleOption:  ASAClocksViewGroupingOption {
        switch self {
        case .byFormattedDate:
            return .byPlaceName

        case .byCalendar:
            return .byPlaceName

        case .byPlaceName:
            return .byFormattedDate

        case .byCountry:
            return .byPlaceName

        case .byTimeZoneWestToEast:
            return .byPlaceName

        case .byTimeZoneEastToWest:
            return .byPlaceName

        default:
            return .byPlaceName
        } // switch self
    } //var defaultCompatibleOption
} // enum ASAClocksViewGroupingOption
