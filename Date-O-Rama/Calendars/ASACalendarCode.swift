//
//  ASACalendarCode.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-02-03.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

// Calendar codes
// I would prefer to use a standard, but ISO has not released one as of this writing.
enum ASACalendarCode:  String {
//    case None                = "  "
    case Buddhist            = "Buddhist"
    case Chinese             = "Chinese"
    case Coptic              = "Coptic"
    case EthiopicAmeteAlem   = "EthiopicAmeteAlem"
    case EthiopicAmeteMihret = "EthiopicAmeteMihret"
    case Gregorian           = "Gregorian"
    case Hebrew              = "Hebrew"
    case Indian              = "Indian"
    case Islamic             = "Islamic"
    case IslamicCivil        = "IslamicCivil"
    case IslamicTabular      = "IslamicTabular"
    case IslamicUmmAlQura    = "IslamicUmmAlQura"
    case ISO8601             = "ISO8601"
    case Japanese            = "Japanese"
    case Persian             = "Persian"
    case RepublicOfChina     = "RepublicOfChina"
    case JulianDay           = "JulianDay"
    case ReducedJulianDay    = "ReducedJulianDay"
    case DublinJulianDay     = "DublinJulianDay"
    case ModifiedJulianDay   = "ModifiedJulianDay"
    case TruncatedJulianDay  = "TruncatedJulianDay"
    case CNESJulianDay       = "CNESJulianDay"
    case CCSDSJulianDay      = "CCSDSJulianDay"
    case LilianDate          = "LilianDate"
    case RataDie            = "RataDie"


} // enum ASACalendarCode:  String


// MARK: -

extension ASACalendarCode {
    func localizedName() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    } // func localizedName() -> String
} // extension ASACalendarCode

extension ASACalendarCode {
    func isAppleCalendar() -> Bool {
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
    } // func isAppleCalendar() -> Bool
        
    func isISO8601Calendar() -> Bool {
        switch self {
        case .ISO8601:
            return true
        default:
            return false
        }
    } // func isISO8601Calendar() -> Bool
    
    func isJulianDayCalendar() -> Bool {
        switch self {
        case .JulianDay, .ReducedJulianDay, .ModifiedJulianDay, .TruncatedJulianDay, .DublinJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
            return true
        default:
            return false
        }
    }
} // extension ASACalendarCode

extension ASACalendarCode {
    func equivalentCalendarIdentifier() -> Calendar.Identifier {
           var calendarIdentifier:  Calendar.Identifier
           switch self {
           case ASACalendarCode.Buddhist:
               calendarIdentifier = .buddhist
               
           case ASACalendarCode.Chinese:
               calendarIdentifier = .chinese
               
           case ASACalendarCode.Coptic:
               calendarIdentifier = .coptic
               
           case ASACalendarCode.EthiopicAmeteAlem:
               calendarIdentifier = .ethiopicAmeteAlem
               
           case ASACalendarCode.EthiopicAmeteMihret:
               calendarIdentifier = .ethiopicAmeteMihret
               
           case ASACalendarCode.Gregorian:
               calendarIdentifier = .gregorian
               
           case ASACalendarCode.Hebrew:
               calendarIdentifier = .hebrew
               
           case ASACalendarCode.Indian:
               calendarIdentifier = .indian
               
           case ASACalendarCode.Islamic:
               calendarIdentifier = .islamic
               
           case ASACalendarCode.IslamicCivil:
               calendarIdentifier = .islamicCivil
               
           case ASACalendarCode.IslamicTabular:
               calendarIdentifier = .islamicTabular
               
           case ASACalendarCode.IslamicUmmAlQura:
               calendarIdentifier = .islamicUmmAlQura
               
           case ASACalendarCode.ISO8601:
               calendarIdentifier = .gregorian
               
           case ASACalendarCode.Japanese:
               calendarIdentifier = .japanese
               
           case ASACalendarCode.Persian:
               calendarIdentifier = .persian
               
           case ASACalendarCode.RepublicOfChina:
               calendarIdentifier = .republicOfChina
               
           default:
               calendarIdentifier = .gregorian
           } // switch calendarCode
           
           return calendarIdentifier
       } // func calendarIdentifier() -> Calendar.Identifier
} // extension ASACalendarCode
