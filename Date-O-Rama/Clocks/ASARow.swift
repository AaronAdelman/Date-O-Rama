//
//  ASARow.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit
import CoreLocation

let UUID_KEY:  String        = "UUID"
let LOCALE_KEY:  String      = "locale"
let CALENDAR_KEY:  String    = "calendar"
let DATE_FORMAT_KEY:  String = "dateFormat"
let TIME_FORMAT_KEY:  String = "timeFormat"


// MARK: -

class ASARow: ASALocatedObject {
    @Published var calendar:  ASACalendar = ASAAppleCalendar(calendarCode: .Gregorian) {
        didSet {
            if !self.calendar.supportedDateFormats.contains(self.dateFormat) {
                self.dateFormat = self.calendar.defaultDateFormat
            }
            if !self.calendar.supportsLocations {
                self.usesDeviceLocation = false

                if !self.calendar.supportsTimeZones {
                    self.locationData = ASALocationData.NullIsland
                    self.usesDeviceLocation = false
                }
            }
        } // didSet
    } // var calendar

    @Published var dateFormat:  ASADateFormat = .full {
        didSet {
        } // didset
    } // var dateFormat

    @Published var timeFormat:  ASATimeFormat = .medium {
        didSet {
        } // didset
    } // var timeFormat

    
    // MARK: -
        
    public var dictionary:  Dictionary<String, Any> {
        //        debugPrint(#file, #function)
        var result = [
            UUID_KEY:  uuid.uuidString,
            LOCALE_KEY:  localeIdentifier,
            CALENDAR_KEY:  calendar.calendarCode.rawValue,
            DATE_FORMAT_KEY:  dateFormat.rawValue ,
            TIME_FORMAT_KEY:  timeFormat.rawValue ,
            TIME_ZONE_KEY:  timeZone.identifier,
            USES_DEVICE_LOCATION_KEY:  self.usesDeviceLocation
        ] as [String : Any]
        
        result[LATITUDE_KEY] = self.location.coordinate.latitude
        result[LONGITUDE_KEY] = self.location.coordinate.longitude
        result[ALTITUDE_KEY] = self.location.altitude
        result[HORIZONTAL_ACCURACY_KEY] = self.location.horizontalAccuracy
        result[VERTICAL_ACCURACY_KEY] = self.location.verticalAccuracy

        if self.locationData.name != nil {
            result[PLACE_NAME_KEY] = self.locationData.name
        }
        if self.locationData.locality != nil {
            result[LOCALITY_KEY] = self.locationData.locality
        }
        if self.locationData.country != nil {
            result[COUNTRY_KEY] = self.locationData.country
        }
        if self.locationData.ISOCountryCode != nil {
            result[ISO_COUNTRY_CODE_KEY] = self.locationData.ISOCountryCode
        }
        
        if self.locationData.postalCode != nil {
            result[POSTAL_CODE_KEY] = self.locationData.postalCode
        }
        
        if self.locationData.administrativeArea != nil {
            result[ADMINISTRATIVE_AREA_KEY] = self.locationData.administrativeArea
        }

        if self.locationData.subAdministrativeArea != nil {
            result[SUBADMINISTRATIVE_AREA_KEY] = self.locationData.subAdministrativeArea
        }

        if self.locationData.subLocality != nil {
            result[SUBLOCALITY_KEY] = self.locationData.subLocality
        }

        if self.locationData.thoroughfare != nil {
            result[THOROUGHFARE_KEY] = self.locationData.thoroughfare
        }

        if self.locationData.subThoroughfare != nil {
            result[SUBTHOROUGHFARE_KEY] = self.locationData.subThoroughfare
        }

        //        debugPrint(#file, #function, result)
        return result
    } // var dictionary:  Dictionary<String, Any>
    
    public class func newRow(dictionary:  Dictionary<String, Any>) -> ASARow {
        //        debugPrint(#file, #function, dictionary)
        
        let newRow = ASARow()
        
        let UUIDString = dictionary[UUID_KEY] as? String
        if UUIDString != nil {
            let tempUUID: UUID? = UUID(uuidString: UUIDString!)
            if tempUUID != nil {
                newRow.uuid = tempUUID!
            } else {
                newRow.uuid = UUID()
            }
        } else {
            newRow.uuid = UUID()
        }
        
        let localeIdentifier = dictionary[LOCALE_KEY] as? String
        if localeIdentifier != nil {
            newRow.localeIdentifier = localeIdentifier!
        }

        let calendarCode = dictionary[CALENDAR_KEY] as? String
        if calendarCode != nil {
            let code = ASACalendarCode(rawValue: calendarCode!)
            if code == nil {
                newRow.calendar = ASACalendarFactory.calendar(code: .Gregorian)!
            } else {
                newRow.calendar = ASACalendarFactory.calendar(code: code!)!
            }
        }
        
        let dateFormat = dictionary[DATE_FORMAT_KEY] as? String
        if dateFormat != nil {
            newRow.dateFormat = ASADateFormat(rawValue: dateFormat! )!
        }

        let timeFormat = dictionary[TIME_FORMAT_KEY] as? String
        if timeFormat != nil {
            newRow.timeFormat = ASATimeFormat(rawValue: timeFormat! ) ?? .medium
        }

        let timeZoneIdentifier = dictionary[TIME_ZONE_KEY] as? String
        if timeZoneIdentifier != nil {
            newRow.timeZone = TimeZone(identifier: timeZoneIdentifier!)!
        }
        
        let usesDeviceLocation = dictionary[USES_DEVICE_LOCATION_KEY] as? Bool
        let latitude = dictionary[LATITUDE_KEY] as? Double
        let longitude = dictionary[LONGITUDE_KEY] as? Double
        let altitude = dictionary[ALTITUDE_KEY] as? Double
        let horizontalAccuracy = dictionary[HORIZONTAL_ACCURACY_KEY] as? Double
        let verticalAccuracy = dictionary[VERTICAL_ACCURACY_KEY] as? Double
        newRow.usesDeviceLocation = usesDeviceLocation ?? true
        if latitude != nil && longitude != nil {
            newRow.location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), altitude: altitude ?? 0.0, horizontalAccuracy: horizontalAccuracy ?? 0.0, verticalAccuracy: verticalAccuracy ?? 0.0, timestamp: Date())
        }
        newRow.locationData.name = dictionary[PLACE_NAME_KEY] as? String
        newRow.locationData.locality = dictionary[LOCALITY_KEY] as? String
        newRow.locationData.country = dictionary[COUNTRY_KEY] as? String
        newRow.locationData.ISOCountryCode = dictionary[ISO_COUNTRY_CODE_KEY] as? String
        
        newRow.locationData.postalCode = dictionary[POSTAL_CODE_KEY] as? String
        newRow.locationData.administrativeArea = dictionary[ADMINISTRATIVE_AREA_KEY] as? String
        newRow.locationData.subAdministrativeArea = dictionary[SUBADMINISTRATIVE_AREA_KEY] as? String
        newRow.locationData.subLocality = dictionary[SUBLOCALITY_KEY] as? String
        newRow.locationData.thoroughfare = dictionary[THOROUGHFARE_KEY] as? String
        newRow.locationData.subThoroughfare = dictionary[SUBTHOROUGHFARE_KEY] as? String
        
        return newRow
    } // func newRowFromDictionary(dictionary:  Dictionary<String, String?>) -> ASARow
    
    static var generic:  ASARow {
        let temp = ASARow()
        temp.calendar = ASAAppleCalendar(calendarCode: .Gregorian)
        temp.localeIdentifier = ""
        temp.dateFormat = .full
        return temp
    } // static var generic:  ASARow
} // class ASARow


// MARK:  -

extension ASARow {
    public func dateString(now:  Date) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: self.dateFormat, timeFormat: .none, locationData: self.locationData)
    } // func dateTimeString(now:  Date) -> String

    public func dateTimeString(now:  Date) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: self.dateFormat, timeFormat: self.timeFormat, locationData: self.locationData)
    } // func dateTimeString(now:  Date) -> String
    
    func startOfDay(date:  Date) -> Date {
        return self.calendar.startOfDay(for: date, locationData: self.locationData)
    } // func startODay(date:  Date) -> Date

    func startOfNextDay(date:  Date) -> Date {
        return self.calendar.startOfNextDay(date: date, locationData: self.locationData)
    } // func startOfNextDay(now:  Date) -> Date

    public func timeString(now:  Date) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .none, timeFormat: self.timeFormat, locationData: self.locationData)
    } // func timeString(now:  Date) -> String
    
    public var supportsLocales:  Bool {
        return self.calendar.supportsLocales
    } // var supportsLocales:  Bool

    public func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents {
        self.calendar.dateComponents(components, from: date, locationData: self.locationData)
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocationData) -> ASADateComponents
} // extension ASARow


// MARK:  -

extension ASARow {
    public func shortenedDateTimeString(now:  Date) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.shortened
        let timeFormat: ASATimeFormat = self.timeFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: self.locationData)
        return result
    } // func shortenedDateTimeString(now:  Date) -> String

    public func shortenedDateString(now:  Date) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: self.locationData)
        return result
    } // func shortenedDateString(now:  Date) -> String

    public func watchShortenedDateString(now:  Date) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.watchShortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: self.locationData)
        return result
    } // func watchShortenedDateString(now:  Date) -> String

    public func watchShortenedTimeString(now:  Date) -> String {
        let timeFormat: ASATimeFormat = self.timeFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: self.locationData)
        return result
    } // func watchShortenedTimeString(now:  Date) -> String
} // extension ASARow
