//
//  ASAProcessedClock.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

struct ASAProcessedClock {
    var clock:  ASAClock
    var calendarString:  String
    var dateString:  String
    var timeString:  String?
    var flagEmojiString:  String
    var timeZoneString:  String

    var usesDeviceLocation:  Bool
    var locationString:  String
    var canSplitTimeFromDate:  Bool
    var supportsTimeZones:  Bool
    var supportsLocations:  Bool
    var supportsTimes:  Bool

    var daysPerWeek:  Int?
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

    var veryShortStandaloneWeekdaySymbols:  Array<String>

    var month:  Int

    var events:  Array<ASAEventCompatible>

    var startOfDay:  Date
    var startOfNextDay:  Date
    
    var weekendDays: Array<Int>
    var regionCode: String?
    
    var miniCalendarNumberFormat: ASAMiniCalendarNumberFormat

    init(clock:  ASAClock, now:  Date, isForComplications: Bool) {
        self.clock = clock
        self.calendarString = clock.calendar.calendarCode.localizedName
        let (dateString, timeString, dateComponents) = clock.dateStringTimeStringDateComponents(now: now)
        self.canSplitTimeFromDate = clock.calendar.canSplitTimeFromDate
        self.dateString = dateString
        self.timeString = timeString
        let timeZone = clock.locationData.timeZone
        #if os(watchOS)
        self.timeZoneString = timeZone.extremeAbbreviation(for: now)
        #else
        self.timeZoneString = timeZone.abbreviation(for:  now) ?? ""
        #endif
        self.supportsLocations = clock.calendar.supportsLocations
        if self.supportsLocations {
            self.flagEmojiString = (clock.locationData.regionCode ?? "").flag
            self.usesDeviceLocation = clock.usesDeviceLocation
            var locationString = ""
            if clock.locationData.name == nil && clock.locationData.locality == nil && clock.locationData.country == nil {
                locationString = clock.locationData.location.humanInterfaceRepresentation
            } else {
                #if os(watchOS)
                locationString = clock.locationData.shortFormattedOneLineAddress
                #else
                locationString = clock.locationData.formattedOneLineAddress
                #endif
            }
            self.locationString = locationString
        } else {
            self.flagEmojiString = "🇺🇳"
            self.usesDeviceLocation = false
            self.locationString = NSLocalizedString("NO_PLACE_NAME", comment: "")
        }
        self.supportsTimeZones = clock.calendar.supportsTimeZones

        self.daysPerWeek = clock.daysPerWeek
        self.day = dateComponents.day ?? 1
        self.weekday = dateComponents.weekday ?? 1
        if clock.calendar.supports(calendarComponent: .month) {
            self.daysInMonth = clock.calendar.maximumValue(of: .day, in: .month, for: now) ?? 1
            self.supportsMonths = true
        } else {
            self.daysInMonth = 1
            self.supportsMonths = false
        }

        self.hour   = dateComponents.hour
        self.minute = dateComponents.minute
        self.second = dateComponents.second
        self.fractionalHour = dateComponents.solarHours
        self.dayHalf = dateComponents.dayHalf

        self.transitionType = clock.calendar.transitionType

        if clock.localeIdentifier == "" {
            self.localeIdentifier = Locale.current.identifier
        } else {
            self.localeIdentifier = clock.localeIdentifier
        }
        self.calendarCode = clock.calendar.calendarCode

        self.calendarType = clock.calendar.calendarCode.type
        self.supportsTimes = clock.calendar.supportsTimes

        self.veryShortStandaloneWeekdaySymbols = clock.calendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: clock.localeIdentifier)

        self.month = dateComponents.month ?? 0

        let startOfDay: Date = clock.startOfDay(date: now)
        let startOfNextDay: Date   = clock.startOfNextDay(date: now)
        self.events = isForComplications ? [] : clock.events(startDate: startOfDay, endDate: startOfNextDay)
        self.startOfDay = startOfDay
        self.startOfNextDay   = startOfNextDay
        self.weekendDays = clock.weekendDays
        self.regionCode = clock.locationData.regionCode
        self.miniCalendarNumberFormat = clock.miniCalendarNumberFormat
    } // init(row:  ASARow, now:  Date)
} // struct ASAProcessedClock


// MARK:  -

extension ASAProcessedClock {
    var latitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.clock.locationData.location.coordinate.latitude 
            } else {
                return 0.0
            }
        } // get
    } // var latitude

    var longitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.clock.locationData.location.coordinate.longitude 
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


// MARK:  -

extension Array where Element == ASAClock {
    func processed(now:  Date) -> Array<ASAProcessedClock> {
        var result:  Array<ASAProcessedClock> = []

        for row in self {
            let processedRow = ASAProcessedClock(clock: row, now: now, isForComplications: false)
            result.append(processedRow)
        }

        return result
    } // func processed(now:  Date) -> Array<ASAProcessedClock>

    func processedByFormattedDate(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>> {
        var result:  Dictionary<String, Array<ASAProcessedClock>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key = processedRow.dateString
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        //        debugPrint(#file, #function, result)
        //        debugPrint("-----------")

        return result
    } // func processedByFormattedDate(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>>

    func processedRowsByCalendar(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>> {
        var result:  Dictionary<String, Array<ASAProcessedClock>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key = processedRow.calendarString
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByCalendar(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>>

    func processedRowsByPlaceName(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>> {
        var result:  Dictionary<String, Array<ASAProcessedClock>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key = processedRow.locationString
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByPlaceName(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>>

    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }

    func processedRowsByCountry(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>> {
        var result:  Dictionary<String, Array<ASAProcessedClock>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key:  String = {
                if processedRow.supportsLocations == false {
                return noCountryString()
            }
                return processedRow.clock.locationData.country ?? noCountryString()
            }()
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByCountry(now:  Date) -> Dictionary<String, Array<ASAProcessedClock>>

    func processedRowsByTimeZone(now:  Date) -> Dictionary<Int, Array<ASAProcessedClock>> {
        var result:  Dictionary<Int, Array<ASAProcessedClock>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key = processedRow.clock.locationData.timeZone.secondsFromGMT(for: now) 
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByTimeZone(now:  Date) -> Dictionary<Int, Array<ASAProcessedClock>>

    func processedWestToEast(now:  Date) -> Array<ASAProcessedClock> {
        let processedRows = self.processed(now: now).sorted {
            $0.longitude < $1.longitude
        }

        return processedRows
    } // func processedWestToEast(now:  Date) -> Array<ASAProcessedClock>

    func processedEastToWest(now:  Date) -> Array<ASAProcessedClock> {
        let processedRows = self.processed(now: now).sorted {
            $0.longitude > $1.longitude
        }

        return processedRows
    } // func processedEastToWest(now:  Date) -> Array<ASAProcessedClock>

    func processedNorthToSouth(now:  Date) -> Array<ASAProcessedClock> {
        let processedRows = self.processed(now: now).sorted {
            $0.latitude > $1.latitude
        }

        return processedRows
    } // func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow>

    func processedSouthToNorth(now:  Date) -> Array<ASAProcessedClock> {
        let processedRows = self.processed(now: now).sorted {
            $0.latitude < $1.latitude
        }

        return processedRows
    } // func processedSouthToNorth(now:  Date) -> Array<ASAProcessedClock>
} // extension Array where Element == ASARow


// MARK: -

extension Array where Element == ASAProcessedClock {
    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }

    func sorted(_ groupingOption:  ASAClocksViewGroupingOption) -> Array<ASAProcessedClock> {
        switch groupingOption {
        case .eastToWest:
            return self.sorted {
                $0.longitude > $1.longitude
            }

        case .westToEast:
            return self.sorted {
                $0.longitude < $1.longitude
            }

        case .northToSouth:
            return self.sorted {
                $0.latitude > $1.latitude
            }

        case .southToNorth:
            return self.sorted {
                $0.latitude < $1.latitude
            }

        case .byFormattedDate:
            return self.sorted {
                $0.dateString < $1.dateString
            }

        case .byCalendar:
            return self.sorted {
                $0.calendarString < $1.calendarString
            }

        case .byPlaceName:
            return self.sorted {
                $0.locationString < $1.locationString
            }

        case .byCountry:
            return self.sorted {
                $0.clock.locationData.country ?? noCountryString() < $1.clock.locationData.country ?? noCountryString()
            }

        case .byTimeZoneWestToEast:
            return self.sorted {
                $0.clock.locationData.timeZone.secondsFromGMT() < $1.clock.locationData.timeZone.secondsFromGMT() 
            }
        case .byTimeZoneEastToWest:
            return self.sorted {
                $0.clock.locationData.timeZone.secondsFromGMT() > $1.clock.locationData.timeZone.secondsFromGMT() 
            }
        } // switch groupingOption
    } // func sorted(_ groupingOption:  ASAClocksViewGroupingOption, now:  Date) -> Array<ASAProcessedClock>
}
