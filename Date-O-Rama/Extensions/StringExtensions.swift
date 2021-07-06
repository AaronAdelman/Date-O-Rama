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
                
                case "002", "015", "202", "014", "017", "018", "011":  // Africa
                return "🌍"
                
                case "019", "419", "029", "013", "005", "003", "021":  // Americas
                return "🌎"
                
            case "142", "143", "030", "035", "034", "145": // Asia
                return "🌏"
                
            case "150", "151", "154", "039", "155": // Europe
                return "🇪🇺"

            case "009", "053", "054", "057", "061":  // Oceania
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
    
    var localeRegionCodeFlag:  String {
        let regionCode = self.localeRegionCode
        if regionCode == nil {
            return "🏳️"
        }
        
        return regionCode!.flag
    } //var localeRegionCodeFlag
} // extension String
