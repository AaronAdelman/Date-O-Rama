//
//  ASARow.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit
import CoreLocation
import EventKit

let UUID_KEY:  String                      = "UUID"
let LOCALE_KEY:  String                    = "locale"
let CALENDAR_KEY:  String                  = "calendar"
let DATE_FORMAT_KEY:  String               = "dateFormat"
let TIME_FORMAT_KEY:  String               = "timeFormat"
let BUILT_IN_EVENT_CALENDARS_KEY:  String  = "builtInEventCalendars"
let ICALENDAR_EVENT_CALENDARS_KEY:  String = "iCalendarEventCalendars"


// MARK:  -

//class ASAEventCacheObject {
//    var array:  Array<ASAEventCompatible>
//
//    init(array:  Array<ASAEventCompatible>) {
//        self.array = array
//    } // init(array:  Array<ASAEventCompatible>)
//} // class ASAEventCacheObject


// MARK:  -

class ASARow: ASALocatedObject {
    @Published var calendar:  ASACalendar = ASAAppleCalendar(calendarCode: .Gregorian) {
        didSet {
            if !self.calendar.supportedDateFormats.contains(self.dateFormat) {
                self.dateFormat = self.calendar.defaultDateFormat
            }
            if !self.calendar.supportsLocations {
                self.usesDeviceLocation = false

                if !self.calendar.supportsTimeZones {
                    self.locationData = ASALocation.NullIsland
                    self.usesDeviceLocation = false
                }
            }

            if !startingUp {
//                self.eventCache.removeAllObjects()
                self.clearCacheObjects()
            }
        } // didSet
    } // var calendar

    @Published var dateFormat:  ASADateFormat = .full {
        didSet {
            if !startingUp {
//                self.eventCache.removeAllObjects()
                self.clearCacheObjects()
            }
        } // didset
    } // var dateFormat

    @Published var timeFormat:  ASATimeFormat = .medium {
        didSet {
            if !startingUp {
//                self.eventCache.removeAllObjects()
                self.clearCacheObjects()
            }
        } // didset
    } // var timeFormat

    @Published var builtInEventCalendars:  Array<ASAEventCalendar> = [] {
        didSet {
            if !startingUp {
//                self.eventCache.removeAllObjects()
                self.clearCacheObjects()
            }
        } // didset
    } // var builtInEventCalendars

    @Published var iCalendarEventCalendars:  Array<EKCalendar> = [] {
        didSet {
            if !startingUp {
//                self.eventCache.removeAllObjects()
                self.clearCacheObjects()
            }
        } // didset
    } // var iCalendarEventCalendars

    override func handleLocationDataChanged() {
        if !startingUp {
//            self.eventCache.removeAllObjects()
            self.clearCacheObjects()
            debugPrint(#file, #function, "The event cache has been cleared.")
        }
    }

//    private var eventCache = NSCache<NSNumber, ASAEventCacheObject>()
    private var eventCacheStartDate:  Date = Date.distantPast
    private var eventCacheEndDate:  Date = Date.distantPast
    private var eventCacheValue:  Array<ASAEventCompatible> = []

    private func clearCacheObjects() {
        self.eventCacheStartDate = Date.distantPast
        self.eventCacheEndDate   = Date.distantPast
        self.eventCacheValue     = []
    } // func clearCacheObjects()

    
    // MARK:  -
        
    public func dictionary(forComplication:  Bool) ->  Dictionary<String, Any> {
        //        debugPrint(#file, #function)

        var result = [
            UUID_KEY:  uuid.uuidString,
            LOCALE_KEY:  localeIdentifier,
            CALENDAR_KEY:  calendar.calendarCode.rawValue,
            DATE_FORMAT_KEY:  dateFormat.rawValue ,
            TIME_FORMAT_KEY:  timeFormat.rawValue ,
            TIME_ZONE_KEY:  locationData.timeZone.identifier,
            BUILT_IN_EVENT_CALENDARS_KEY:  self.builtInEventCalendars.map{ $0.fileName },
            USES_DEVICE_LOCATION_KEY:  self.usesDeviceLocation
        ] as [String : Any]

        if self.isICalendarCompatible && !forComplication {
            result[ICALENDAR_EVENT_CALENDARS_KEY] =  self.iCalendarEventCalendars.map{ $0.title }
        }
        
        result[LATITUDE_KEY] = self.locationData.location.coordinate.latitude
        result[LONGITUDE_KEY] = self.locationData.location.coordinate.longitude
        result[ALTITUDE_KEY] = self.locationData.location.altitude
        result[HORIZONTAL_ACCURACY_KEY] = self.locationData.location.horizontalAccuracy
        result[VERTICAL_ACCURACY_KEY] = self.locationData.location.verticalAccuracy

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

    private var startingUp = true
    
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

        let builtInEventCalendarsFileNames = dictionary[BUILT_IN_EVENT_CALENDARS_KEY] as? Array<String>
        if builtInEventCalendarsFileNames != nil {
            for fileName in builtInEventCalendarsFileNames! {
                let newEventCalendar = ASAEventCalendar(fileName: fileName)
                newRow.builtInEventCalendars.append(newEventCalendar)
            }
        }

        if newRow.calendar.usesISOTime {
            let iCalendarEventCalendarsTitles = dictionary[ICALENDAR_EVENT_CALENDARS_KEY] as? Array<String>
            newRow.iCalendarEventCalendars = ASAEKEventManager.shared.EKCalendars(titles: iCalendarEventCalendarsTitles)
        }
        
        let usesDeviceLocation = dictionary[USES_DEVICE_LOCATION_KEY] as? Bool
        let latitude = dictionary[LATITUDE_KEY] as? Double
        let longitude = dictionary[LONGITUDE_KEY] as? Double
        let altitude = dictionary[ALTITUDE_KEY] as? Double
        let horizontalAccuracy = dictionary[HORIZONTAL_ACCURACY_KEY] as? Double
        let verticalAccuracy = dictionary[VERTICAL_ACCURACY_KEY] as? Double
        newRow.usesDeviceLocation = usesDeviceLocation ?? true
        var newLocation = CLLocation()
        if latitude != nil && longitude != nil {
            newLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), altitude: altitude ?? 0.0, horizontalAccuracy: horizontalAccuracy ?? 0.0, verticalAccuracy: verticalAccuracy ?? 0.0, timestamp: Date())
        }
        let newName = dictionary[PLACE_NAME_KEY] as? String
        let newLocality = dictionary[LOCALITY_KEY] as? String
        let newCountry = dictionary[COUNTRY_KEY] as? String
        let newISOCountryCode = dictionary[ISO_COUNTRY_CODE_KEY] as? String
        
        let newPostalCode = dictionary[POSTAL_CODE_KEY] as? String
        let newAdministrativeArea = dictionary[ADMINISTRATIVE_AREA_KEY] as? String
        let newSubAdministrativeArea = dictionary[SUBADMINISTRATIVE_AREA_KEY] as? String
        let newSubLocality = dictionary[SUBLOCALITY_KEY] as? String
        let newThoroughfare = dictionary[THOROUGHFARE_KEY] as? String
        let newSubThoroughfare = dictionary[SUBTHOROUGHFARE_KEY] as? String

        let timeZoneIdentifier = dictionary[TIME_ZONE_KEY] as? String

        let newLocationData = ASALocation(id: UUID(), location: newLocation, name: newName, locality: newLocality, country: newCountry, ISOCountryCode: newISOCountryCode, postalCode: newPostalCode, administrativeArea: newAdministrativeArea, subAdministrativeArea: newSubAdministrativeArea, subLocality: newSubLocality, thoroughfare: newThoroughfare, subThoroughfare: newSubThoroughfare, timeZone: TimeZone(identifier: timeZoneIdentifier!) ?? TimeZone.GMT)
        newRow.locationData = newLocationData

        newRow.startingUp = false
        return newRow
    } // func newRowFromDictionary(dictionary:  Dictionary<String, String?>) -> ASARow


    // MARK:  -

    func events(startDate:  Date, endDate:  Date) -> Array<ASAEventCompatible> {
//        let eventCacheKey = NSNumber(value: startDate.timeIntervalSince1970)
//        let wrappedArray = self.eventCache.object(forKey: eventCacheKey)
//        if wrappedArray != nil {
////            debugPrint(#file, #function, self.calendar.calendarCode, self.locationData.formattedOneLineAddress, "Found events in cache")
//            return wrappedArray!.array
//        }
        if self.eventCacheStartDate == startDate && self.eventCacheEndDate == endDate {
            return self.eventCacheValue
        }

//        debugPrint(#file, #function, self.calendar.calendarCode, self.locationData.formattedOneLineAddress, "Did not find events in cache")

        var unsortedEvents: [ASAEventCompatible] = []

        if self.isICalendarCompatible {
            unsortedEvents = unsortedEvents + ASAEKEventManager.shared.eventsFor(startDate: startDate, endDate: endDate, calendars: self.iCalendarEventCalendars)
        }

        for eventCalendar in self.builtInEventCalendars {
            unsortedEvents = unsortedEvents + eventCalendar.events(startDate: startDate, endDate: endDate, locationData: self.locationData, eventCalendarName: eventCalendar.eventCalendarNameWithPlaceName(locationData: self.locationData, localeIdentifier: Locale.current.identifier), calendarTitleWithoutLocation: eventCalendar.eventCalendarNameWithoutPlaceName(localeIdentifier: Locale.current.identifier), ISOCountryCode: self.locationData.ISOCountryCode, requestedLocaleIdentifier: self.localeIdentifier, calendar: self.calendar)
        } // for eventCalendar in self.builtInEventCalendars

        let events: [ASAEventCompatible] = unsortedEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool
            in
            if e1.isAllDay && !e2.isAllDay {
                return true
            }

            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })

//        self.eventCache.setObject(ASAEventCacheObject(array: events), forKey: eventCacheKey)
        self.eventCacheStartDate = startDate
        self.eventCacheEndDate   = endDate
        self.eventCacheValue     = events
//        debugPrint(#file, #function, self.calendar.calendarCode, self.locationData.formattedOneLineAddress, "Number of events written to cache:", events.count, "Start date:", startDate, "End date:", endDate)

        return events
    } // func events(startDate:  Date, endDate:  Date) -> Array<ASAEventCompatible>

    var isICalendarCompatible:  Bool {
        return self.calendar.usesISOTime && self.usesDeviceLocation
    } // var isICalendarCompatible
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

    public func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents {
        self.calendar.dateComponents(components, from: date, locationData: self.locationData)
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents

    public func shortenedDateTimeString(now:  Date) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.shortened
        let timeFormat: ASATimeFormat = self.timeFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: self.locationData)
        return result
    } // func shortenedDateTimeString(now:  Date) -> String

    public func shortenedTimeString(now:  Date) -> String {
        let timeFormat: ASATimeFormat = self.timeFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: self.locationData)
        return result
    }

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

    var daysPerWeek:  Int? {
        return self.calendar.daysPerWeek
    }
} // extension ASARow


// MARK:  -

extension ASARow {
    static func generic(calendarCode:  ASACalendarCode, dateFormat:  ASADateFormat) ->  ASARow {
        let temp = ASARow()
        temp.calendar = ASAAppleCalendar(calendarCode: calendarCode)
        temp.localeIdentifier = ""
        temp.dateFormat = dateFormat
        return temp
    } // static func generic(calendarCode:  ASACalendarCode) ->  ASARow

    static var generic:  ASARow {
        return ASARow.generic(calendarCode: .Gregorian, dateFormat: .full)
    } // static var generic:  ASARow
} // extension ASARow
