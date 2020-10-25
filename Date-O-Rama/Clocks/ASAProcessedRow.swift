//
//  ASAProcessedRow.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 06/10/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

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
            self.dateString = row.dateString(now: now)
            #if os(watchOS)
            self.timeString = row.shortenedTimeString(now: now)
            #else
            self.timeString = row.timeString(now: now)
            #endif
        } else {
            self.dateString = row.dateTimeString(now: now)
            self.timeString = ""
        }
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
        self.supportsTimeZones = row.calendar.supportsTimeZones
        self.supportsLocations = row.calendar.supportsLocations
    }
} // struct ASAProcessedRow


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
//            var locationString = ""
//            if row.locationData.name == nil && row.locationData.locality == nil && row.locationData.country == nil {
//                if row.location != nil {
//                    locationString = row.location!.humanInterfaceRepresentation
//                }
//            } else {
//                locationString = row.locationData.formattedOneLineAddress
//            }
//            let processedRow = ASAProcessedRow(row: row, calendarString: row.calendar.calendarCode.localizedName(), dateString: row.dateString(now: now), timeString: row.timeString(now: now), emojiString: row.emoji(date:  now), usesDeviceLocation: row.usesDeviceLocation, locationString: locationString, canSplitTimeFromDate: row.calendar.canSplitTimeFromDate, supportsTimeZones: row.calendar.supportsTimeZones, supportsLocations: row.calendar.supportsLocations)
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
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.longitude ?? 0.0 < $1.row.locationData.location?.coordinate.longitude ?? 0.0}

        return processedRows
    } // func processedWestToEast(now:  Date) -> Array<ASAProcessedRow>

    func processedEastToWest(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.longitude ?? 0.0 > $1.row.locationData.location?.coordinate.longitude ?? 0.0}

        return processedRows
    } // func processedEastToWest(now:  Date) -> Array<ASAProcessedRow>

    func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.latitude ?? 0.0 > $1.row.locationData.location?.coordinate.latitude ?? 0.0}

        return processedRows
    } // func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow>

    func processedSouthToNorth(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.latitude ?? 0.0 < $1.row.locationData.location?.coordinate.latitude ?? 0.0}

        return processedRows
    } // func processedSouthToNorth(now:  Date) -> Array<ASAProcessedRow>
} // extension Array where Element == ASARow
