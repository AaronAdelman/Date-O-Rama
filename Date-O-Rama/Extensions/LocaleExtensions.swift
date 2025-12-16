//
//  LocaleExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 15/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension Locale {
    static func desiredLocale(_ identifier:  String) -> Locale {
        if identifier == "" {
            return Locale.current // autoupdatingCurrent makes the date formatter default to the Gregorian calendar.
        } else {
            return Locale(identifier: identifier)
        }
    } // static func desiredLocale(_ identifier:  String) -> Locale
} //extension Locale
