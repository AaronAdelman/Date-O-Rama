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
// Many codes come from https://github.com/CalConnect/cc-calendar-systems
enum ASACalendarCode: String, Codable {
    case none                      = "  "
    
    case buddhist                  = "tha"
    case chinese                   = "chi"
    case coptic                    = "cop"
    case ethiopicAmeteAlem         = "EthiopicAmeteAlem"
    case ethiopicAmeteMihret       = "EthiopicAmeteMihret"
    case gregorian                 = "gre"
    case hebrew                    = "Hebrew"
    case indian                    = "ind"
    case islamic                   = "Islamic"
    case islamicCivil              = "IslamicCivil"
    case islamicTabular            = "IslamicTabular"
    case islamicUmmAlQura          = "IslamicUmmAlQura"
    case japanese                  = "kok"
    case persian                   = "his"
    case republicOfChina           = "min"
    case julianDay                 = "jld"
    case reducedJulianDay          = "rjd"
    case dublinJulianDay           = "djd"
    case modifiedJulianDay         = "mjd"
    case truncatedJulianDay        = "tjd"
    case cnesJulianDay             = "cjd"
    case ccsdsJulianDay            = "ccj"
    case lilianDate                = "lid"
    case rataDie                   = "rad"
    case hebrewGRA                 = "HebrewSolar"
    case islamicSolarTime          = "IslamicSolar"
    case islamicCivilSolarTime     = "IslamicCivilSolar"
    case islamicTabularSolarTime   = "IslamicTabularSolar"
    case islamicUmmAlQuraSolarTime = "IslamicUmmAlQuraSolar"
    case hebrewMA                  = "HebrewSolarMA"
    case frenchRepublican          = "fre"
    case julian                    = "jul"
    case marsSolDate               = "mar"
    case bangla                    = "bangla"
    case dangi                     = "dangi"
    case gujarati                  = "gujarati"
    case kannada                   = "kannada"
    case malayalam                 = "malayalam"
    case marathi                   = "marathi"
    case odia                      = "odia"
    case tamil                     = "tamil"
    case telugu                    = "telugu"
    case vietnamese                = "vietnamese"
    case vikram                    = "vikram"
    case banglaSolarTime           = "bangla-s"
    case dangiSolarTime            = "dangi-s"
    case gujaratiSolarTime         = "gujarati-s"
    case kannadaSolarTime          = "kannada-s"
    case malayalamSolarTime        = "malayalam-s"
    case marathiSolarTime          = "marathi-s"
    case odiaSolarTime             = "odia-s"
    case tamilSolarTime            = "tamil-s"
    case teluguSolarTime           = "telugu-s"
    case vietnameseSolarTime       = "vietnamese-s"
    case vikramSolarTime           = "vikram-s"
    case allEarth                  = "*"
    case allHebrew                 = "heb*"
    case allHebrewSolarTime        = "heb-solar*"
    case allIslamic                = "hiq*"
    case allIslamicSolarTime       = "hiq-solar*"
    case allFrenchRepublican       = "fre*"
    case gregorianOrJulian         = "greOrJul"
    case allEthiopic               = "Ethiopic*"
    
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
    case julianDay
    
    case invalid
} // enum ASACalendarType


// MARK: -

extension ASACalendarCode {
    var localizedName:  String {
        switch self {
        case .julianDay, .reducedJulianDay, .modifiedJulianDay, .truncatedJulianDay, .dublinJulianDay, .cnesJulianDay, .ccsdsJulianDay, .lilianDate, .rataDie, .marsSolDate, .frenchRepublican,
//                .hebrew,
                .hebrewMA,
//                .islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura,
                .julian:
            return NSLocalizedString(self.rawValue, comment: "")
            
        case .hebrew, .islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura, .bangla, .dangi, .gujarati, .kannada, .malayalam, .marathi, .odia, .tamil, .telugu, .vietnamese, .vikram:
            let identifier = self.equivalentCalendarIdentifier
            let shortVersion: String = Locale.current.localizedString(for: identifier!) ?? "???"
            return String.localizedStringWithFormat(NSLocalizedString("%@ (midnight date start)", comment: ""), shortVersion)

        default:
            let identifier = self.equivalentCalendarIdentifier
            return Locale.current.localizedString(for: identifier!) ?? "???"
        }
    } // var localizedName

    var isAppleCalendar:  Bool {
        switch self {
        case .buddhist,
             .chinese,
             .coptic,
             .ethiopicAmeteAlem,
             .ethiopicAmeteMihret,
             .gregorian,
             .hebrew,
             .indian,
             .islamic,
             .islamicCivil,
             .islamicTabular,
             .islamicUmmAlQura,
             .japanese,
             .persian,
             .republicOfChina,
             .bangla,
             .dangi,
             .gujarati,
             .kannada,
             .malayalam,
             .marathi,
             .odia,
             .tamil,
             .telugu,
             .vietnamese,
             .vikram:
            return true
        default:
            return false
        } // switch self
    } // var isAppleCalendar
    
    var isJulianDayCalendar:  Bool {
        switch self {
        case .julianDay, .reducedJulianDay, .modifiedJulianDay, .truncatedJulianDay, .dublinJulianDay, .cnesJulianDay, .ccsdsJulianDay, .lilianDate, .rataDie, .marsSolDate:
            return true
            
        default:
            return false
        } // switch self
    } // var isJulianDayCalendar
    
    var isSunsetTransitionCalendar:  Bool {
        switch self {
        case .hebrewGRA, .islamicSolarTime, .islamicTabularSolarTime, .islamicCivilSolarTime, .islamicUmmAlQuraSolarTime, .hebrewMA:
            return true
        default:
            return false
        } // switch self
    } // var isSunsetTransitionCalendar

    var isHebrewCalendar: Bool {
        switch self {
        case .hebrew, .hebrewMA, .hebrewGRA:
            return true
            
        default:
            return false
        } // switch self
    } // var isHebrewCalendar
    
    var isHebrewSolarTimeCalendar: Bool {
        switch self {
        case .hebrewMA, .hebrewGRA:
            return true
            
        default:
            return false
        } // switch self
    } // var isHebrewSolarTimeCalendar
    
    var isIslamicCalendar: Bool {
        switch self {
        case .islamic, .islamicCivil, .islamicSolarTime, .islamicTabular, .islamicUmmAlQura, .islamicCivilSolarTime, .islamicTabularSolarTime, .islamicUmmAlQuraSolarTime:
            return true
            
        default:
            return false
        }
    }
    
    var isIslamicSolarTimeCalendar: Bool {
        switch self {
        case .islamicSolarTime, .islamicCivilSolarTime, .islamicTabularSolarTime, .islamicUmmAlQuraSolarTime:
            return true
            
        default:
            return false
        }
    }
    
    var is24HourDaysMidnightStartFixedCalendar: Bool {
        switch self {
        case .hebrewGRA, .islamicSolarTime, .islamicTabularSolarTime, .islamicCivilSolarTime, .islamicUmmAlQuraSolarTime, .hebrewMA, .marsSolDate, .dublinJulianDay, .reducedJulianDay, .julianDay:
            return false

        default:
            return true
        }
    }
    
    var isGregorianMonthWeeksDaysCalendar: Bool {
        switch self {
        case .gregorian, .buddhist, .japanese, .republicOfChina:
            return true
            
        default:
            return false
        } // switch self
    } // var isGregorianMonthWeeksDaysCalendar: Bool
    
    var isFrenchRepublicanCalendar: Bool {
        switch self {
        case .frenchRepublican:
            return true
            
        default:
            return false
        } // switch self
    } // var isFrenchRepublicanCalendar: Bool

    var equivalentCalendarIdentifier:  Calendar.Identifier? {
           var identifier:  Calendar.Identifier?
           switch self {
           case ASACalendarCode.buddhist:
               identifier = .buddhist
               
           case ASACalendarCode.chinese:
               identifier = .chinese
               
           case ASACalendarCode.coptic:
               identifier = .coptic
               
           case ASACalendarCode.ethiopicAmeteAlem:
               identifier = .ethiopicAmeteAlem
               
           case ASACalendarCode.ethiopicAmeteMihret:
               identifier = .ethiopicAmeteMihret
               
           case ASACalendarCode.gregorian:
               identifier = .gregorian
               
           case ASACalendarCode.hebrew, .hebrewGRA, .hebrewMA:
               identifier = .hebrew
               
           case ASACalendarCode.indian:
               identifier = .indian
               
           case ASACalendarCode.islamic, .islamicSolarTime:
               identifier = .islamic
               
           case ASACalendarCode.islamicCivil, .islamicCivilSolarTime:
               identifier = .islamicCivil
               
           case ASACalendarCode.islamicTabular, .islamicTabularSolarTime:
               identifier = .islamicTabular
               
           case ASACalendarCode.islamicUmmAlQura, .islamicUmmAlQuraSolarTime:
               identifier = .islamicUmmAlQura
               
           case ASACalendarCode.japanese:
               identifier = .japanese
               
           case ASACalendarCode.persian:
               identifier = .persian
               
           case ASACalendarCode.republicOfChina:
               identifier = .republicOfChina
               
           case .bangla:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .bangla
               } else {
                   identifier = nil
               }
               
           case .dangi:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .dangi
               } else {
                   identifier = nil
               }
           case .gujarati:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .gujarati
               } else {
                   identifier = nil
               }
           case .kannada:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .kannada
               } else {
                   identifier = nil
               }
           case .malayalam:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .malayalam
               } else {
                   identifier = nil
               }
           case .marathi:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .marathi
               } else {
                   identifier = nil
               }
           case .odia:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .odia
               } else {
                   identifier = nil
               }
           case .tamil:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .tamil
               } else {
                   identifier = nil
               }
               
           case .telugu:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .telugu
               } else {
                   identifier = nil
               }
               
           case .vietnamese:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .vietnamese
               } else {
                   identifier = nil
               }
               
           case .vikram:
               if #available(iOS 26.0, watchOS 26.0, *) {
                   identifier = .vikram
               } else {
                   identifier = nil
               }
               
           default:
               identifier = nil
           } // switch calendarCode
           
           return identifier
       } // var equivalentCalendarIdentifier

    var type:  ASACalendarType {
        switch self {
        case .buddhist, .coptic, .ethiopicAmeteAlem, .ethiopicAmeteMihret, .gregorian, .indian,
                .japanese ,.persian, .republicOfChina, .frenchRepublican, .julian, .bangla, .malayalam, .odia, .tamil:
            return .solar
            
        case .chinese, .hebrew, .hebrewGRA, .hebrewMA, .vietnamese, .vikram, .gujarati, .kannada, .telugu:
            return .lunisolar
            
        case .islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura, .islamicSolarTime, .islamicCivilSolarTime, .islamicTabularSolarTime, .islamicUmmAlQuraSolarTime:
            return .lunar
            
        case .julianDay, .reducedJulianDay, .dublinJulianDay, .modifiedJulianDay, .truncatedJulianDay, .cnesJulianDay, .ccsdsJulianDay, .lilianDate, .rataDie, .marsSolDate:
            return .julianDay
            
        default:
            return .invalid
        } // switch self
    } // var type
    
    static func allForClocksOfLocationType(_ locationType: ASALocationType) -> Array<ASACalendarCode> {
        switch locationType {
        case .earthLocation:
            return [.buddhist, .coptic, .ethiopicAmeteAlem, .ethiopicAmeteMihret, .gregorian, .indian, .japanese ,.persian, .republicOfChina, .frenchRepublican, .julian, .chinese,
//                    .hebrew,
                    .hebrewGRA, .hebrewMA,
//                .islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura,
                .islamicSolarTime, .islamicCivilSolarTime, .islamicTabularSolarTime, .islamicUmmAlQuraSolarTime, .bangla, .dangi, .gujarati, .kannada, .malayalam, .marathi, .odia, .tamil, .telugu, .vietnamese, .vikram]
        case .earthUniversal:
            return [.julianDay, .reducedJulianDay, .dublinJulianDay, .modifiedJulianDay, .truncatedJulianDay, .cnesJulianDay, .ccsdsJulianDay, .lilianDate, .rataDie]
        case .marsUniversal:
            return [.marsSolDate]
        } // switch locationType
    } // static func allForClocksOfLocationType(_ locationType: ASALocationType) -> Array<ASACalendarCode>
    
    // TODO:  Some Indian calendars crash the date picker.  This is likely Apple’s fault.
    static let datePickerSafeCalendars: [ASACalendarCode] = [
        .gregorian,
        .buddhist,
        .chinese,
        .coptic,
        .ethiopicAmeteAlem,
        .ethiopicAmeteMihret,
        .hebrew,
        .indian,
        .islamic,
        .islamicCivil,
        .islamicTabular,
        .islamicUmmAlQura,
        .japanese,
        .persian,
        .republicOfChina,
        .bangla,
        .dangi,
//        .gujarati,
//        .kannada,
        .malayalam,
//        .marathi,
        .odia,
        .tamil,
//        .telugu,
        .vietnamese,
//        .vikram
    ]

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
            return self != .marsSolDate
            // TODO:  Needs to be modified when adding calendars for other planets, e.g., the Darian calendar for Mars.
        }
        
        if self == .gregorianOrJulian && (otherCalendarCode == .gregorian || otherCalendarCode == .julian) {
            return true
        }
        
        if self == .allEthiopic && (otherCalendarCode == .ethiopicAmeteAlem || otherCalendarCode == .ethiopicAmeteMihret) {
            return true
        }

        return self == otherCalendarCode
    } // func matches(_ otherCalendarCode: ASACalendarCode) -> Bool
    
    var locationType: ASALocationType {
        switch self {
        case .julianDay, .reducedJulianDay, .dublinJulianDay, .modifiedJulianDay, .truncatedJulianDay, .cnesJulianDay, .ccsdsJulianDay, .lilianDate, .rataDie:
            return .earthUniversal
            
        case .marsSolDate:
            return .marsUniversal
            
        default:
            return .earthLocation
        }
    } // var locationType
    
    func genericBuiltInEventCalendarNames(regionCode: String) -> Array<String> {
        switch self {
        case .buddhist:
            return [regionCode + " (Buddhist)"]

        case .chinese:
            return [regionCode + " (Chinese)"]
            
        case .coptic:
            return [regionCode + " (Coptic)"]
            
        case .ethiopicAmeteAlem, .ethiopicAmeteMihret:
            return [regionCode + " (Ethiopic)"]
            
        case .gregorian:
            return [regionCode]

        case .indian:
            return [regionCode + " (Indian)"]
            
        case .islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura, .islamicSolarTime, .islamicCivilSolarTime, .islamicTabularSolarTime, .islamicUmmAlQuraSolarTime:
            return [regionCode + " (Muslim)", "Islam (general)"]
            
        case .japanese:
            return [regionCode + " (Japanese)"]
            
        case .persian:
            return [regionCode + " (Persian)"]
            
        case .republicOfChina:
            return [regionCode + " (ROC)"]

        case .hebrewGRA, .hebrewMA, .hebrew:
            var result: [String] = [regionCode + " (Hebrew)", "Judaism"]
            if regionCode != REGION_CODE_Israel {
                result.append("IL (Hebrew)")
            }
            return result

        case .frenchRepublican:
            return ["Rural"]
            
        case .julian:
            return [regionCode + " (Julian)"]
            
        default:
            return []
        } // switch self
    } // func genericBuiltInEventCalendarNames(regionCode: String) -> Array<String>
} // extension ASACalendarCode

