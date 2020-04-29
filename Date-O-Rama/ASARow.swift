//
//  ASARow.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit
import CoreLocation

let LOCALE_KEY:  String               = "locale"
let CALENDAR_KEY:  String             = "calendar"
let MAJOR_DATE_FORMAT_KEY:  String    = "majorDateFormat"
let DATE_GEEK_FORMAT_KEY:  String     = "geekFormat"
let TIME_ZONE_KEY:  String            = "timeZone"
let USES_DEVICE_LOCATION_KEY:  String = "usesDeviceLocation"
let LATITUDE_KEY:  String             = "latitude"
let LONGITUDE_KEY:  String            = "longitude"
let ALTITUDE_KEY:  String             = "altitude"
let HORIZONTAL_ACCURACY_KEY:  String  = "haccuracy"
let VERTICAL_ACCURACY_KEY:  String    = "vaccuracy"

let AUTOUPDATING_CURRENT_TIME_ZONE_VALUE = "*AUTOUPDATING*"
let DEVICE_LOCATION_VALUE = -1000000.0 // Something implausible for latitude and longitude and fairly unlikely for an altitude


// MARK: -

class ASARow: NSObject, ObservableObject, Identifiable {
    var uid = UUID()

    @Published var dummy = false
    
    @Published var calendar:  ASACalendar = ASAAppleCalendar(calendarCode: .Gregorian)
        
    @Published var localeIdentifier:  String = Locale.current.identifier
    
    @Published var majorDateFormat:  ASAMajorFormat = .full {
        didSet {
            if dateGeekFormat.isEmpty {
                self.dateGeekFormat = self.calendar.defaultDateGeekCode(majorDateFormat: self.majorDateFormat)
            }
        } // didset
    } // var majorDateFormat
    @Published var dateGeekFormat:  String = "eMMMdy"
    
    @Published var timeZone:  TimeZone = TimeZone.autoupdatingCurrent
    
    @Published var usesDeviceLocation:  Bool = true
    @Published var location:  CLLocation?
    @Published var placemark:  CLPlacemark?
    
    // MARK: -
    
    public func dictionary() -> Dictionary<String, Any> {
        var result = [
            LOCALE_KEY:  localeIdentifier,
            CALENDAR_KEY:  calendar.calendarCode.rawValue,
            MAJOR_DATE_FORMAT_KEY:  majorDateFormat.rawValue ,
            DATE_GEEK_FORMAT_KEY:  dateGeekFormat,
            TIME_ZONE_KEY:  timeZone == TimeZone.autoupdatingCurrent ? AUTOUPDATING_CURRENT_TIME_ZONE_VALUE : timeZone.identifier,
            USES_DEVICE_LOCATION_KEY:  self.usesDeviceLocation
            ] as [String : Any]
        
        if location != nil {
            result[LATITUDE_KEY] = self.location!.coordinate.latitude
            result[LONGITUDE_KEY] = self.location!.coordinate.longitude
            result[ALTITUDE_KEY] = self.location?.altitude
            result[HORIZONTAL_ACCURACY_KEY] = self.location?.horizontalAccuracy
            result[VERTICAL_ACCURACY_KEY] = self.location?.verticalAccuracy
        }
        
        return result
    } // public func dictionary() -> Dictionary<String, Any>
    
    public class func newRow(dictionary:  Dictionary<String, Any>) -> ASARow {
        let newRow = ASARow()
        
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
            newRow.majorDateFormat = ASAMajorFormat(rawValue: majorDateFormat! )!
        }
        
        let dateGeekFormat = dictionary[DATE_GEEK_FORMAT_KEY] as? String
        if dateGeekFormat != nil {
            newRow.dateGeekFormat = dateGeekFormat!
        }
        
        let timeZoneIdentifier = dictionary[TIME_ZONE_KEY] as? String
        if timeZoneIdentifier != nil {
            if timeZoneIdentifier! == AUTOUPDATING_CURRENT_TIME_ZONE_VALUE {
                newRow.timeZone = TimeZone.autoupdatingCurrent
            } else {
                newRow.timeZone = TimeZone(identifier: timeZoneIdentifier!)!
            }
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
    
    class func dummy() -> ASARow {
        let temp = ASARow()
        temp.dummy = true
        return temp
    } // func dummy() -> ASARow
    
    func copy() -> ASARow {
        let tempRow = ASARow()
        tempRow.calendar = ASACalendarFactory.calendar(code: self.calendar.calendarCode)!
        tempRow.localeIdentifier = self.localeIdentifier
        tempRow.majorDateFormat = self.majorDateFormat
        tempRow.dateGeekFormat = self.dateGeekFormat
        tempRow.timeZone = TimeZone(identifier: self.timeZone.identifier)!
        return tempRow
    } // func copy() -> ASARow
    
    
    //MARK: -
    
    public func dateString(now:  Date, defaultLocation:  CLLocation?) -> String {
        return self.calendar.dateString(now: now, localeIdentifier: self.localeIdentifier, majorDateFormat: self.majorDateFormat, dateGeekFormat: self.dateGeekFormat, majorTimeFormat: .medium, timeGeekFormat: "HH:mm:ss", location: defaultLocation, timeZone: self.timeZone)
    } // func dateString(now:  Date) -> String
    
    public func dateString(now:  Date, LDMLString:  String, defaultLocation:  CLLocation?) -> String {
        return self.calendar.dateString(now: now, localeIdentifier: self.localeIdentifier, LDMLString: LDMLString, location: defaultLocation, timeZone: self.timeZone)
    } // func dateString(now:  Date, LDMLString:  String) -> String
    
    
    // MARK: -
    
    public func details() -> Array<ASALDMLDetail> {
        return self.calendar.LDMLDetails()
    } // public func details() -> Array<ASADetail>
    
    public func supportsLocales() -> Bool {
        return self.calendar.supportsLocales()
    } // func supportsLocales() -> Bool
} // class ASARow: NSObject
