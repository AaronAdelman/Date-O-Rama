//
//  ASALocatedObject.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

let TIME_ZONE_KEY:  String              = "timeZone"
let USES_DEVICE_LOCATION_KEY:  String   = "usesDeviceLocation"
let LATITUDE_KEY:  String               = "latitude"
let LONGITUDE_KEY:  String              = "longitude"
let ALTITUDE_KEY:  String               = "altitude"
let HORIZONTAL_ACCURACY_KEY:  String    = "haccuracy"
let VERTICAL_ACCURACY_KEY:  String      = "vaccuracy"
let PLACE_NAME_KEY:  String             = "placeName"
let LOCALITY_KEY                        = "locality"
let COUNTRY_KEY                         = "country"
let ISO_COUNTRY_CODE_KEY                = "ISOCountryCode"
let POSTAL_CODE_KEY:  String            = "postalCode"
let ADMINISTRATIVE_AREA_KEY:  String    = "administrativeArea"
let SUBADMINISTRATIVE_AREA_KEY:  String = "subAdministrativeArea"
let SUBLOCALITY_KEY:  String            = "subLocality"
let THOROUGHFARE_KEY:  String           = "thoroughfare"
let SUBTHOROUGHFARE_KEY:  String        = "subThoroughfare"


class ASALocatedObject:  NSObject, ObservableObject, Identifiable {
    var uuid = UUID()

    var timeZone:  TimeZone? {
        get {
            return self.locationData.timeZone
        } // get
        set {
            self.locationData.timeZone = newValue
        } // set
    }
    
    var effectiveTimeZone:  TimeZone {
        get {
            if usesDeviceLocation || self.timeZone == nil {
                return TimeZone.autoupdatingCurrent
            } else {
                return self.timeZone!
            }
        } // get
    } // var effectiveTimeZone
    
    @Published var usesDeviceLocation:  Bool = true
    @Published var locationData:  ASALocationData = ASALocationManager.shared.locationData
    
    var location:  CLLocation? {
        get {
            return self.locationData.location
        } // get
        set {
            self.locationData.location = newValue
        } // set
    }

    @Published var localeIdentifier:  String = ""
    
    var locationManager = ASALocationManager.shared
    let notificationCenter = NotificationCenter.default

    
    // MARK: -
    
    override init() {
        super.init()
        notificationCenter.addObserver(self, selector: #selector(handle(notification:)), name: NSNotification.Name(rawValue: UPDATED_LOCATION), object: nil)
    } // override init()
    
    deinit {
        notificationCenter.removeObserver(self)
    } // deinit
    
    @objc func handle(notification:  Notification) -> Void {
        if self.usesDeviceLocation {
            if self.locationManager.locationData.location == nil {
                debugPrint("AHA!")
            }
            self.locationData = self.locationManager.locationData
        }
    } // func handle(notification:  Notification) -> Void
    
} // class ASALocatedObject


// MARK :-

extension ASALocatedObject {
    public func emoji(date:  Date) -> String {
        return "\((self.locationData.ISOCountryCode ?? "").flag())\(self.effectiveTimeZone.emoji(date:  date))"
    } // public func emoji(date:  Date) -> String
} // extension ASARow
