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
} // extension DateFormatter
