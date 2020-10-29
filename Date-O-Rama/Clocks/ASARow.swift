//
//  ASARow.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit
import CoreLocation

let UUID_KEY:  String                 = "UUID"
let LOCALE_KEY:  String               = "locale"
let CALENDAR_KEY:  String             = "calendar"
let MAJOR_DATE_FORMAT_KEY:  String    = "majorDateFormat"
let DATE_GEEK_FORMAT_KEY:  String     = "geekFormat"
let MAJOR_TIME_FORMAT_KEY:  String    = "majorTimeFormat"
let TIME_GEEK_FORMAT_KEY:  String     = "timeGeekFormat"


// MARK: -

class ASARow: ASALocatedObject {
    @Published var calendar:  ASACalendar = ASAAppleCalendar(calendarCode: .Gregorian) {
        didSet {
            if !self.calendar.supportedMajorDateFormats.contains(self.majorDateFormat) {
                self.majorDateFormat = self.calendar.defaultMajorDateFormat
            }
            if !self.calendar.supportsLocations && !self.calendar.supportsTimeZones {
                self.usesDeviceLocation = false
            }
        } // didSet
    } // var calendar

    @Published var majorDateFormat:  ASAMajorDateFormat = .full {
        didSet {
            if dateGeekFormat.isEmpty {
                self.dateGeekFormat = self.calendar.defaultDateGeekCode(majorDateFormat: self.majorDateFormat)
            }
        } // didset
    } // var majorDateFormat
    @Published var dateGeekFormat:  String = "eMMMdy"
    
    @Published var majorTimeFormat:  ASAMajorTimeFormat = .full {
        didSet {
            if timeGeekFormat.isEmpty {
                self.timeGeekFormat = self.calendar.defaultTimeGeekCode(majorTimeFormat: self.majorTimeFormat)
            }
        } // didset
    } // var majorDateFormat
    @Published var timeGeekFormat:  String = "HHmmss"

    
    // MARK: -
        
    public func dictionary() -> Dictionary<String, Any> {
//        debugPrint(#file, #function)
        var result = [
            UUID_KEY:  uuid.uuidString,
            LOCALE_KEY:  localeIdentifier,
            CALENDAR_KEY:  calendar.calendarCode.rawValue,
            MAJOR_DATE_FORMAT_KEY:  majorDateFormat.rawValue ,
            DATE_GEEK_FORMAT_KEY:  dateGeekFormat,
            MAJOR_TIME_FORMAT_KEY:  majorTimeFormat.rawValue ,
            TIME_GEEK_FORMAT_KEY:  timeGeekFormat,
            TIME_ZONE_KEY:  effectiveTimeZone.identifier,
            USES_DEVICE_LOCATION_KEY:  self.usesDeviceLocation
            ] as [String : Any]
        
        if location != nil {
            result[LATITUDE_KEY] = self.location!.coordinate.latitude
            result[LONGITUDE_KEY] = self.location!.coordinate.longitude
            result[ALTITUDE_KEY] = self.location?.altitude
            result[HORIZONTAL_ACCURACY_KEY] = self.location?.horizontalAccuracy
            result[VERTICAL_ACCURACY_KEY] = self.location?.verticalAccuracy
        }
        
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
    } // public func dictionary() -> Dictionary<String, Any>
    
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
            let code = ASACalendarCode(rawValue: calendarCode! ) ?? ASACalendarCode.Gregorian
            newRow.calendar = ASACalendarFactory.calendar(code: code)!
        }
        
        let majorDateFormat = dictionary[MAJOR_DATE_FORMAT_KEY] as? String
        if majorDateFormat != nil {
            newRow.majorDateFormat = ASAMajorDateFormat(rawValue: majorDateFormat! )!
        }
        
        let dateGeekFormat = dictionary[DATE_GEEK_FORMAT_KEY] as? String
        if dateGeekFormat != nil {
            newRow.dateGeekFormat = dateGeekFormat!
        }
        
        let majorTimeFormat = dictionary[MAJOR_TIME_FORMAT_KEY] as? String
        if majorTimeFormat != nil {
            newRow.majorTimeFormat = ASAMajorTimeFormat(rawValue: majorTimeFormat! )!
        }
        
        let timeGeekFormat = dictionary[TIME_GEEK_FORMAT_KEY] as? String
        if timeGeekFormat != nil {
            newRow.timeGeekFormat = timeGeekFormat!
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
    
    class func generic() -> ASARow {
        let temp = ASARow()
        temp.calendar = ASAAppleCalendar(calendarCode: .Gregorian)
        temp.localeIdentifier = ""
        temp.majorDateFormat = .full
        temp.timeZone = TimeZone.autoupdatingCurrent
        return temp
    } // func generic() -> ASARow
    
    class func test() -> ASARow {
        let temp = ASARow()
        temp.calendar = ASAAppleCalendar(calendarCode: .Gregorian)
        temp.localeIdentifier = "en_US"
        temp.majorDateFormat = .localizedLDML
        temp.dateGeekFormat = "eeeyMMMd"
        temp.timeZone = TimeZone.autoupdatingCurrent
        return temp
    } // func generic() -> ASARow
    
    func copy() -> ASARow {
        let tempRow = ASARow()
        tempRow.calendar = ASACalendarFactory.calendar(code: self.calendar.calendarCode)!
        tempRow.localeIdentifier = self.localeIdentifier
        tempRow.majorDateFormat = self.majorDateFormat
        tempRow.dateGeekFormat = self.dateGeekFormat
        tempRow.timeZone = TimeZone(identifier: self.effectiveTimeZone.identifier)!
        return tempRow
    } // func copy() -> ASARow
} // class ASARow: NSObject


// MARK :-

extension ASARow {
    public func dateString(now:  Date) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: self.majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: .none, timeGeekFormat: "", location: self.location, timeZone: self.effectiveTimeZone)
    } // func dateTimeString(now:  Date) -> String

    public func dateTimeString(now:  Date) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: self.majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: self.majorTimeFormat, timeGeekFormat: self.timeGeekFormat, location: self.location, timeZone: self.effectiveTimeZone)
    } // func dateTimeString(now:  Date) -> String

//    public func dateTimeString(now:  Date, LDMLString:  String) -> String {
//        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, LDMLString: LDMLString, location: self.location, timeZone: self.effectiveTimeZone)
//    } // func dateTimeString(now:  Date, LDMLString:  String) -> String

//    public func LDMLDetails() -> Array<ASALDMLDetail> {
//        return self.calendar.LDMLDetails
//    } // public func LDMLDetails() -> Array<ASADetail>
    
    func startOfDay(date:  Date) -> Date {
        return self.calendar.startOfDay(for: date, location: self.location, timeZone: self.effectiveTimeZone)
    } // func startODay(date:  Date) -> Date

    func startOfNextDay(date:  Date) -> Date {
        return self.calendar.startOfNextDay(date: date, location: self.location, timeZone: self.effectiveTimeZone)
    } // func startOfNextDay(now:  Date) -> Date

    public func timeString(now:  Date) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: .none, dateGeekFormat: "", majorTimeFormat: self.majorTimeFormat, timeGeekFormat: self.timeGeekFormat, location: self.location, timeZone: self.effectiveTimeZone)
    } // func timeString(now:  Date
    
    public func supportsLocales() -> Bool {
        return self.calendar.supportsLocales
    } // func supportsLocales() -> Bool
} // extension ASARow

extension ASARow {
    public func shortenedDateTimeString(now:  Date) -> String {
        let majorDateFormat: ASAMajorDateFormat = self.majorDateFormat.shortened
        let majorTimeFormat: ASAMajorTimeFormat = self.majorTimeFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: majorTimeFormat, timeGeekFormat: self.timeGeekFormat, location: self.location, timeZone: self.effectiveTimeZone)
        return result
    } // func shortenedDateTimeString(now:  Date) -> String

    public func shortenedDateString(now:  Date) -> String {
        let majorDateFormat: ASAMajorDateFormat = self.majorDateFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: .none, timeGeekFormat: "", location: self.location, timeZone: self.effectiveTimeZone)
        return result
    } // func shortenedDateString(now:  Date) -> String

    public func watchShortenedDateString(now:  Date) -> String {
        let majorDateFormat: ASAMajorDateFormat = self.majorDateFormat.watchShortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: .none, timeGeekFormat: "", location: self.location, timeZone: self.effectiveTimeZone)
        return result
    } //

    public func watchShortenedTimeString(now:  Date) -> String {
        let majorTimeFormat: ASAMajorTimeFormat = self.majorTimeFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: .none, dateGeekFormat: "", majorTimeFormat: majorTimeFormat, timeGeekFormat: self.timeGeekFormat, location: self.location, timeZone: self.effectiveTimeZone)
        return result
    } // func shortenedTimeString(now:  Date) -> String
} // extension ASARow
