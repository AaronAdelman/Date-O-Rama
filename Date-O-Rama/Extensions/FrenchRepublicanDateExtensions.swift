//
//  FrenchRepublicanDateExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/01/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import FrenchRepublicanCalendarCore

extension FrenchRepublicanDate {
    func dateComponents(locationData: ASALocation, calendar: ASAFrenchRepublicanCalendar) -> ASADateComponents {
        let ApplesComponents = self.components
        let month: Int? = ApplesComponents?.month
        let weekday: Int? = month == 13 ? 0 : ApplesComponents?.weekday
        let components = ASADateComponents(calendar: calendar, locationData: locationData, era: ApplesComponents?.era, year: ApplesComponents?.year, yearForWeekOfYear: ApplesComponents?.yearForWeekOfYear, quarter: ApplesComponents?.quarter, month: month, isLeapMonth: ApplesComponents?.isLeapMonth, weekOfMonth: ApplesComponents?.weekOfMonth, weekOfYear: ApplesComponents?.weekOfYear, weekday: weekday, weekdayOrdinal: ApplesComponents?.weekdayOrdinal, day: ApplesComponents?.day, hour: ApplesComponents?.hour, minute: ApplesComponents?.minute, second: ApplesComponents?.second, nanosecond: ApplesComponents?.nanosecond, solarHours: nil, dayHalf: nil)
        return components
    } // func dateComponents(locationData: ASALocation, calendar: ASAFrenchRepublicanCalendar) -> ASADateComponents
    
    init(now: Date, dateFormat: ASADateFormat, timeZone: TimeZone?, calendarCode: ASACalendarCode) {
        let RomanYear: Bool = dateFormat.isRomanYear
        
        var variant: FrenchRepublicanDateOptions.Variant
        switch calendarCode {
        case .FrenchRepublicanRomme:
            variant = .romme
            
        default:
            variant = .original
        } // switch calendarCode
        
        let options = FrenchRepublicanDateOptions(romanYear: RomanYear, variant: variant, treatSansculottidesAsAMonth: true)
         self = FrenchRepublicanDate(date: now, options: options, timeZone: timeZone)
    } // init(now: Date, dateFormat: ASADateFormat)
} // extension FrenchRepublicanDate
