//
//  ASAEventCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import CoreLocation

fileprivate let EVENT_SOURCE_CODE_KEY = "EVENT_SOURCE_CODE"
fileprivate let BUILTIN_KEY           = "builtIn"

fileprivate let TRUE_STRING  = "true"
fileprivate let FALSE_STRING = "false"

class ASAEventCalendar:  ASALocatedObject {
    private var eventSource:  ASAUnlocatedEventCalendar?

    public var supportedLocales:  Array<String>? {
        get {
            return self.eventSource?.eventsFile?.supportedLocales
        } // get
    } // var supportedLocales

    @Published var eventsFileName:  String = "Solar events" {
        didSet {
            self.eventSource = ASAUnlocatedEventCalendar(fileName: self.eventsFileName)
        } // didSet
    } // var eventSourceCode
    
    @Published var builtIn:  Bool = true

//    @Published var localeIdentifier:  String = ""
    
    public func dictionary() -> Dictionary<String, Any> {
        //        debugPrint(#file, #function)
        var result = [
            UUID_KEY:  uuid.uuidString,
            //            EVENT_SOURCE_CODE_KEY:  self.eventSource?.eventSourceCode.rawValue ?? "",
            EVENT_SOURCE_CODE_KEY:  self.eventsFileName,
            TIME_ZONE_KEY:  effectiveTimeZone.identifier,
            USES_DEVICE_LOCATION_KEY:  self.usesDeviceLocation,
            BUILTIN_KEY:  self.builtIn ? TRUE_STRING : FALSE_STRING,
            LOCALE_KEY:  localeIdentifier
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
    }
    
    public class func newInternalEventCalendar(dictionary:  Dictionary<String, Any>) -> ASAEventCalendar? {
        //        debugPrint(#file, #function, dictionary)
        
        let rawCode:  String = dictionary[EVENT_SOURCE_CODE_KEY] as? String ?? ""
//        let code:  ASAInternalEventSourceCode = ASAInternalEventSourceCode(rawValue: rawCode) ?? .solar
//        let tempNewEventCalendar = ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode:  code)
//        let tempNewEventCalendar = ASAEventCalendarFactory.eventCalendar(eventSourceCode:  rawCode)
        let tempNewEventCalendar = ASAEventCalendar.eventCalendar(eventSourceCode:  rawCode)
        if tempNewEventCalendar == nil {
            return nil
        }
        
        let newEventCalendar = tempNewEventCalendar!
        
        let builtInString:  String = (dictionary[BUILTIN_KEY] ?? FALSE_STRING) as! String
        let builtIn = (builtInString == TRUE_STRING)
        newEventCalendar.builtIn = builtIn

        let localeIdentifier = dictionary[LOCALE_KEY] as? String
        if localeIdentifier != nil {
            newEventCalendar.localeIdentifier = localeIdentifier!
        }
        
        let UUIDString = dictionary[UUID_KEY] as? String
        if UUIDString != nil {
            let tempUUID: UUID? = UUID(uuidString: UUIDString!)
            if tempUUID != nil {
                newEventCalendar.uuid = tempUUID!
            } else {
                newEventCalendar.uuid = UUID()
            }
        } else {
            newEventCalendar.uuid = UUID()
        }
        
        let usesDeviceLocation = dictionary[USES_DEVICE_LOCATION_KEY] as? Bool
        let latitude = dictionary[LATITUDE_KEY] as? Double
        let longitude = dictionary[LONGITUDE_KEY] as? Double
        let altitude = dictionary[ALTITUDE_KEY] as? Double
        let horizontalAccuracy = dictionary[HORIZONTAL_ACCURACY_KEY] as? Double
        let verticalAccuracy = dictionary[VERTICAL_ACCURACY_KEY] as? Double
        newEventCalendar.usesDeviceLocation = usesDeviceLocation ?? true
        if latitude != nil && longitude != nil {
            newEventCalendar.location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), altitude: altitude ?? 0.0, horizontalAccuracy: horizontalAccuracy ?? 0.0, verticalAccuracy: verticalAccuracy ?? 0.0, timestamp: Date())
        }
        newEventCalendar.locationData.name = dictionary[PLACE_NAME_KEY] as? String
        newEventCalendar.locationData.locality = dictionary[LOCALITY_KEY] as? String
        newEventCalendar.locationData.country = dictionary[COUNTRY_KEY] as? String
        newEventCalendar.locationData.ISOCountryCode = dictionary[ISO_COUNTRY_CODE_KEY] as? String
        
        newEventCalendar.locationData.postalCode = dictionary[POSTAL_CODE_KEY] as? String
        newEventCalendar.locationData.administrativeArea = dictionary[ADMINISTRATIVE_AREA_KEY] as? String
        newEventCalendar.locationData.subAdministrativeArea = dictionary[SUBADMINISTRATIVE_AREA_KEY] as? String
        newEventCalendar.locationData.subLocality = dictionary[SUBLOCALITY_KEY] as? String
        newEventCalendar.locationData.thoroughfare = dictionary[THOROUGHFARE_KEY] as? String
        newEventCalendar.locationData.subThoroughfare = dictionary[SUBTHOROUGHFARE_KEY] as? String
        
        return newEventCalendar
    } // class func newInternalEventCalendar(dictionary:  Dictionary<String, Any>) -> ASAInternalEventCalendar?
    
    public func eventCalendarName() -> String {
        if self.eventSource == nil {
            return ""
        }
        
        return self.eventSource!.eventCalendarName(locationData:  locationData)
    } // func eventCalendarName() -> String
    
    public func eventSourceName() -> String {
        if self.eventSource == nil {
            return ""
        }
        
        return self.eventSource!.eventSourceName()
    } // func eventSourceName() -> String
    
    func eventDetails(startDate:  Date, endDate:  Date, ISOCountryCode:  String?, requestedLocaleIdentifier:  String) -> Array<ASAEvent> {
        if eventSource == nil || self.locationData.location == nil {
            return []
        }
        
        return self.eventSource!.eventDetails(startDate: startDate, endDate: endDate, locationData: self.locationData, eventCalendarName: eventCalendarName(), ISOCountryCode: ISOCountryCode, requestedLocaleIdentifier: requestedLocaleIdentifier)
    } // func eventDetails(startDate:  Date, endDate:  Date) -> Array<ASAEvent>

    class func eventCalendar(eventSourceCode:  String) -> ASAEventCalendar? {
        let result = ASAEventCalendar()
        result.eventsFileName = eventSourceCode
        result.locationData = ASALocationManager.shared.deviceLocationData
        result.usesDeviceLocation = true
        return result
    } //class func eventCalendar(eventSourceCode:  ASAEventSourceCode) -> ASAEventCalendar?
} // class ASAEventCalendar
