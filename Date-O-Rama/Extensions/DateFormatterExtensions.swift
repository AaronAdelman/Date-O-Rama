//
//  DateFormatterExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 27/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension DateFormatter {
    func apply(dateStyle:  DateFormatter.Style, LDMLExtension:  String) {
        self.dateStyle = dateStyle
        let alchemy = LDMLExtension + self.dateFormat
        let dateFormat = DateFormatter.dateFormat(fromTemplate:alchemy, options: 0, locale: self.locale)
        if dateFormat != nil {
            self.setLocalizedDateFormatFromTemplate(dateFormat!)
        }
    } // func setDateStyle(dateStyle:  DateFormatter.Style, LDMLExtension:  String)

    func apply(dateStyle:  DateFormatter.Style, LDMLExtension:  String, removing:  Array<String>) {
        self.dateStyle = dateStyle
        var rawDateFormat = self.dateFormat ?? ""
        for thingToRemove in removing {
            rawDateFormat = rawDateFormat.replacingOccurrences(of: thingToRemove, with: "")
        }
        let alchemy = LDMLExtension + rawDateFormat
        let dateFormat = DateFormatter.dateFormat(fromTemplate:alchemy, options: 0, locale: self.locale)
        if dateFormat != nil {
            self.setLocalizedDateFormatFromTemplate(dateFormat!)
        }
    } // func apply(dateStyle:  DateFormatter.Style, LDMLExtension:  String, removing:  Array<String>)

    func apply(dateStyle:  DateFormatter.Style, template:  String) {
        self.dateStyle = dateStyle
        self.setLocalizedDateFormatFromTemplate(template)
    } // func apply(dateStyle:  DateFormatter.Style, template:  String)

    static let yearCodes:  Array<String> = ["y", "G", "Y", "U", "r"]
    
    static let nonYearCodes: Array<String> = ["Q", "q", "M", "L", "l", "w", "W", "d", "D", "F", "g", "E", "e", "c"]

    static let nonYearNonMonthCodes: Array<String> = ["w", "W", "d", "D", "F", "g", "E", "e", "c"]
    
    func apply(localeIdentifier: String, timeFormat: ASATimeFormat, timeZone: TimeZone) {
        self.locale = Locale.desiredLocale(localeIdentifier)

        self.timeZone = timeZone

        switch timeFormat {
        case .none:
            self.timeStyle = .none
            
        case .medium:
            self.timeStyle = .medium

        default:
            self.timeStyle = .medium
        } // switch timeFormat
    }
    
    func apply(dateFormat: ASADateFormat) {
        switch dateFormat {
        case .ISO8601YearDay, .ISO8601YearMonthDay, .ISO8601YearWeekDay:
            self.dateStyle = .none // Had to fill in something.  Don’t handle ISO 8601 here!
        
        case .none:
            self.dateStyle = .none
            
        case .full, .fullWithRomanYear:
            self.dateStyle = .full
            
        case .long, .longWithRomanYear:
            self.dateStyle = .long
            
        case .medium:
            self.dateStyle = .medium
            
        case .short, .shortWithRomanYear:
            self.dateStyle = .short

        case .shortWithWeekday:
            self.apply(dateStyle: .short, LDMLExtension: "eee")

        case .mediumWithWeekday:
            self.apply(dateStyle: .medium, LDMLExtension: "eee")

        case .abbreviatedWeekday:
            self.apply(dateStyle: .short, template: "eee")

        case .dayOfMonth:
            self.apply(dateStyle: .short, template: "d")

        case .abbreviatedWeekdayWithDayOfMonth:
            self.apply(dateStyle: .short, template: "eeed")

        case .shortWithWeekdayWithoutYear:
            self.apply(dateStyle: .short, LDMLExtension: "E", removing:  DateFormatter.yearCodes)

        case .mediumWithWeekdayWithoutYear:
            self.apply(dateStyle: .medium, LDMLExtension: "E", removing:  DateFormatter.yearCodes)

        case .fullWithoutYear:
            self.apply(dateStyle: .full, LDMLExtension: "", removing:  DateFormatter.yearCodes)
            
        case .shortYearOnly:
            self.apply(dateStyle: .short, LDMLExtension: "", removing: DateFormatter.nonYearCodes)
            
        case .shortYearAndMonthOnly:
            self.apply(dateStyle: .short, LDMLExtension: "", removing: DateFormatter.nonYearNonMonthCodes)
            
        case .longWithoutYear:
            self.apply(dateStyle: .long, LDMLExtension: "", removing:  DateFormatter.yearCodes)
            
        case .mediumWithoutYear:
            self.apply(dateStyle: .medium, LDMLExtension: "", removing:  DateFormatter.yearCodes)
            
        case .shortWithoutYear:
            self.apply(dateStyle: .short, LDMLExtension: "", removing:  DateFormatter.yearCodes)
        } // switch dateFormat
    }
} // extension DateFormatter
