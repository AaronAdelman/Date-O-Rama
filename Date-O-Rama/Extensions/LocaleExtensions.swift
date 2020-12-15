//
//  LocaleExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 15/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension Locale {
    static func desiredLocale(localeIdentifier:  String) -> Locale {
        if localeIdentifier == "" {
            return Locale.autoupdatingCurrent
        } else {
            return Locale(identifier: localeIdentifier)
        }
    }
}
