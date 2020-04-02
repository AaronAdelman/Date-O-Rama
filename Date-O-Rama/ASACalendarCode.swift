//
//  ASACalendarCode.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-02-03.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

// Calendar codes
enum ASACalendarCode:  String {
    case None                = "  "
    case Buddhist            = "BE"
    case Chinese             = "CH"
    case Coptic              = "CO"
    case EthiopicAmeteAlem   = "EA"
    case EthiopicAmeteMihret = "EM"
    case Gregorian           = "NS"
    case Hebrew              = "AM"
    case Indian              = "IN"
    case Islamic             = "AH"
    case IslamicCivil        = "IC"
    case IslamicTabular      = "IT"
    case IslamicUmmAlQura    = "IU"
    case ISO8601             = "IS"
    case Japanese            = "JA"
    case Persian             = "AP"
    case RepublicOfChina     = "RC"
} // enum ASACalendarCode:  String


// MARK: -

extension ASACalendarCode {
    func localizedName() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    } // func localizedName() -> String
} // extension ASACalendarCode

extension ASACalendarCode {
    func ordinaryAppleCalendar() -> Bool {
        switch self {
        case .Buddhist,
             .Chinese,
             .Coptic,
             .EthiopicAmeteAlem,
             .EthiopicAmeteMihret,
             .Gregorian,
             .Hebrew,
             .Indian,
             .Islamic,
             .IslamicCivil,
             .IslamicTabular,
             .IslamicUmmAlQura,
             .Japanese,
             .Persian,
             .RepublicOfChina:
            return true
        default:
            return false
        } // switch self
    } // func ordinaryAppleCalendar() -> Bool
    
    func usesDateFormatter() -> Bool {
        return self.ordinaryAppleCalendar()
    } // func usesDateFormatter() -> Bool
    
    func ISO8601AppleCalendar() -> Bool {
        switch self {
        case .ISO8601:
            return true
        default:
            return false
        }
    } // func ISOAppleCalendar() -> Bool
} // extension ASACalendarCode
