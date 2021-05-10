//
//  EKWeekdayExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKit

extension EKWeekday {
    func standaloneSymbol(calendar: Calendar) -> String {
        var index = 8
        switch self {
        case .sunday:
            index = 0
        
        case .monday:
            index = 1
            
        case .tuesday:
            index = 2
            
        case .wednesday:
            index = 3
            
        case .thursday:
            index = 4
            
        case .friday:
            index = 5
            
        case .saturday:
            index = 6
        } // switch self
        
        return calendar.standaloneWeekdaySymbols[index]
    } // func standaloneSymbol(calendar: Calendar) -> String
} // extension EKWeekday
