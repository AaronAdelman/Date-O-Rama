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
    
    private func relevantSection() -> String? {
        if self.isEmpty {
            return nil
        }
        
        let firstCharacter = self.first
        switch firstCharacter {
        case "e":
            return "E"
            
        case "y":
            return "y"
            
        case "M":
            return "M"
            
        case "d":
            return "d"
            
        case "G":
            return "G"
            
        case "Y":
            return "Y"
            
        case "U":
            return "U"
            
        case "r":
            return "r"
            
        case "Q":
            return "Q"
            
        case "w":
            return "w"
            
        case "W":
            return "W"
            
        case "D":
            return "D"
            
        case "F":
            return "F"
            
        case "g":
            return "g"
            
        default:
            return nil
        } // switch firstCharacter
    } // func relevantSection() -> String?
    
    func components(calendarCode:  ASACalendarCode) -> Dictionary<String, String> {
        if self != "" {
            var temp:  Dictionary<String, String> = [:]
            let codes = self.chop()
            for code in codes {
                let relevantSection = code.relevantSection()
                if relevantSection != nil {
                    temp[relevantSection!] = code
                }
            } // for code in codes
            debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
            return temp
        } else {
            if calendarCode == ASACalendarCode.ISO8601 {
                let temp = [
                    "E": "",
                    "y": "yyyyy",
                    "M": "MM",
                    "d": "dd",
                    "G": "",
                    "Y": "",
                    "U": "",
                    "r": "",
                    "Q": "",
                    "w": "",
                    "W": "",
                    "D": "",
                    "F": "",
                    "g": "",
                    "-": "-"
                ]
                debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
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
                    "g": "",
                    "-": ""
                ]
                debugPrint("\(#file) \(#function) Geek format = \(self), components = \(temp)")
                return temp
            }
        }
    } // func components(calendarCode:  ASACalendarCode) -> Dictionary<String, String>
    
    static func geekFormat(components:  Dictionary<String, String>) -> String {
        var temp:  String = ""
        for componentKey in components.keys {
            let component = components[componentKey] ?? ""
            temp += component
        } // for componentKey in c.keys
        debugPrint("\(#file) \(#function) Components = \(components), geek format = \(temp)")
        return temp
    } // static func geekFormat(components:  Dictionary<String, String>) -> String
    
} // extension String
