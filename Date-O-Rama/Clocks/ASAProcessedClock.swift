//
//  ASAProcessedClock.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation
import FrenchRepublicanCalendarCore

struct ASAProcessedClock {
    var clock:  ASAClock
    var calendarString:  String
    var dateString:  String
    var timeString:  String?
//    var flagEmojiString:  String
//    var timeZoneString:  String

//    var locationString:  String
    var canSplitTimeFromDate:  Bool
//    var supportsTimeZones:  Bool
    var supportsLocations:  Bool
    var supportsTimes:  Bool

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

    var localeIdentifier:  String
    var calendarCode:  ASACalendarCode

    var veryShortStandaloneWeekdaySymbols:  Array<String>?

    var month:  Int

    var dateEvents:  Array<ASAEventCompatible>
    var timeEvents:  Array<ASAEventCompatible>
    
    var startOfDay:  Date
    var startOfNextDay:  Date
    
    var weekendDays: Array<Int>?
    var regionCode: String?
    
    var miniCalendarNumberFormat: ASAMiniCalendarNumberFormat
    
    var monthIsBlank: Bool
    var blankWeekdaySymbol: String?
    var timeFormat: ASATimeFormat
    
    var location: ASALocation
    var usesDeviceLocation: Bool
    
    var supportsExternalEvents: Bool

    init(clock:  ASAClock, now:  Date, isForComplications: Bool, location: ASALocation, usesDeviceLocation: Bool) {
        self.clock = clock
        self.location = location
        self.usesDeviceLocation = usesDeviceLocation
        self.calendarString = clock.calendar.calendarCode.localizedName
        let (dateString, timeString, dateComponents) = clock.dateStringTimeStringDateComponents(now: now, location: location)
        self.canSplitTimeFromDate = clock.calendar.canSplitTimeFromDate
        self.dateString = dateString
        self.timeString = timeString
        let timeZone = location.timeZone
//        #if os(watchOS)
//        self.timeZoneString = timeZone.extremeAbbreviation(for: now)
//        #else
//        self.timeZoneString = timeZone.abbreviation(for:  now) ?? ""
//        #endif
        self.supportsLocations = clock.calendar.supportsLocations
//        if self.supportsLocations {
//            self.flagEmojiString = location.flag
////            self.usesDeviceLocation = clock.usesDeviceLocation
//            var locationString = ""
//            if location.name == nil && location.locality == nil && location.country == nil {
//                locationString = location.location.humanInterfaceRepresentation
//            } else {
//                #if os(watchOS)
//                locationString = location.shortFormattedOneLineAddress
//                #else
//                locationString = location.formattedOneLineAddress
//                #endif
//            }
//            self.locationString = locationString
//        } else {
//            self.flagEmojiString = "🇺🇳"
////            self.usesDeviceLocation = false
//            self.locationString = NSLocalizedString("NO_PLACE_NAME", comment: "")
//        }
//        self.supportsTimeZones = clock.calendar.supportsTimeZones
        
        self.daysPerWeek = clock.daysPerWeek
        
        self.veryShortStandaloneWeekdaySymbols = clock.veryShortStandaloneWeekdaySymbols(localeIdentifier: clock.localeIdentifier)
        
        self.weekendDays = clock.weekendDays(location: location)
        
        self.day = dateComponents.day ?? 1
        self.weekday = dateComponents.weekday ?? 1
        if clock.calendar.supports(calendarComponent: .month) {
            self.daysInMonth = clock.calendar.maximumValue(of: .day, in: .month, for: now) ?? 1
            self.supportsMonths = true
        } else {
            self.daysInMonth = 1
            self.supportsMonths = false
        }
        
        assert(!(location.type != .EarthLocation && self.supportsMonths))

        if clock.timeFormat == .decimal {
            let decimalTime = DecimalTime(base: now, timeZone: timeZone)
            self.hour   = decimalTime.hour
            self.minute = decimalTime.minute
            self.second = decimalTime.second
        } else {
            self.hour   = dateComponents.hour
            self.minute = dateComponents.minute
            self.second = dateComponents.second
            self.fractionalHour = dateComponents.solarHours
            self.dayHalf = dateComponents.dayHalf
        }

        self.transitionType = clock.calendar.transitionType

        if clock.localeIdentifier == "" {
            self.localeIdentifier = Locale.current.identifier
        } else {
            self.localeIdentifier = clock.localeIdentifier
        }
        self.calendarCode = clock.calendar.calendarCode

        self.calendarType = clock.calendar.calendarCode.type
        self.supportsTimes = clock.calendar.supportsTimes

        self.month = dateComponents.month ?? 0

        let startOfDay: Date = clock.startOfDay(date: now, location: location)
        let startOfNextDay: Date   = clock.startOfNextDay(date: now, location: location)
        assert(startOfDay <= now)
        assert(now < startOfNextDay)
        let clockEvents = clock.events(startDate: startOfDay, endDate: startOfNextDay, locationData: location, usesDeviceLocation: usesDeviceLocation)
        self.dateEvents = isForComplications ? [] : clockEvents.dateEvents
        self.timeEvents = isForComplications ? [] : clockEvents.timeEvents

        self.startOfDay               = startOfDay
        self.startOfNextDay           = startOfNextDay
        self.regionCode               = location.regionCode
        self.miniCalendarNumberFormat = clock.miniCalendarNumberFormat
        
        if self.clock.calendar is ASACalendarSupportingBlankMonths {
            let cal = self.clock.calendar as! ASACalendarSupportingBlankMonths
            self.monthIsBlank = cal.blankMonths.contains(month)
            self.blankWeekdaySymbol = cal.blankWeekdaySymbol
        } else {
            self.monthIsBlank = false
            self.blankWeekdaySymbol = nil
        }
 
        self.timeFormat = clock.timeFormat
        
        self.supportsExternalEvents = clock.supportsExternalEvents(location: location, usesDeviceLocation: usesDeviceLocation)
    } // init(clock:  ASAClock, now:  Date, isForComplications: Bool)
} // struct ASAProcessedClock


// MARK:  -

extension ASAProcessedClock {
    var latitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.location.location.coordinate.latitude
            } else {
                return 0.0
            }
        } // get
    } // var latitude

    var longitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.location.location.coordinate.longitude
            } else {
                return 0.0
            }
        } // get
    } // var longitude

    var hasValidTime:  Bool {
        get {
            return self.hour != -1
        } // get
    } // var hasValidTime
} // extension ASAProcessedClock


// MARK: -

extension Array where Element == ASAProcessedClock {
    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }
    
//    var sortedByCalendar: Array<ASAProcessedClock> {
//        return self.sorted {
//            $0.calendarString < $1.calendarString
//        }
//    }
}
