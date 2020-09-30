//
//  ASAMajorTimeFormat.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-07.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASAMajorTimeFormat:  String {
    case none                         = "none"
    case short                        = "short"
    case medium                       = "medium"
    case long                         = "long"
    case full                         = "full"
    case localizedLDML                = "loc"
    case decimalTwelveHour            = "decimalTwelveHour" // 12 Night|Day
//    case JewishCalendricalCalculation = "JewishCalendricalCalculation" // 12:1080:76 Night|Day
    case decimal                      = "decimal" // 10:100:100
    case hexadecimal                  = "hexadecimal" // 16:256:16
} // enum ASAMajorTimeFormat

extension ASAMajorTimeFormat {
    func localizedItemName() -> String {
        var unlocalizedString = ""
        switch self {
        case .short:
            unlocalizedString = "ITEM_Short"
        case .medium:
            unlocalizedString = "ITEM_Medium"
        case .long:
            unlocalizedString = "ITEM_Long"
        case .full:
            unlocalizedString = "ITEM_Full"
        case .localizedLDML:
            unlocalizedString = "ITEM_Components"
        case .none:
            unlocalizedString = "ITEM_None"
        case .decimalTwelveHour:
            unlocalizedString = "ITEM_decimalTwelveHour"
//        case .JewishCalendricalCalculation:
//            unlocalizedString = "ITEM_JewishCalendricalCalculation"
        case .decimal:
            unlocalizedString = "ITEM_decimal"
        case .hexadecimal:
            unlocalizedString = "ITEM_hexadecimal"
        } // switch self
        return NSLocalizedString(unlocalizedString, comment: "")
    } // func localizedItemName() -> String
} // extension ASAMajorTimeFormat

extension ASAMajorTimeFormat {
    var shortened:  ASAMajorTimeFormat {
        get {
            switch self {
            case .long, .full:
                return .medium
                
            default:
                return self
            } // switch self
        } // get
    } // var shortened
} // extension ASAMajorTimeFormat
