//
//  ASACalendarFactory.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

protocol ASACalendar {
    var calendarCode:  ASACalendarCode { get set }
    
    func defaultDateGeekCode(majorDateFormat:  ASAMajorFormat) -> String
    func dateString(now:  Date, localeIdentifier:  String, majorDateFormat:  ASAMajorFormat, dateGeekFormat:  String, majorTimeFormat:  ASAMajorFormat, timeGeekFormat:  String, location:  CLLocation?) -> String
    func dateString(now:  Date, LDMLString:  String, location:  CLLocation?) -> String
    func details() -> Array<ASADetail>
    func supportsLocales() -> Bool
} // protocol ASACalendar


// MARK: -

class ASACalendarFactory {
    class func calendar(code:  ASACalendarCode) -> ASACalendar? {
        if code.ordinaryAppleCalendar() {
            return ASAAppleCalendar(calendarCode: code)
        } else if code.ISO8601AppleCalendar() {
            return ASAISO8601Calendar()
        }
     
        return nil
    } // class func calendar(code:  ASACalendarCode) -> ASACalendar?
} // class ASACalendarFactory
