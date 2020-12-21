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
enum ASACalendarCode:  String, Codable {
//    case None                = "  "
    case Buddhist              = "Buddhist"
    case Chinese               = "Chinese"
    case Coptic                = "Coptic"
    case EthiopicAmeteAlem     = "EthiopicAmeteAlem"
    case EthiopicAmeteMihret   = "EthiopicAmeteMihret"
    case Gregorian             = "Gregorian"
    case Hebrew                = "Hebrew"
    case Indian                = "Indian"
    case Islamic               = "Islamic"
    case IslamicCivil          = "IslamicCivil"
    case IslamicTabular        = "IslamicTabular"
    case IslamicUmmAlQura      = "IslamicUmmAlQura"
    case ISO8601               = "ISO8601"
    case Japanese              = "Japanese"
    case Persian               = "Persian"
    case RepublicOfChina       = "RepublicOfChina"
    case JulianDay             = "JulianDay"
    case ReducedJulianDay      = "ReducedJulianDay"
    case DublinJulianDay       = "DublinJulianDay"
    case ModifiedJulianDay     = "ModifiedJulianDay"
    case TruncatedJulianDay    = "TruncatedJulianDay"
    case CNESJulianDay         = "CNESJulianDay"
    case CCSDSJulianDay        = "CCSDSJulianDay"
    case LilianDate            = "LilianDate"
    case RataDie               = "RataDie"
    case HebrewGRA             = "HebrewSolar"
    case IslamicSolar          = "IslamicSolar"
    case IslamicCivilSolar     = "IslamicCivilSolar"
    case IslamicTabularSolar   = "IslamicTabularSolar"
    case IslamicUmmAlQuraSolar = "IslamicUmmAlQuraSolar"
    case HebrewMA              = "HebrewSolarMA"
} // enum ASACalendarCode:  String

enum ASACalendarType {
    case solar
    case lunisolar
    case lunar
    case JulianDay
} // enum ASACalendarType


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
    
    func isSunsetTransitionCalendar() -> Bool {
        switch self {
        case .HebrewGRA, .IslamicSolar, .IslamicTabularSolar, .IslamicCivilSolar, .IslamicUmmAlQuraSolar, .HebrewMA:
            return true
        default:
            return false
        } // switch self
    } // func isSolarCalendar() -> Bool

    var isHebrewCalendar: Bool {
        get {
            switch self {
            case .Hebrew, .HebrewMA, .HebrewGRA:
                return true

            default:
                return false
            } // switch self
        } // get
    } // var isHebrewCalendar
} // extension ASACalendarCode

extension ASACalendarCode {
    func equivalentCalendarIdentifier() -> Calendar.Identifier {
           var title:  Calendar.Identifier
           switch self {
           case ASACalendarCode.Buddhist:
               title = .buddhist
               
           case ASACalendarCode.Chinese:
               title = .chinese
               
           case ASACalendarCode.Coptic:
               title = .coptic
               
           case ASACalendarCode.EthiopicAmeteAlem:
               title = .ethiopicAmeteAlem
               
           case ASACalendarCode.EthiopicAmeteMihret:
               title = .ethiopicAmeteMihret
               
           case ASACalendarCode.Gregorian:
               title = .gregorian
               
           case ASACalendarCode.Hebrew, .HebrewGRA, .HebrewMA:
               title = .hebrew
               
           case ASACalendarCode.Indian:
               title = .indian
               
           case ASACalendarCode.Islamic, .IslamicSolar:
               title = .islamic
               
           case ASACalendarCode.IslamicCivil, .IslamicCivilSolar:
               title = .islamicCivil
               
           case ASACalendarCode.IslamicTabular, .IslamicTabularSolar:
               title = .islamicTabular
               
           case ASACalendarCode.IslamicUmmAlQura, .IslamicUmmAlQuraSolar:
               title = .islamicUmmAlQura
               
           case ASACalendarCode.ISO8601:
               title = .gregorian
               
           case ASACalendarCode.Japanese:
               title = .japanese
               
           case ASACalendarCode.Persian:
               title = .persian
               
           case ASACalendarCode.RepublicOfChina:
               title = .republicOfChina
               
           default:
               title = .gregorian
           } // switch calendarCode
           
           return title
       } // func title() -> Calendar.Identifier
} // extension ASACalendarCode

extension ASACalendarCode {
    var type:  ASACalendarType {
        get {
            switch self {
            case .Buddhist, .Coptic, .EthiopicAmeteAlem, .EthiopicAmeteMihret, .Gregorian, .Indian, .ISO8601, .Japanese ,.Persian, .RepublicOfChina:
                return .solar
                
            case .Chinese, .Hebrew, .HebrewGRA, .HebrewMA:
                return .lunisolar
                
            case .Islamic, .IslamicCivil, .IslamicTabular, .IslamicUmmAlQura, .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
                return .lunar
                
            case .JulianDay, .ReducedJulianDay, .DublinJulianDay, .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
                return .JulianDay
            } // switch self
        } // get
    } // var type
} // extension ASACalendarCode
