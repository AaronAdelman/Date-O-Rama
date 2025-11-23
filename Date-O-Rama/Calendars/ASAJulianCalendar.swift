//
//  ASAJulianCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation
import JulianDayNumber

public class ASAJulianCalendar: ASABoothCalendar, ASACalendarWithEaster {
    public let BCE = 0
    public let CE  = 1
    
    
// MARK: - ASACalendarWithEaster
    
    func calculateEaster(era: Int, year: Int) -> (month: Int, day: Int)? {
        switch era {
        case BCE:
            return nil
            
        case CE:
            return JulianCalendar.easter(year: year)
            
        default:
            return nil
        } // switch era
    }
}
