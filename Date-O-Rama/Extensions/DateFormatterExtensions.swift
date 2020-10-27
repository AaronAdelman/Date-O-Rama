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
} // extension DateFormatter
