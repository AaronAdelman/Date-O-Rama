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
        assert(!code.isAbstract)
        
        if code == .gregorian {
            return ASAGregorianCalendar()
        } else if code.isAppleCalendar {
            return ASAAppleCalendar(calendarCode:  code)
        } else if code.isJulianDayCalendar {
            return ASAJulianDayCalendar(calendarCode:  code)
        } else if code.isSunsetTransitionCalendar {
            return ASASunsetTransitionCalendar(calendarCode: code)
        } else if code.isFrenchRepublicanCalendar {
            return ASAFrenchRepublicanCalendar(calendarCode: code)
        } else if code == .julian {
            return ASAJulianCalendar(calendarCode: code)
        }
     
        return nil
    } // class func calendar(code:  ASACalendarCode) -> ASACalendar?
} // class ASACalendarFactory
