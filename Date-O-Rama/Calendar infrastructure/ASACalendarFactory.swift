//
//  ASACalendarFactory.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation


class ASACalendarFactory {
    class func calendar(code:  ASACalendarCode) -> ASACalendar? {
        var revisedCode: ASACalendarCode
        switch code {
        case .Gregorian_Old:
            revisedCode = .Gregorian
        default:
            revisedCode = code
        } // switch code
        
        assert(!revisedCode.isAbstract)
        
        if revisedCode == .Gregorian {
            return ASAGregorianCalendar()
        } else if revisedCode.isAppleCalendar {
            return ASAAppleCalendar(calendarCode:  revisedCode)
        } else if revisedCode.isJulianDayCalendar {
            return ASAJulianDayCalendar(calendarCode:  revisedCode)
        } else if revisedCode.isSunsetTransitionCalendar {
            return ASASunsetTransitionCalendar(calendarCode: revisedCode)
        } else if revisedCode.isFrenchRepublicanCalendar {
            return ASAFrenchRepublicanCalendar(calendarCode: revisedCode)
        } else if revisedCode == .Julian {
            return ASAJulianCalendar()
        }
     
        return nil
    } // class func calendar(code:  ASACalendarCode) -> ASACalendar?
} // class ASACalendarFactory
