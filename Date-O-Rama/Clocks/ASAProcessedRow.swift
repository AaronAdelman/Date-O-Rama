//
//  ASAProcessedRow.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

struct ASAProcessedRow {
    var row:  ASARow
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

    var daysPerWeek:  Int
    var day:  Int
    var weekday:  Int
    var daysInMonth:  Int
    var supportsMonths:  Bool

    var hour:  Int
    var minute:  Int
    var second:  Int

    var transitionType:  ASATransitionType
    var calendarType:  ASACalendarType

    var localeIdentifier:  String
    var calendarCode:  ASACalendarCode

    var veryShortStandaloneWeekdaySymbols:  Array<String>

    var month:  Int

    var events:  Array<ASAEventCompatible>

    init(row:  ASARow, now:  Date) {
        self.row = row
        self.calendarString = row.calendar.calendarCode.localizedName()
        self.canSplitTimeFromDate = row.calendar.canSplitTimeFromDate
        if self.canSplitTimeFromDate {
            #if os(watchOS)
            self.dateString = row.watchShortenedDateString(now: now)
            #else
            self.dateString = row.dateString(now: now)
            #endif
            #if os(watchOS)
            self.timeString = row.watchShortenedTimeString(now: now)
            #else
            self.timeString = row.timeString(now: now)
            #endif
        } else {
            self.dateString = row.dateTimeString(now: now)
            self.timeString = ""
        }
        self.timeZoneString = row.locationData.timeZone.abbreviation(for:  now) ?? ""
        self.supportsLocations = row.calendar.supportsLocations
        if self.supportsLocations {
            self.flagEmojiString = (row.locationData.ISOCountryCode ?? "").flag()
            self.usesDeviceLocation = row.usesDeviceLocation
            var locationString = ""
            if row.locationData.name == nil && row.locationData.locality == nil && row.locationData.country == nil {
                //                if row.location != nil {
                locationString = row.locationData.location.humanInterfaceRepresentation
                //                }
            } else {
                #if os(watchOS)
                locationString = row.locationData.shortFormattedOneLineAddress
                #else
                locationString = row.locationData.formattedOneLineAddress
                #endif
            }
            self.locationString = locationString
        } else {
            self.flagEmojiString = "🇺🇳"
            self.usesDeviceLocation = false
            self.locationString = NSLocalizedString("NO_PLACE_NAME", comment: "")
        }
        self.supportsTimeZones = row.calendar.supportsTimeZones

        let dateComponents = row.dateComponents([.day, .weekday, .hour, .minute, .second], from: now, locationData: row.locationData)

        self.daysPerWeek = 7 // TODO:  FIX THIS!
        self.day = dateComponents.day ?? 1
        self.weekday = dateComponents.weekday ?? 1
        if row.calendar.supports(calendarComponent: .month) {
            let rangeOfDaysInMonth = row.calendar.range(of: .day, in: .month, for: now)
            self.daysInMonth = rangeOfDaysInMonth?.count ?? 1
            self.supportsMonths = true
        } else {
            self.daysInMonth = 1
            self.supportsMonths = false
        }

        self.hour   = dateComponents.hour ?? 0
        self.minute = dateComponents.minute ?? 0
        self.second = dateComponents.second ?? 0

        self.transitionType = row.calendar.transitionType

        if row.localeIdentifier == "" {
            self.localeIdentifier = Locale.current.identifier
        } else {
            self.localeIdentifier = row.localeIdentifier
        }
        self.calendarCode = row.calendar.calendarCode

        self.calendarType = row.calendar.calendarCode.type
        self.supportsTimes = row.calendar.supportsTimes

        self.veryShortStandaloneWeekdaySymbols = row.calendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: row.localeIdentifier)

        self.month = dateComponents.month ?? 0

        self.events = row.events(for: now)
    } // init(row:  ASARow, now:  Date)
} // struct ASAProcessedRow


// MARK:  -

extension ASAProcessedRow {
    var latitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.row.locationData.location.coordinate.latitude 
            } else {
                return 0.0
            }
        } // get
    } // var latitude

    var longitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.row.locationData.location.coordinate.longitude 
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
} // extension ASAProcessedRow


// MARK:  -

struct ASAProcessedRowsDictionaryKey {
    var text:  String
    var emoji:  String?
} // struct ASAProcessedRowsDictionaryKey



// MARK:  -

extension Array where Element == ASARow {
    func processed(now:  Date) -> Array<ASAProcessedRow> {
        var result:  Array<ASAProcessedRow> = []

        for row in self {
            let processedRow = ASAProcessedRow(row: row, now: now)
            result.append(processedRow)
        }

        return result
    } // func processed(now:  Date) -> Array<ASAProcessedRow>

    func processedByFormattedDate(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
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
    } // func processedByFormattedDate(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByCalendar(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
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
    } // func processedRowsByCalendar(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByPlaceName(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
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
    } // func processedRowsByPlaceName(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }

    func processedRowsByCountry(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key:  String = {
                if processedRow.supportsLocations == false {
                return noCountryString()
            }
                return processedRow.row.locationData.country ?? noCountryString()
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
    } // func processedRowsByCountry(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByTimeZone(now:  Date) -> Dictionary<Int, Array<ASAProcessedRow>> {
        var result:  Dictionary<Int, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processed(now: now)

        for processedRow in processedRows {
            let key = processedRow.row.locationData.timeZone.secondsFromGMT(for: now) 
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByTimeZone(now:  Date) -> Dictionary<Int, Array<ASAProcessedRow>>

    func processedWestToEast(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {
            $0.longitude < $1.longitude
        }

        return processedRows
    } // func processedWestToEast(now:  Date) -> Array<ASAProcessedRow>

    func processedEastToWest(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {
            $0.longitude > $1.longitude
        }

        return processedRows
    } // func processedEastToWest(now:  Date) -> Array<ASAProcessedRow>

    func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {
            $0.latitude > $1.latitude
        }

        return processedRows
    } // func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow>

    func processedSouthToNorth(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {
            $0.latitude < $1.latitude
        }

        return processedRows
    } // func processedSouthToNorth(now:  Date) -> Array<ASAProcessedRow>
} // extension Array where Element == ASARow


// MARK: -

extension Array where Element == ASAProcessedRow {
    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }

    func sorted(_ groupingOption:  ASAClocksViewGroupingOption) -> Array<ASAProcessedRow> {
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
                $0.row.locationData.country ?? noCountryString() < $1.row.locationData.country ?? noCountryString()
            }

        case .byTimeZoneWestToEast:
            return self.sorted {
                $0.row.locationData.timeZone.secondsFromGMT() < $1.row.locationData.timeZone.secondsFromGMT() 
            }
        case .byTimeZoneEastToWest:
            return self.sorted {
                $0.row.locationData.timeZone.secondsFromGMT() > $1.row.locationData.timeZone.secondsFromGMT() 
            }
        } // switch groupingOption
    } // func sorted(_ groupingOption:  ASAClocksViewGroupingOption, now:  Date) -> Array<ASAProcessedRow>
}
