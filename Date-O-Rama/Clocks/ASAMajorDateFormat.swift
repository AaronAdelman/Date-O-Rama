//
//  ASAMajorDateFormat.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASAMajorDateFormat:  String {
    case none                             = "none"
    case short                            = "short"
    case medium                           = "medium"
    case long                             = "long"
    case full                             = "full"
//    case localizedLDML                    = "loc"
    //    case rawLDML                    = "raw"
    case ISO8601YearMonthDay              = "ISO8601YearMonthDay"
    case ISO8601YearWeekDay               = "ISO8601YearWeekDay"
    case ISO8601YearDay                   = "ISO8601YearDay"
    case shortWithWeekday                 = "shortWithWeekday"
    case mediumWithWeekday                = "mediumWithWeekday"
    case abbreviatedWeekday               = "abbreviatedWeekday"
    case dayOfMonth                       = "dayOfMonth"
    case abbreviatedWeekdayWithDayOfMonth = "abbreviatedWeekdayWithDayOfMonth"
    case shortWithWeekdayWithoutYear      = "shortWithWeekdayWithoutYear"
    case mediumWithWeekdayWithoutYear     = "mediumWithWeekdayWithoutYear"
    case fullWithoutYear                  = "fullWithoutYear"

} // enum ASAMajorDateFormat

extension ASAMajorDateFormat {
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
//        case .localizedLDML:
//            unlocalizedString = "ITEM_Components"
//        case .rawLDML:
//            unlocalizedString = "ITEM_Raw_LDML"
        case .none:
            unlocalizedString = "ITEM_None"
        case .ISO8601YearMonthDay:
            unlocalizedString = "ITEM_ISO8601YearMonthDay"
        case .ISO8601YearWeekDay:
            unlocalizedString = "ITEM_ISO8601YearWeekDay"
        case .ISO8601YearDay:
            unlocalizedString = "ITEM_ISO8601YearDay"
        case .shortWithWeekday:
            unlocalizedString = "ITEM_ShortWithWeekday"
        case .mediumWithWeekday:
            unlocalizedString = "ITEM_MediumWithWeekday"
        case .abbreviatedWeekday:
            unlocalizedString = "ITEM_AbbreviatedWeekday"
        case .dayOfMonth:
            unlocalizedString = "ITEM_DayOfMonth"
        case .abbreviatedWeekdayWithDayOfMonth:
            unlocalizedString = "ITEM_AbbreviatedWeekdayWithDayOfMonth"
        case .shortWithWeekdayWithoutYear:
            unlocalizedString = "ITEM_ShortWithWeekdayWithoutYear"
        case .mediumWithWeekdayWithoutYear:
            unlocalizedString = "ITEM_MediumWithWeekdayWithoutYear"
        case .fullWithoutYear:
            unlocalizedString = "ITEM_FullWithoutYear"
        } // switch self
        return NSLocalizedString(unlocalizedString, comment: "")
    } // func localizedItemName() -> String
} // extension ASAMajorDateFormat

extension ASAMajorDateFormat {
    var shortened:  ASAMajorDateFormat {
        get {
            switch self {
            case .long, .full, .medium:
                return .short
                
            default:
                return self
            } // switch self
        } // get
    } // var shortened

    var watchShortened:  ASAMajorDateFormat {
        get {
            switch self {
            case .full, .mediumWithWeekday:
                return .shortWithWeekday

            case .long, .medium:
                return .short

            default:
                return self
            } // switch self
        } // get
    } // var watchShortened
} // extension ASAMajorDateFormat
