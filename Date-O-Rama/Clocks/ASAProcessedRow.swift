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
    var emojiString:  String
    var usesDeviceLocation:  Bool
    var locationString:  String
    var canSplitTimeFromDate:  Bool
    var supportsTimeZones:  Bool
    var supportsLocations:  Bool

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
        self.supportsLocations = row.calendar.supportsLocations
        if self.supportsLocations {
            self.emojiString = row.emoji(date:  now)
            self.usesDeviceLocation = row.usesDeviceLocation
            var locationString = ""
            if row.locationData.name == nil && row.locationData.locality == nil && row.locationData.country == nil {
                if row.location != nil {
                    locationString = row.location!.humanInterfaceRepresentation
                }
            } else {
                #if os(watchOS)
                locationString = row.locationData.shortFormattedOneLineAddress
                #else
                locationString = row.locationData.formattedOneLineAddress
                #endif
            }
            self.locationString = locationString
        } else {
            self.emojiString = "🇺🇳🕛"
            self.usesDeviceLocation = false
            self.locationString = NSLocalizedString("NO_PLACE_NAME", comment: "")
        }
        self.supportsTimeZones = row.calendar.supportsTimeZones
    }
} // struct ASAProcessedRow

extension ASAProcessedRow {
    var latitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.row.locationData.location?.coordinate.latitude ?? 0.0
            } else {
                return 0.0
            }
        } // get
    } // var latitude

    var longitude:  CLLocationDegrees {
        get {
            if self.supportsLocations {
                return self.row.locationData.location?.coordinate.longitude ?? 0.0
            } else {
                 return 0.0
            }
        } // get
    } // var longitude
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
