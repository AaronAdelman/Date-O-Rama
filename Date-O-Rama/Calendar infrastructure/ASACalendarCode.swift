//
//  ASACalendarCode.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-02-03.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

// Calendar codes
// I would prefer to use a standard, but ISO has not released one as of this writing.
enum ASACalendarCode:  String, Codable {
    case none                = "  "
    
    case Buddhist              = "tha"
    case Chinese               = "chi"
    case Coptic                = "cop"
    case EthiopicAmeteAlem     = "EthiopicAmeteAlem"
    case EthiopicAmeteMihret   = "EthiopicAmeteMihret"
    case Gregorian             = "gre"
    case Gregorian_Old         = "Gregorian"
    case Hebrew                = "Hebrew"
    case Indian                = "ind"
    case Islamic               = "Islamic"
    case IslamicCivil          = "IslamicCivil"
    case IslamicTabular        = "IslamicTabular"
    case IslamicUmmAlQura      = "IslamicUmmAlQura"
    case Japanese              = "kok"
    case Persian               = "his"
    case RepublicOfChina       = "min"
    case JulianDay             = "jld"
    case ReducedJulianDay      = "rjd"
    case DublinJulianDay       = "djd"
    case ModifiedJulianDay     = "mjd"
    case TruncatedJulianDay    = "tjd"
    case CNESJulianDay         = "cjd"
    case CCSDSJulianDay        = "ccj"
    case LilianDate            = "lid"
    case RataDie               = "rad"
    case HebrewGRA             = "HebrewSolar"
    case IslamicSolar          = "IslamicSolar"
    case IslamicCivilSolar     = "IslamicCivilSolar"
    case IslamicTabularSolar   = "IslamicTabularSolar"
    case IslamicUmmAlQuraSolar = "IslamicUmmAlQuraSolar"
    case HebrewMA              = "HebrewSolarMA"
    case FrenchRepublican      = "fre"
    case FrenchRepublicanRomme = "fre-r"
    case Julian                = "jul"
    case MarsSolDate           = "mar"
    
    case allEarth              = "*"
    case allHebrew             = "heb*"
    case allHebrewSolarTime    = "heb-solar*"
    case allIslamic            = "hiq*"
    case allIslamicSolarTime   = "hiq-solar*"
    case allFrenchRepublican   = "fre*"
    case GregorianOrJulian     = "greOrJul"
    case allEthiopic           = "Ethiopic*"
    
    /// Gregorian and all calendar systems in which the days, months, and weeks are identical to Gregorian, e.g., Buddhist and Japanese
    case allGregorianMonthsWeeksDays = "gre*"
    
    case allSupportingTimeZones      = "tz*"
    case allSupportingEarthLocations = "xloc*"
} // enum ASACalendarCode:  String


extension ASACalendarCode {
    /// An “abstract” calendar code represents a group of calendars, not an individual calendar which can be manifested.
    var isAbstract: Bool {
        switch self {
        case .allEarth, .allHebrew, .allHebrewSolarTime, .allIslamic, .allIslamicSolarTime, .allGregorianMonthsWeeksDays, .allSupportingTimeZones, .allSupportingEarthLocations, .allEthiopic:
            return true
            
        default:
            return false
        }
    }
}


// MARK:  -

enum ASACalendarType {
    case solar
    case lunisolar
    case lunar
    case JulianDay
    
    case invalid
} // enum ASACalendarType


// MARK: -

extension ASACalendarCode {
    var localizedName:  String {
        return NSLocalizedString(self.rawValue, comment: "")
    } // var localizedName

    var isAppleCalendar:  Bool {
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
    } // var isAppleCalendar
    
    var isJulianDayCalendar:  Bool {
        switch self {
        case .JulianDay, .ReducedJulianDay, .ModifiedJulianDay, .TruncatedJulianDay, .DublinJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie, .MarsSolDate:
            return true
            
        default:
            return false
        } // switch self
    } // var isJulianDayCalendar
    
    var isSunsetTransitionCalendar:  Bool {
        switch self {
        case .HebrewGRA, .IslamicSolar, .IslamicTabularSolar, .IslamicCivilSolar, .IslamicUmmAlQuraSolar, .HebrewMA:
            return true
        default:
            return false
        } // switch self
    } // var isSunsetTransitionCalendar

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
    
    var isHebrewSolarTimeCalendar: Bool {
        get {
            switch self {
            case .HebrewMA, .HebrewGRA:
                return true

            default:
                return false
            } // switch self
        } // get
    } // var isHebrewSolarTimeCalendar
    
    var isIslamicCalendar: Bool {
        switch self {
        case .Islamic, .IslamicCivil, .IslamicSolar, .IslamicTabular, .IslamicUmmAlQura, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
            return true
            
        default:
            return false
        }
    }
    
    var isIslamicSolarTimeCalendar: Bool {
        switch self {
        case .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
            return true
            
        default:
            return false
        }
    }
    
    var is24HourDaysMidnightStartFixedCalendar: Bool {
        switch self {
        case .HebrewGRA, .IslamicSolar, .IslamicTabularSolar, .IslamicCivilSolar, .IslamicUmmAlQuraSolar, .HebrewMA, .MarsSolDate, .DublinJulianDay, .ReducedJulianDay, .JulianDay:
            return false

        default:
            return true
        }
    }
    
    var isGregorianMonthWeeksDaysCalendar: Bool {
        switch self {
        case .Gregorian, .Buddhist, .Japanese, .RepublicOfChina:
            return true
            
        default:
            return false
        } // switch self
    } // var isGregorianMonthWeeksDaysCalendar: Bool
    
    var isFrenchRepublicanCalendar: Bool {
        switch self {
        case .FrenchRepublican, .FrenchRepublicanRomme:
            return true
            
        default:
            return false
        } // switch self
    } // var isFrenchRepublicanCalendar: Bool

    var equivalentCalendarIdentifier:  Calendar.Identifier {
           var identifier:  Calendar.Identifier
           switch self {
           case ASACalendarCode.Buddhist:
               identifier = .buddhist
               
           case ASACalendarCode.Chinese:
               identifier = .chinese
               
           case ASACalendarCode.Coptic:
               identifier = .coptic
               
           case ASACalendarCode.EthiopicAmeteAlem:
               identifier = .ethiopicAmeteAlem
               
           case ASACalendarCode.EthiopicAmeteMihret:
               identifier = .ethiopicAmeteMihret
               
           case ASACalendarCode.Gregorian:
               identifier = .gregorian
               
           case ASACalendarCode.Hebrew, .HebrewGRA, .HebrewMA:
               identifier = .hebrew
               
           case ASACalendarCode.Indian:
               identifier = .indian
               
           case ASACalendarCode.Islamic, .IslamicSolar:
               identifier = .islamic
               
           case ASACalendarCode.IslamicCivil, .IslamicCivilSolar:
               identifier = .islamicCivil
               
           case ASACalendarCode.IslamicTabular, .IslamicTabularSolar:
               identifier = .islamicTabular
               
           case ASACalendarCode.IslamicUmmAlQura, .IslamicUmmAlQuraSolar:
               identifier = .islamicUmmAlQura
               
           case ASACalendarCode.Japanese:
               identifier = .japanese
               
           case ASACalendarCode.Persian:
               identifier = .persian
               
           case ASACalendarCode.RepublicOfChina:
               identifier = .republicOfChina
               
           default:
               identifier = .gregorian
           } // switch calendarCode
           
           return identifier
       } // var equivalentCalendarIdentifier
} // extension ASACalendarCode

extension ASACalendarCode {
    var type:  ASACalendarType {
        get {
            switch self {
            case .Buddhist, .Coptic, .EthiopicAmeteAlem, .EthiopicAmeteMihret, .Gregorian, .Indian,
                    .Japanese ,.Persian, .RepublicOfChina, .FrenchRepublican, .FrenchRepublicanRomme, .Julian:
                return .solar
                
            case .Chinese, .Hebrew, .HebrewGRA, .HebrewMA:
                return .lunisolar
                
            case .Islamic, .IslamicCivil, .IslamicTabular, .IslamicUmmAlQura, .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
                return .lunar
                
            case .JulianDay, .ReducedJulianDay, .DublinJulianDay, .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie, .MarsSolDate:
                return .JulianDay
                
            default:
                return .invalid
            } // switch self
        } // get
    } // var type
    
    static func allForLocationType(_ locationType: ASALocationType) -> Array<ASACalendarCode> {
        switch locationType {
        case .earthLocation:
            return [.Buddhist, .Coptic, .EthiopicAmeteAlem, .EthiopicAmeteMihret, .Gregorian, .Indian,
                    .Japanese ,.Persian, .RepublicOfChina, .FrenchRepublican, .FrenchRepublicanRomme, .Julian, .Chinese, .Hebrew, .HebrewGRA, .HebrewMA, .Islamic, .IslamicCivil, .IslamicTabular, .IslamicUmmAlQura, .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar]
        case .earthUniversal:
            return [.JulianDay, .ReducedJulianDay, .DublinJulianDay, .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie]
        case .marsUniversal:
            return [.MarsSolDate]
        } // switch locationType
    } // static func allForLocationType(_ locationType: ASALocationType) -> Array<ASACalendarCode>

    func matches(_ otherCalendarCode: ASACalendarCode) -> Bool {
        if self == .allHebrew && otherCalendarCode.isHebrewCalendar {
            return true
        }
        
        if self == .allHebrewSolarTime && otherCalendarCode.isHebrewSolarTimeCalendar {
            return true
        }
        
        if self == .allIslamic && otherCalendarCode.isIslamicCalendar {
            return true
        }

        if self == .allIslamicSolarTime && otherCalendarCode.isIslamicSolarTimeCalendar {
            return true
        }
        
        if self == .allFrenchRepublican && otherCalendarCode.isFrenchRepublicanCalendar {
            return true
        }
        
        if self == .allGregorianMonthsWeeksDays && otherCalendarCode.isGregorianMonthWeeksDaysCalendar {
            return true
        }
        
        if self == .allSupportingTimeZones && !otherCalendarCode.isJulianDayCalendar {
            return true
        }
        
        if self == .allSupportingEarthLocations && !otherCalendarCode.isJulianDayCalendar {
            return true
        }
        
        if self == .allEarth {
            return self != .MarsSolDate
            // TODO:  Needs to be modified when adding calendars for other planets, e.g., the Darian calendar for Mars.
        }
        
        if self == .GregorianOrJulian && (otherCalendarCode == .Gregorian || otherCalendarCode == .Julian) {
            return true
        }
        
        if self == .allEthiopic && (otherCalendarCode == .EthiopicAmeteAlem || otherCalendarCode == .EthiopicAmeteMihret) {
            return true
        }

        return self == otherCalendarCode
    } // func matches(_ otherCalendarCode: ASACalendarCode) -> Bool
    
    var locationType: ASALocationType {
        switch self {
        case .JulianDay, .ReducedJulianDay, .DublinJulianDay, .ModifiedJulianDay, .TruncatedJulianDay, .CNESJulianDay, .CCSDSJulianDay, .LilianDate, .RataDie:
            return .earthUniversal
            
        case .MarsSolDate:
            return .marsUniversal
            
        default:
            return .earthLocation
        }
    } // var locationType
    
    func genericBuiltInEventCalendarNames(regionCode: String) -> Array<String> {
        switch self {
        case .Buddhist:
            return [regionCode + " (Buddhist)"]

        case .Chinese:
            return [regionCode + " (Chinese)"]
            
        case .Coptic:
            return [regionCode + " (Coptic)"]
            
        case .EthiopicAmeteAlem, .EthiopicAmeteMihret:
            return [regionCode + " (Ethiopic)"]
            
        case .Gregorian:
            return [regionCode]

        case .Indian:
            return [regionCode + " (Indian)"]
            
        case .Islamic, .IslamicCivil, .IslamicTabular, .IslamicUmmAlQura, .IslamicSolar, .IslamicCivilSolar, .IslamicTabularSolar, .IslamicUmmAlQuraSolar:
            return [regionCode + " (Muslim)", "Islam (general)"]
            
        case .Japanese:
            return [regionCode + " (Japanese)"]
            
        case .Persian:
            return [regionCode + " (Persian)"]
            
        case .RepublicOfChina:
            return [regionCode + " (ROC)"]

        case .HebrewGRA, .HebrewMA, .Hebrew:
            var result: [String] = [regionCode + " (Hebrew)", "Judaism"]
            if regionCode != REGION_CODE_Israel {
                result.append("IL (Hebrew)")
            }
            return result

        case .FrenchRepublican, .FrenchRepublicanRomme:
            return ["Rural"]
            
        case .Julian:
            return [regionCode + " (Julian)"]
            
        default:
            return []
        } // switch self
    } // func genericBuiltInEventCalendarNames(regionCode: String) -> Array<String>
} // extension ASACalendarCode
