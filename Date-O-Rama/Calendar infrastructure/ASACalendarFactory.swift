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
            return ASAAppleCalendar(calendarCode: code)
        } else if code.isJulianDayCalendar {
            return ASAJulianDayCalendar(calendarCode: code)
        } else if code.isHebrewSolarTimeCalendar || code.isIslamicSolarTimeCalendar {
            return ASAJudeoIslamicCalendar(calendarCode: code)
        } else if code == .frenchRepublican {
            return ASAFrenchRepublicanCalendar(calendarCode: code)
        } else if code == .julian {
            return ASAJulianCalendar(calendarCode: code)
        } else if code == .bahaiSolarTime {
            return ASABahaiCalendar(calendarCode: code)
        }
     
        return ASAUnknownCalendar(calendarCode: code)
    } // class func calendar(code:  ASACalendarCode) -> ASACalendar?
} // class ASACalendarFactory
