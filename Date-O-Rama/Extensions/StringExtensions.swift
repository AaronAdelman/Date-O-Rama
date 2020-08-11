//
//  StringExtensions.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-08-05.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

extension String {
    func chop() -> Array<String> {
        let selfAsArray = Array(self)
        
        var i = 0
        var resultsArray:  Array<String> = []
        while i < selfAsArray.count {
            let runElement = selfAsArray[i]
            //    print(runElement)
            var j = i
            
            while (j < selfAsArray.count) && (runElement == selfAsArray[j]) {
                j += 1
            }
            let runString = String.init(repeatElement(runElement, count: j - i))
            resultsArray.append(runString)
            i = j
        }
        return resultsArray
    } // func chop() -> Array<String>
    
    func relevantSection() -> String? {
        if self.isEmpty {
            return nil
        }
        
        let firstCharacter = self.first
        
        if firstCharacter == nil {
            return nil
        }
        
        if !(firstCharacter!.isLetter && firstCharacter!.isASCII)   {
            return nil
        }
        switch firstCharacter {
        case "e":
            return "E"
            
        case "h", "H", "k", "K":
            return "H"
            
        case "z", "Z", "O", "V", "v", "X", "x":
            return "z"
            
        case "a", "b", "B":
            return "a"
            
        default:
            return "\(firstCharacter!)"
        } // switch firstCharacter
    } // func relevantSection() -> String?
    
    func dateComponents(calendarCode:  ASACalendarCode) -> Dictionary<String, String> {
        if self != "" {
            var temp:  Dictionary<String, String> = [:]
            let codes = self.chop()
            for code in codes {
                let relevantSection = code.relevantSection()
                if relevantSection != nil {
                    temp[relevantSection!] = code
                }
            } // for code in codes
//            debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
            return temp
        } else {
            
            let temp = [
                "E": "eee",
                "y": "y",
                "M": "MMM",
                "d": "d",
                "G": "",
                "Y": "",
                "U": "",
                "r": "",
                "Q": "",
                "w": "",
                "W": "",
                "D": "",
                "F": "",
                //                    "g": "",
//                "-": ""
            ]
//            debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
            return temp
        }
        
    } // func dateComponents(calendarCode:  ASACalendarCode) -> Dictionary<String, String>

    func timeComponents(calendarCode:  ASACalendarCode) -> Dictionary<String, String> {
        if self != "" {
            var temp:  Dictionary<String, String> = [:]
            let codes = self.chop()
            for code in codes {
                let relevantSection = code.relevantSection()
                if relevantSection != nil {
                    temp[relevantSection!] = code
                }
            } // for code in codes
//            debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
            return temp
        } else {
            
            let temp = [
                "a": "",
                "H": "HH",
                "m": "mm",
                "s": "ss"
            ]
//            debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
            return temp
        }
    }
    
    static func geekFormat(components:  Dictionary<String, String>) -> String {
        var temp:  String = ""
        for componentKey in components.keys {
            let component = components[componentKey] ?? ""
            temp += component
        } // for componentKey in ccomponents.keys
//        debugPrint("\(#file) \(#function) Components = \(components), geek format = \(temp)")
        return temp
    } // static func geekFormat(components:  Dictionary<String, String>) -> String
    
} // extension String

extension String {
    // Based on https://stackoverflow.com/questions/30402435/swift-turn-a-country-code-into-a-emoji-flag-via-unicode
    // Converts a country code into a Unicode emoji flag
    func flag() -> String {
        let FAILURE_FLAG = "🏳️"
        
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
    } // func flag() -> String
} // extension String

extension String {
    func localeLanguageCode() -> String? {
        let array = self.components(separatedBy: "_")
        if array.count < 1 {
            return nil
        }
        
        return array[0]
    } // func localeLanguageCode() -> String?
    
    func localeRegionCode() -> String? {
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
    }
    
    func localeCountryCodeFlag() -> String {
        let countryCode = self.localeRegionCode()
        if countryCode == nil {
            return "🏳️"
        }
        
        return countryCode!.flag()
    }
} // extension String

extension String {
    func row(backupIndex:  Int) -> ASARow {
        let tempUUID = UUID(uuidString: self)
        if tempUUID == nil {
            return ASARow.generic()
        }
        
        let temp = ASAUserData.shared().mainRows.first(where: {$0.uuid == tempUUID!})
        if temp != nil {
            return temp!
        }
        
        if ASAUserData.shared().mainRows.count >= backupIndex + 1 {
            return ASAUserData.shared().mainRows[backupIndex]
        }
        
        return ASARow.generic()
    } // func row(backupIndex:  Int) -> ASARow
} // extension UUID
