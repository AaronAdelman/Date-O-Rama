//
//  StringExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-08-05.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation
import SwiftAA

extension String {
    // Based on https://stackoverflow.com/questions/30402435/swift-turn-a-country-code-into-a-emoji-flag-via-unicode
    // Converts a country code into a Unicode emoji flag
    var flag:  String {
        let FAILURE_FLAG = "📍"
        let EARTH_FLAG   = "🇺🇳"
        
        if self == "" {
            return FAILURE_FLAG
        }
        
        if self.count == 1 {
            if self == REGION_CODE_Earth {
                return EARTH_FLAG
            } else {
                return FAILURE_FLAG
            }
        }
        
        if self.count == 3 {
            // We are probably dealing with a UN M49 code
            switch self {
                case "001": // Earth in general
                return EARTH_FLAG
                
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
                
            case REGION_CODE_Sun:
                return "☉"
                
            case REGION_CODE_Mercury:
                return "☿"
                
            case REGION_CODE_Venus:
                return "♀"
                
            case REGION_CODE_Moon:
                return "☽"
                
            case REGION_CODE_Mars:
                return "♂"
                
            case REGION_CODE_Jupiter:
                return "♃"
                
            case REGION_CODE_Saturn:
                return "♄"
                
            case REGION_CODE_Uranus:
                return "⛢"
                
            case REGION_CODE_Neptune:
                return "♆"
                
            case REGION_CODE_Pluto:
                return "♇"

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
    func celestialBody(julianDay: JulianDay) -> CelestialBody? {
        switch self {
        case REGION_CODE_Sun:
            return Sun(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Mercury:
            return Mercury(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Venus:
            return Venus(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Moon:
            return Moon(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Mars:
            return Mars(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Jupiter:
            return Jupiter(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Saturn:
            return Saturn(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Uranus:
            return Uranus(julianDay: julianDay, highPrecision: true)
            
        case REGION_CODE_Neptune:
            return Neptune(julianDay: julianDay, highPrecision: true)
                        
        default:
            return nil
        } // switch self
    }
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

let REGION_CODE_Sun     = "zsu"
let REGION_CODE_Mercury = "zme"
let REGION_CODE_Venus   = "zve"
let REGION_CODE_Earth   = "x"
let REGION_CODE_Moon    = "zmo"
let REGION_CODE_Mars    = "zma"
let REGION_CODE_Jupiter = "zju"
let REGION_CODE_Saturn  = "zsa"
let REGION_CODE_Uranus  = "zur"
let REGION_CODE_Neptune = "zne"
let REGION_CODE_Pluto   = "zpl"

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


// MARK:  -

extension Character {
    var isSyntaxCharacter: Bool {
        switch self {
        case "A"..."Z", "a"..."z":
            return true
            
        default:
            return false
        }
    }
}

extension String {
    private enum ComponentizationMode {
        case symbol
        case literal
    } // enum ComponentizationMode
    
    var dateFormatPatternComponents: Array<ASADateFormatPatternComponent> {
        var buffer: String = ""
        var lastCharacter: Character? = nil
        var mode = ComponentizationMode.symbol
        var components: Array<ASADateFormatPatternComponent> = []
        var quoteMode = false
        
        for scalar in self.unicodeScalars { // We are doing this slightly weird thing, because at least one date format pattern puts a combining accent immediately after a quote symbol, and we need to make sure that we get the quote and the combining accent separately.
            let character = Character(scalar)
            if buffer.isEmpty {
                buffer.append(character)
                debugPrint(#file, #function, "Buffer is now “\(buffer)”,  Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
            } else if character == "'" {
                if mode == .symbol {
                    let newComponent = ASADateFormatPatternComponent(type: .symbol, string: buffer)
                    components.append(newComponent)
                    debugPrint(#file, #function, "Appending symbol component “\(buffer)”")
                    buffer = ""
                } else {
                    assert(mode == .literal)
                    if lastCharacter == "'" {
                        buffer.append(character)
                    }
                }
                
                mode = .literal
                quoteMode = !quoteMode
                debugPrint(#file, #function, "Buffer is now “\(buffer)”,  Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
            } else if mode == .symbol {
                if character == lastCharacter {
                    buffer.append(character)
                    debugPrint(#file, #function, "Buffer is now “\(buffer)”,  Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                } else {
                    let newComponent = ASADateFormatPatternComponent(type: .symbol, string: buffer)
                    components.append(newComponent)
                    debugPrint(#file, #function, "Appending symbol component “\(buffer)”")
                    buffer = String(character)
                    mode = character.isSyntaxCharacter ? .symbol : .literal
                    debugPrint(#file, #function, "Buffer is now “\(buffer)”,  Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                }
            } else if mode == .literal {
                if character.isSyntaxCharacter && !quoteMode {
                    let newComponent = ASADateFormatPatternComponent(type: .literal, string: buffer)
                    components.append(newComponent)
                    debugPrint(#file, #function, "Appending literal component “\(buffer)”")
                    buffer = String(character)
                    mode = .symbol
                    debugPrint(#file, #function, "Buffer is now “\(buffer)”,  Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                } else {
                    buffer.append(character)
                    debugPrint(#file, #function, "Buffer is now “\(buffer)”,  Mode is now \(mode == .literal ? "literal" : "symbol"), Quote mode is now \(quoteMode ? "true" : "false")")
                }
            }
            
            lastCharacter = character
        } // self.forEach
        
        let newComponent = ASADateFormatPatternComponent(type: mode == .literal ? .literal : .symbol, string: buffer)
        components.append(newComponent)
                            debugPrint(#file, #function, "Mode is now ", mode == .literal ? "literal" : "symbol")

        return components
    } // var dateFormatPatternComponents
} // extension String
