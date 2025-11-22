//
//  ASAProcessedClock.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
//import CoreLocation
import SwiftUI

struct ASAProcessedClock: ASAProcessedClockProtocol {
    var calendarString:  String
    var dateString:  String
    var timeString:  String?

    var daysPerWeek: Int?
    var day:  Int
    var weekday:  Int
    var daysInMonth:  Int
    var supportsMonths:  Bool

    var hour:  Int?
    var minute:  Int?
    var second:  Int?
    var fractionalHour: Double?
    var dayHalf: ASADayHalf?

    var transitionType:  ASATransitionType
    var calendarType:  ASACalendarType

    var calendarCode:  ASACalendarCode

    var veryShortStandaloneWeekdaySymbols:  Array<String>?

    var dateEvents:  Array<ASAEventCompatible>
    var timeEvents:  Array<ASAEventCompatible>
    
    var startOfDay:  Date
    var startOfNextDay:  Date
    
    var weekendDays: Array<Int>?
    var regionCode: String?
    
    var monthIsBlank: Bool
    var blankWeekdaySymbol: String?

    var usesDeviceLocation: Bool
    
    var supportsExternalEvents: Bool
    
    var miniCalendarWeekdayItems: [ASAMiniCalendarWeekdayModel]?
    var miniCalendarDayItems: [ASAMiniCalendarDayModel]?
    var characterDirection: Locale.LanguageDirection
    
    init(clock:  ASAClock, now:  Date, isForComplications: Bool, location: ASALocation, usesDeviceLocation: Bool) {
        self.usesDeviceLocation = usesDeviceLocation
        self.calendarString = clock.calendar.calendarCode.localizedName
        let (dateString, timeString, dateComponents) = clock.dateStringTimeStringDateComponents(now: now, location: location)
        self.dateString = dateString
        self.timeString = timeString
        
        self.daysPerWeek = clock.daysPerWeek
        
        self.veryShortStandaloneWeekdaySymbols = clock.veryShortStandaloneWeekdaySymbols(localeIdentifier: clock.localeIdentifier)
        
        self.weekendDays = clock.weekendDays(location: location)
        
        self.day = dateComponents.day ?? 1
        self.weekday = dateComponents.weekday ?? 1
        if clock.calendar.supports(calendarComponent: .month) {
            self.daysInMonth = clock.calendar.daysInMonth(for: now) ?? 1
            self.supportsMonths = true
        } else {
            self.daysInMonth = 1
            self.supportsMonths = false
        }
        
        assert(!(location.type != .earthLocation && self.supportsMonths))


            self.hour   = dateComponents.hour
            self.minute = dateComponents.minute
            self.second = dateComponents.second
            self.fractionalHour = dateComponents.solarHours
            self.dayHalf = dateComponents.dayHalf

        self.transitionType = clock.calendar.transitionType
        
        self.calendarCode = clock.calendar.calendarCode

        let month = dateComponents.month ?? 0

        let startOfDay: Date = clock.startOfDay(date: now, location: location)
        let startOfNextDay: Date   = clock.startOfNextDay(date: now, location: location)
        let clockEvents = clock.events(startDate: startOfDay, endDate: startOfNextDay, locationData: location, usesDeviceLocation: usesDeviceLocation)
        self.dateEvents = isForComplications ? [] : clockEvents.dateEvents
        self.timeEvents = isForComplications ? [] : clockEvents.timeEvents

        self.startOfDay               = startOfDay
        self.startOfNextDay           = startOfNextDay
        self.regionCode               = location.regionCode
   
        if clock.calendar is ASACalendarWithBlankMonths {
            let cal = clock.calendar as! ASACalendarWithBlankMonths
            self.monthIsBlank = cal.blankMonths.contains(month)
            self.blankWeekdaySymbol = cal.blankWeekdaySymbol
        } else {
            self.monthIsBlank = false
            self.blankWeekdaySymbol = nil
        }
        
        self.supportsExternalEvents = clock.supportsExternalEvents(location: location, usesDeviceLocation: usesDeviceLocation)
        
        if self.supportsMonths {
            let (weekdayItems, dayItems) = clock.miniCalendarData(day: self.day, weekday: self.weekday, daysInMonth: self.daysInMonth, monthIsBlank: self.monthIsBlank, blankWeekdaySymbol: blankWeekdaySymbol, location: location)
            self.miniCalendarWeekdayItems = weekdayItems
            self.miniCalendarDayItems = dayItems
        } else {
            self.miniCalendarWeekdayItems = nil
            self.miniCalendarDayItems = nil
        }
        self.characterDirection = Locale.Language(identifier: clock.localeIdentifier).characterDirection
        
        self.calendarType = self.calendarCode.type
    } // init(clock:  ASAClock, now:  Date, isForComplications: Bool)
} // struct ASAProcessedClock
