//
//  NSNumberExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

extension NSNumber {
    func monthSymbol(calendar: Calendar) -> String {
        let index = self.intValue - 1
        return calendar.monthSymbols[index]
    } // func monthSymbol(calendar: Calendar) -> String
} // extension NSNumber
