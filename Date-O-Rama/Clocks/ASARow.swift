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
//let TIME_ZONE_KEY:  String            = "timeZone"
//let USES_DEVICE_LOCATION_KEY:  String = "usesDeviceLocation"
//let LATITUDE_KEY:  String             = "latitude"
//let LONGITUDE_KEY:  String            = "longitude"
//let ALTITUDE_KEY:  String             = "altitude"
//let HORIZONTAL_ACCURACY_KEY:  String  = "haccuracy"
//let VERTICAL_ACCURACY_KEY:  String    = "vaccuracy"
//let PLACE_NAME_KEY:  String           = "placeName"
//let LOCALITY_KEY                      = "locality"
//let COUNTRY_KEY                       = "country"
//let ISO_COUNTRY_CODE_KEY              = "ISOCountryCode"
//let POSTAL_CODE_KEY:  String            = "postalCode"
//let ADMINISTRATIVE_AREA_KEY:  String    = "administrativeArea"
//let SUBADMINISTRATIVE_AREA_KEY:  String = "subAdministrativeArea"
//let SUBLOCALITY_KEY:  String            = "subLocality"
//let THOROUGHFARE_KEY:  String           = "thoroughfare"
//let SUBTHOROUGHFARE_KEY:  String        = "subThoroughfare"

//let AUTOUPDATING_CURRENT_TIME_ZONE_VALUE = "*AUTOUPDATING*"


// MARK: -

//class ASARow: NSObject, ObservableObject, Identifiable {
    class ASARow: ASALocatedObject {
//        var uuid = UUID()
    
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
    
    @Published var localeIdentifier:  String = Locale.current.identifier
    
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
    
//    var timeZone:  TimeZone? {
//        get {
//            return self.locationData.timeZone
//        } // get
//        set {
//            self.locationData.timeZone = newValue
//        } // set
//    }
//
//    var effectiveTimeZone:  TimeZone {
//        get {
//            if usesDeviceLocation || self.timeZone == nil {
//                return TimeZone.autoupdatingCurrent
//            } else {
//                return self.timeZone!
//            }
//        } // get
//    } // var effectiveTimeZone
//
//    @Published var usesDeviceLocation:  Bool = true
//    @Published var locationData:  ASALocationData = ASALocationManager.shared().locationData
//
//    var location:  CLLocation? {
//        get {
//            return self.locationData.location
//        } // get
//        set {
//            self.locationData.location = newValue
//        } // set
//    }
    
    var placeName:  String? {
           get {
               return self.locationData.name
           } // get
           set {
               self.locationData.name = newValue
           } // set
       }
    
    var locality:  String? {
           get {
               return self.locationData.locality
           } // get
           set {
               self.locationData.locality = newValue
           } // set
       }
    
    var country:  String? {
           get {
               return self.locationData.country
           } // get
           set {
               self.locationData.country = newValue
           } // set
       }
    
    var ISOCountryCode:  String? {
           get {
               return self.locationData.ISOCountryCode
           } // get
           set {
               self.locationData.ISOCountryCode = newValue
           } // set
       }
    
//    var locationManager = ASALocationManager.shared()
//    let notificationCenter = NotificationCenter.default

    
    // MARK: -
    
//    override init() {
//        super.init()
//        notificationCenter.addObserver(self, selector: #selector(handle(notification:)), name: NSNotification.Name(rawValue: UPDATED_LOCATION), object: nil)
//    } // override init()
//
//    deinit {
//        notificationCenter.removeObserver(self)
//    } // deinit
//
//    @objc func handle(notification:  Notification) -> Void {
//        if self.usesDeviceLocation {
//            self.locationData = self.locationManager.locationData
//        }
//    } // func handle(notification:  Notification) -> Void
    
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
        
        if self.placeName != nil {
            result[PLACE_NAME_KEY] = self.placeName
        }
        if self.locality != nil {
            result[LOCALITY_KEY] = self.locality
        }
        if self.country != nil {
            result[COUNTRY_KEY] = self.country
        }
        if self.ISOCountryCode != nil {
            result[ISO_COUNTRY_CODE_KEY] = self.ISOCountryCode
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
        newRow.placeName = dictionary[PLACE_NAME_KEY] as? String
        newRow.locality = dictionary[LOCALITY_KEY] as? String
        newRow.country = dictionary[COUNTRY_KEY] as? String
        newRow.ISOCountryCode = dictionary[ISO_COUNTRY_CODE_KEY] as? String
        
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

    public func dateTimeString(now:  Date, LDMLString:  String) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, LDMLString: LDMLString, location: self.location, timeZone: self.effectiveTimeZone)
    } // func dateTimeString(now:  Date, LDMLString:  String) -> String

//    func eventDetails(date:  Date) -> Array<ASAEvent> {
//        return self.calendar.eventDetails(date: date, location: self.locationData.location, timeZone: self.effectiveTimeZone)
//    } // func eventDetails(date:  Date) -> Array<ASAEvent>

    public func LDMLDetails() -> Array<ASALDMLDetail> {
        return self.calendar.LDMLDetails
    } // public func LDMLDetails() -> Array<ASADetail>
    
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


// MARK :-

extension ASARow {
    public func emoji(date:  Date) -> String {
       return "\((self.ISOCountryCode ?? "").flag())\(self.effectiveTimeZone.emoji(date:  date))\(self.usesDeviceLocation ? "📍" : "")"
    } // public func emoji(date:  Date) -> String
} // extension ASARow
