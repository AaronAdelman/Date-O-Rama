//
//  ASAMajorDateFormat.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASAMajorFormat:  String {
    case none          = "none"
    case short         = "short"
    case medium        = "medium"
    case long          = "long"
    case full          = "full"
    case localizedLDML = "loc"
//    case rawLDML       = "raw"
} // enum ASAMajorDateFormat

extension ASAMajorFormat {
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
//        case .rawLDML:
//            unlocalizedString = "ITEM_Raw_LDML"
        case .none:
            "ITEM_None"
        } // switch self
        return NSLocalizedString(unlocalizedString, comment: "")
    } // func localizedItemName() -> String
} // extension ASAMajorDateFormat
