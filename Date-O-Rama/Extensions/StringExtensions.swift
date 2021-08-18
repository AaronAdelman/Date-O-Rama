//
//  StringExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-08-05.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

extension String {
    // Based on https://stackoverflow.com/questions/30402435/swift-turn-a-country-code-into-a-emoji-flag-via-unicode
    // Converts a country code into a Unicode emoji flag
    var flag:  String {
        let FAILURE_FLAG = "📍"
        
        if self == "" {
            return FAILURE_FLAG
        }
        
        if self.count == 3 {
            // We are probably dealing with a UN M49 code
            switch self {
                case "001": // Earth in general
                return "🇺🇳"
                
                case "002", "015", "202", "014", "017", "018", "011": // Africa
                return "🌍"
                
                case "019", "419", "029", "013", "005", "003", "021": // Americas
                return "🌎"
                
            case "142", "143", "030", "035", "034", "145": // Asia
                return "🌏"
                
            case "150", "151", "154", "039", "155": // Europe
                return "🇪🇺"

            case "009", "053", "054", "057", "061": // Oceania
                return "🌏"

            default:
                return FAILURE_FLAG
            } // switch self
        }
        
        return self
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    } // var flag
} // extension String

extension String {
    var localeLanguageCode:  String? {
        let array = self.components(separatedBy: "_")
        if array.count < 1 {
            return nil
        }
        
        return array[0]
    } // var localeLanguageCode
    
    var localeRegionCode:  String? {
        let array = self.components(separatedBy: "_")
        let count: Int = array.count
        if count == 2 || count == 3 {
            let suspectedCountryCode = array[count - 1]
            if suspectedCountryCode.count != 2 && suspectedCountryCode.count != 3 {
                return nil
            }
            
            return suspectedCountryCode
        }
        
        return nil
    } // var localeRegionCode
    
    var localeCountryCodeFlag:  String {
        let countryCode = self.localeRegionCode
        if countryCode == nil {
            return "🏳️"
        }
        
        return countryCode!.flag
    } //var localeCountryCodeFlag
} // extension String


// MARK:  -

extension String {
    var backupWeekendDays: Array<Int> {
        // Because Apple didn’t make its code for weekends work right outside of the current location
        switch self {
        case REGION_CODE_Equatorial_Guinea,
             REGION_CODE_Germany,
             REGION_CODE_Hong_Kong,
             REGION_CODE_India,
             REGION_CODE_North_Korea,
             REGION_CODE_Uganda,
             REGION_CODE_Bolivia:
            return [1]
            
        case REGION_CODE_Brunei_Darussalam:
            return [6, 1]
            
        case REGION_CODE_Djibouti,
             REGION_CODE_Iran,
             REGION_CODE_Palestine,
             REGION_CODE_Somalia:
            return [6]
            
        case REGION_CODE_Afghanistan:
            return [5, 6]
            
        case REGION_CODE_Bangladesh,
             REGION_CODE_Algeria,
             REGION_CODE_Bahrain,
             REGION_CODE_Egypt,
             REGION_CODE_Iraq,
             REGION_CODE_Israel,
             REGION_CODE_Jordan,
             REGION_CODE_Kuwait,
             REGION_CODE_Libya,
             REGION_CODE_Maldives,
             REGION_CODE_Oman,
             REGION_CODE_Qatar,
             REGION_CODE_Saudi_Arabia,
             REGION_CODE_Sudan,
             REGION_CODE_Syria,
             REGION_CODE_Yemen,
             REGION_CODE_United_Arab_Emirates,
             REGION_CODE_Malaysia:
            return [6, 7]
            
        case REGION_CODE_Nepal:
            return [7]
            
        default:
            return [7, 1]
        } // switch self
    } // var backupWeekendDays
} // extension String


// MARK:  -

let REGION_CODE_Earth = "x"

let REGION_CODE_Northern_Hemisphere = "xb"
let REGION_CODE_Southern_Hemisphere = "xc"

let REGION_CODE_Afghanistan          = "AF"
let REGION_CODE_Algeria              = "DZ"
let REGION_CODE_Bahrain              = "BH"
let REGION_CODE_Bangladesh           = "BD"
let REGION_CODE_Bolivia              = "BO"
let REGION_CODE_Brunei_Darussalam    = "BN"
let REGION_CODE_Djibouti             = "DJ"
let REGION_CODE_Egypt                = "EG"
let REGION_CODE_Equatorial_Guinea    = "GQ"
let REGION_CODE_Germany              = "DE"
let REGION_CODE_Hong_Kong            = "HK"
let REGION_CODE_India                = "IN"
let REGION_CODE_Iran                 = "IR"
let REGION_CODE_Iraq                 = "ǏQ"
let REGION_CODE_Israel               = "IL"
let REGION_CODE_Jordan               = "JO"
let REGION_CODE_Kuwait               = "KW"
let REGION_CODE_Libya                = "LY"
let REGION_CODE_Malaysia             = "MY"
let REGION_CODE_Maldives             = "MV"
let REGION_CODE_Nepal                = "NP"
let REGION_CODE_North_Korea          = "KP"
let REGION_CODE_Oman                 = "OM"
let REGION_CODE_Palestine            = "PS"
let REGION_CODE_Qatar                = "QA"
let REGION_CODE_Saudi_Arabia         = "SA"
let REGION_CODE_Somalia              = "SO"
let REGION_CODE_Sudan                = "SD"
let REGION_CODE_Syria                = "SY"
let REGION_CODE_Uganda               = "UG"
let REGION_CODE_United_Arab_Emirates = "AE"
let REGION_CODE_Yemen                = "YE"
