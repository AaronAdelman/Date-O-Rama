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
        if code.isAppleCalendar() {
            return ASAAppleCalendar(calendarCode:  code)
        } else if code.isISO8601Calendar() {
            return ASAISO8601Calendar()
        } else if code.isJulianDayCalendar() {
            return ASAJulianDayCalendar(calendarCode:  code)
        } else if code.isSunsetTransitionCalendar() {
            return ASASunsetTransitionCalendar(calendarCode: code)
        }
     
        return nil
    } // class func calendar(code:  ASACalendarCode) -> ASACalendar?
} // class ASACalendarFactory
