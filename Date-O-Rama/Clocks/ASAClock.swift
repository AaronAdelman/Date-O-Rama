//
//  ASAClock.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-01-04.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import UIKit
import CoreLocation
import EventKit
import Foundation

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

let UUID_KEY:  String                      = "UUID"
let LOCALE_KEY:  String                    = "locale"
let CALENDAR_KEY:  String                  = "calendar"
let DATE_FORMAT_KEY:  String               = "dateFormat"
let TIME_FORMAT_KEY:  String               = "timeFormat"
let BUILT_IN_EVENT_CALENDARS_KEY:  String  = "builtInEventCalendars"
let ICALENDAR_EVENT_CALENDARS_KEY:  String = "iCalendarEventCalendars"


// MARK:  -

class ASAClock: NSObject, ObservableObject, Identifiable {
    var uuid = UUID()

    @Published var usesDeviceLocation:  Bool = true
    @Published var locationData:  ASALocation = ASALocationManager.shared.deviceLocation {
        didSet {
            self.handleLocationDataChanged()
        }
    }

    @Published var localeIdentifier:  String = ""
    
    
    // MARK: -
    
    override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(handleLocationChanged(notification:)), name: NSNotification.Name(rawValue: UPDATED_LOCATION_NAME), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleStoreChanged(notification:)), name: .EKEventStoreChanged, object: nil)
    } // override init()
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    } // deinit
    
//    @objc func handleLocationChanged(notification:  Notification) -> Void {
//        if self.usesDeviceLocation {
//            let locationManager = ASALocationManager.shared
//            self.locationData = locationManager.deviceLocation
//        }
//    } // func handle(notification:  Notification) -> Void
    
    @objc func handleStoreChanged(notification:  Notification) -> Void {
        self.clearCacheObjects()
    } // func handleStoreChanged(notification:  Notification) -> Void

    fileprivate func enforceSelfConsistency() {
        if !self.calendar.supportedDateFormats.contains(self.dateFormat) && !self.calendar.supportedWatchDateFormats.contains(self.dateFormat) {
            self.dateFormat = self.calendar.defaultDateFormat
        }
        if !self.calendar.supportsLocations {
            self.usesDeviceLocation = false
            
            if !self.calendar.supportsTimeZones {
                self.locationData = ASALocation.NullIsland
                self.usesDeviceLocation = false
            }
        }
        
        if !self.isICalendarCompatible {
            self.iCalendarEventCalendars = []
        }
        
        var revisedBuiltInEventCalendars: Array<ASAEventCalendar> = []
        for eventCalendar in self.builtInEventCalendars {
            if (eventCalendar.eventsFile?.calendarCode ?? .none).matches(self.calendar.calendarCode) {
                revisedBuiltInEventCalendars.append(eventCalendar)
            } // for eventCalendar
            self.builtInEventCalendars = revisedBuiltInEventCalendars
        }
    }
    
    @Published var calendar:  ASACalendar = ASAAppleCalendar(calendarCode: .Gregorian) {
        didSet {
            enforceSelfConsistency()

            if !startingUp {
                self.clearCacheObjects()
            }
        } // didSet
    } // var calendar

    @Published var dateFormat:  ASADateFormat = .full {
        didSet {
            enforceSelfConsistency()

            if !startingUp {
                self.clearCacheObjects()
            }
        } // didset
    } // var dateFormat

    @Published var timeFormat:  ASATimeFormat = .medium {
        didSet {
            enforceSelfConsistency()

            if !startingUp {
                self.clearCacheObjects()
            }
        } // didset
    } // var timeFormat

    @Published var builtInEventCalendars:  Array<ASAEventCalendar> = [] {
        didSet {
            if !startingUp {
                self.clearCacheObjects()
            }
        } // didset
    } // var builtInEventCalendars

    @Published var iCalendarEventCalendars:  Array<EKCalendar> = [] {
        didSet {
            if !startingUp {
                self.clearCacheObjects()
            }
        } // didset
    } // var iCalendarEventCalendars
    

    // MARK:  -

    func handleLocationDataChanged() {
        if !startingUp {
            self.clearCacheObjects()
//            debugPrint(#file, #function, "The event cache has been cleared.")
        }
    }

    private var eventCacheStartDate:  Date = Date.distantPast
    private var eventCacheEndDate:  Date = Date.distantPast
    private var eventCacheValue:  (dateEvents: Array<ASAEventCompatible>, timeEvents: Array<ASAEventCompatible>) = ([], [])

    private func clearCacheObjects() {
        self.eventCacheStartDate = Date.distantPast
        self.eventCacheEndDate   = Date.distantPast
        self.eventCacheValue     = ([], [])
        self.startAndEndDateStringsCache.removeAllObjects()
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
        if self.locationData.regionCode != nil {
            result[ISO_COUNTRY_CODE_KEY] = self.locationData.regionCode
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
    
    public class func new(dictionary:  Dictionary<String, Any>) -> ASAClock {
        //        debugPrint(#file, #function, dictionary)
        
        let newClock = ASAClock()
        
        let UUIDString = dictionary[UUID_KEY] as? String
        if UUIDString != nil {
            let tempUUID: UUID? = UUID(uuidString: UUIDString!)
            if tempUUID != nil {
                newClock.uuid = tempUUID!
            } else {
                newClock.uuid = UUID()
            }
        } else {
            newClock.uuid = UUID()
        }
        
        let localeIdentifier = dictionary[LOCALE_KEY] as? String
        if localeIdentifier != nil {
            newClock.localeIdentifier = localeIdentifier!
        }

        let calendarCode = dictionary[CALENDAR_KEY] as? String
        if calendarCode != nil {
            let code = ASACalendarCode(rawValue: calendarCode!)
            if code == nil {
                newClock.calendar = ASACalendarFactory.calendar(code: .Gregorian)!
            } else {
                newClock.calendar = ASACalendarFactory.calendar(code: code!)!
            }
        }
        
        let dateFormat = dictionary[DATE_FORMAT_KEY] as? String
        if dateFormat != nil {
            newClock.dateFormat = ASADateFormat(rawValue: dateFormat! )!
        }

        let timeFormat = dictionary[TIME_FORMAT_KEY] as? String
        if timeFormat != nil {
            newClock.timeFormat = ASATimeFormat(rawValue: timeFormat! ) ?? .medium
        }

        let builtInEventCalendarsFileNames = dictionary[BUILT_IN_EVENT_CALENDARS_KEY] as? Array<String>
        if builtInEventCalendarsFileNames != nil {
            for fileName in builtInEventCalendarsFileNames! {
                let newEventCalendar = ASAEventCalendar(fileName: fileName)
                if newEventCalendar.eventsFile != nil {
                    newClock.builtInEventCalendars.append(newEventCalendar)
                }
            }
        }

        if newClock.calendar.usesISOTime {
            let iCalendarEventCalendarsTitles = dictionary[ICALENDAR_EVENT_CALENDARS_KEY] as? Array<String>
            newClock.iCalendarEventCalendars = ASAEKEventManager.shared.EKCalendars(titles: iCalendarEventCalendarsTitles)
        }
        
        let usesDeviceLocation = dictionary[USES_DEVICE_LOCATION_KEY] as? Bool
        let latitude = dictionary[LATITUDE_KEY] as? Double
        let longitude = dictionary[LONGITUDE_KEY] as? Double
        let altitude = dictionary[ALTITUDE_KEY] as? Double
        let horizontalAccuracy = dictionary[HORIZONTAL_ACCURACY_KEY] as? Double
        let verticalAccuracy = dictionary[VERTICAL_ACCURACY_KEY] as? Double
        newClock.usesDeviceLocation = usesDeviceLocation ?? true
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

        let newLocationData = ASALocation(id: UUID(), location: newLocation, name: newName, locality: newLocality, country: newCountry, regionCode: newISOCountryCode, postalCode: newPostalCode, administrativeArea: newAdministrativeArea, subAdministrativeArea: newSubAdministrativeArea, subLocality: newSubLocality, thoroughfare: newThoroughfare, subThoroughfare: newSubThoroughfare, timeZone: TimeZone(identifier: timeZoneIdentifier!) ?? TimeZone.GMT)
        newClock.locationData = newLocationData

        newClock.startingUp = false
        return newClock
    } // class func new(dictionary:  Dictionary<String, Any>) -> ASAClock


    // MARK:  -

    func events(startDate:  Date, endDate:  Date) -> (dateEvents: Array<ASAEventCompatible>, timeEvents: Array<ASAEventCompatible>) {
        if self.eventCacheStartDate == startDate && self.eventCacheEndDate == endDate {
            return self.eventCacheValue
        }

//        debugPrint(#file, #function, self.calendar.calendarCode, self.locationData.formattedOneLineAddress, "Did not find events in cache")

        var unsortedDateEvents: [ASAEventCompatible] = []
        var unsortedTimeEvents: [ASAEventCompatible] = []
        
        let currentLocaleIdentifier: String = Locale.current.identifier
        let regionCode = self.locationData.regionCode
        for eventCalendar in self.builtInEventCalendars {
            let eventCalendarName: String = eventCalendar.eventCalendarNameWithPlaceName(locationData: self.locationData, localeIdentifier: currentLocaleIdentifier)
            let eventCalendarNameWithoutLocation: String = eventCalendar.eventCalendarNameWithoutPlaceName(localeIdentifier: currentLocaleIdentifier)
            let eventCalendarEvents = eventCalendar.events(startDate: startDate, endDate: endDate, locationData: self.locationData, eventCalendarName: eventCalendarName, calendarTitleWithoutLocation: eventCalendarNameWithoutLocation, regionCode: regionCode, requestedLocaleIdentifier: self.localeIdentifier, calendar: self.calendar)
            unsortedDateEvents.add(events: eventCalendarEvents.dateEvents)
            unsortedTimeEvents.add(events: eventCalendarEvents.timeEvents)
        } // for eventCalendar in self.builtInEventCalendars
        
        if self.isICalendarCompatible && self.iCalendarEventCalendars.count > 0 {
            let EventKitEvents = ASAEKEventManager.shared.eventsFor(startDate: startDate, endDate: endDate, calendars: self.iCalendarEventCalendars)
            for event in EventKitEvents {
                if event.isAllDay {
                    unsortedDateEvents.add(event: event)
                } else {
                    unsortedTimeEvents.add(event: event)
                }
            } // for event in EventKitEvents
        }
        
        let dateEvents = unsortedDateEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool
            in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        let timeEvents = unsortedTimeEvents.sorted(by: {
            (e1: ASAEventCompatible, e2: ASAEventCompatible) -> Bool
            in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        })
        
        assert(dateEvents.count == unsortedDateEvents.count)
        assert(timeEvents.count == unsortedTimeEvents.count)

        self.eventCacheStartDate = startDate
        self.eventCacheEndDate   = endDate
        let result = (dateEvents, timeEvents)
        self.eventCacheValue     = result
//        debugPrint(#file, #function, self.calendar.calendarCode, self.locationData.formattedOneLineAddress, "Number of events written to cache:", events.count, "Start date:", startDate, "End date:", endDate)

        return result
    } // func events(startDate:  Date, endDate:  Date) -> (dateEvents: Array<ASAEventCompatible>, timeEvents: Array<ASAEventCompatible>)

    var isICalendarCompatible:  Bool {
        return self.calendar.usesISOTime && (self.usesDeviceLocation || self.locationData.timeZone.isCurrent)
    } // var isICalendarCompatible
    
    var startAndEndDateStringsCache = NSCache<NSString, ASAStartAndEndDateStrings>()
    
    
    // MARK:  - Weeks
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>? {
        if self.calendar is ASACalendarSupportingWeeks {
            let calendarSupportingWeeks = self.calendar as! ASACalendarSupportingWeeks
            let result = calendarSupportingWeeks.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
            return result
        }
        
        return nil
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>?
    
    var weekendDays: Array<Int>? {
        if self.calendar is ASACalendarSupportingWeeks {
            let calendarSupportingWeeks = self.calendar as! ASACalendarSupportingWeeks
            return calendarSupportingWeeks.weekendDays(for: self.locationData.regionCode)

        } else {
            return nil
        }
    } // var weekendDays
    
//    var workDays: Array<Int> {
//        return self.calendar.workDays
//    }
    
    var daysPerWeek: Int? {
        if self.calendar is ASACalendarSupportingWeeks {
            let calendarSupportingWeeks = self.calendar as! ASACalendarSupportingWeeks
            
            return calendarSupportingWeeks.daysPerWeek
        }
        
        return nil
    } // var daysPerWeek
    
} // class ASAClock


// MARK:  -

extension ASAClock {
    public func dateStringTimeStringDateComponents(now: Date) -> (dateString: String, timeString: String?, dateComponents: ASADateComponents) {
//        #if os(watchOS)
//        let properDateFormat = self.dateFormat.watchShortened
//        #else
        let properDateFormat = self.dateFormat
//        #endif
        return self.calendar.dateStringTimeStringDateComponents(now: now, localeIdentifier: self.localeIdentifier, dateFormat: properDateFormat, timeFormat: self.timeFormat, locationData: self.locationData)
    }

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
        let timeFormat: ASATimeFormat = self.timeFormat
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: self.locationData)
        return result
    } // func shortenedDateTimeString(now:  Date) -> String

    public func shortenedDateString(now:  Date) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: self.locationData)
        return result
    } // func shortenedDateString(now:  Date) -> String
    
    public func yearOnlyDateString(now:  Date) -> String {
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .shortYearOnly, timeFormat: .none, locationData: self.locationData)
        return result
    } // func yearOnlyDateString(now:  Date) -> String
    
    public func yearAndMonthOnlyDateString(now:  Date) -> String {
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .shortYearAndMonthOnly, timeFormat: .none, locationData: self.locationData)
        return result
    } // public func yearAndMonthOnlyDateString(now:  Date) -> String

//    public func watchShortenedDateString(now:  Date) -> String {
//        let dateFormat: ASADateFormat = self.dateFormat.watchShortened
//        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: self.locationData)
//        return result
//    } // func watchShortenedDateString(now:  Date) -> String

//    public func watchShortenedTimeString(now:  Date) -> String {
//        let timeFormat: ASATimeFormat = self.timeFormat
//        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: self.locationData)
//        return result
//    } // func watchShortenedTimeString(now:  Date) -> String

    
    var miniCalendarNumberFormat: ASAMiniCalendarNumberFormat {
        return self.calendar.miniCalendarNumberFormat(locale: Locale.desiredLocale(self.localeIdentifier))
    } // var miniCalendarNumberFormat
} // extension ASAClock


// MARK:  -

extension ASAClock {
    static func generic(calendarCode:  ASACalendarCode, dateFormat:  ASADateFormat) ->  ASAClock {
        let temp = ASAClock()
        temp.calendar = ASAAppleCalendar(calendarCode: calendarCode)
        temp.localeIdentifier = ""
        temp.dateFormat = dateFormat
        return temp
    } // static func generic(calendarCode:  ASACalendarCode) ->  ASAClock

    static var generic:  ASAClock {
        return ASAClock.generic(calendarCode: .Gregorian, dateFormat: .full)
    } // static var generic:  ASAClock
} // extension ASAClock

extension ASAClock {
    public func countryCodeEmoji(date:  Date) -> String {
        let regionCode: String = self.locationData.regionCode ?? ""
        let result: String = regionCode.flag
//        debugPrint(#file, #function, "Region code:", regionCode, "Flag:", result)
        return result
    } // public func countryCodeEmoji(date:  Date) -> String
} // extension ASAClock

class ASAStartAndEndDateStrings {
    var startDateString: String?
    var endDateString: String
    
    init(startDateString: String?, endDateString: String) {
        self.startDateString = startDateString
        self.endDateString   = endDateString
    }
}

extension ASAClock {
    func properlyShortenedString(date:  Date, isPrimaryClock: Bool, eventIsTodayOnly: Bool, eventIsAllDay: Bool) -> String {
        return (isPrimaryClock && eventIsTodayOnly && !eventIsAllDay) ? self.timeString(now: date) : self.shortenedDateTimeString(now: date)
     } // func properlyShortenedString(date:  Date, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> String
    
    private func genericStartAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String?, endDateString: String) {
        var startDateString: String?
        var endDateString: String
        
        if event.startDate == event.endDate {
            startDateString = nil
        } else {
            startDateString = self.properlyShortenedString(date: event.startDate, isPrimaryClock: isPrimaryClock, eventIsTodayOnly: eventIsTodayOnly, eventIsAllDay: event.isAllDay)
        }
        endDateString = self.properlyShortenedString(date: event.endDate ?? event.startDate, isPrimaryClock: isPrimaryClock, eventIsTodayOnly: eventIsTodayOnly, eventIsAllDay: event.isAllDay)
        
        return (startDateString, endDateString)
    } // func genericStartAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String?, endDateString: String)
    
    public func startAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String?, endDateString: String) {
        // Cache code
        if let cachedVersion = startAndEndDateStringsCache.object(forKey: event.eventIdentifier! as NSString) {
            // use the cached version
            return (cachedVersion.startDateString, cachedVersion.endDateString)
        }
        
        var startDateString: String?
        var endDateString: String
        
        let eventIsAllDay = event.isAllDay(for: self)
        if !eventIsAllDay {
            (startDateString, endDateString) = genericStartAndEndDateStrings(event: event, isPrimaryClock: isPrimaryClock, eventIsTodayOnly: eventIsTodayOnly)
        } else {
            switch event.type {
            case .multiYear:
                startDateString = self.yearOnlyDateString(now: event.startDate)
                endDateString = self.yearOnlyDateString(now: event.endDate - 1)
            case .oneYear:
                startDateString = nil
                endDateString = self.yearOnlyDateString(now: event.startDate)
            case .multiMonth:
                startDateString = self.yearAndMonthOnlyDateString(now: event.startDate)
                endDateString = event.endDate == nil ? "???" : self.yearAndMonthOnlyDateString(now: event.endDate - 1)
            case .oneMonth:
                startDateString = nil
                endDateString = self.yearAndMonthOnlyDateString(now: event.startDate)
            case .multiDay:
                startDateString = self.shortenedDateString(now: event.startDate)
                endDateString = event.endDate == nil ? "???" : self.shortenedDateString(now: event.endDate - 1)
            case .oneDay
//                , .firstFullMoonDay, .secondFullMoonDay, .Easter
                :
                startDateString = nil
                endDateString = self.shortenedDateString(now: event.startDate)
            default:
                (startDateString, endDateString) = genericStartAndEndDateStrings(event: event, isPrimaryClock: isPrimaryClock, eventIsTodayOnly: eventIsTodayOnly)
            } // switch event.type
        }
        
        // create it from scratch then store in the cache
        let myObject = ASAStartAndEndDateStrings(startDateString: startDateString, endDateString: endDateString)
        startAndEndDateStringsCache.setObject(myObject, forKey: event.eventIdentifier! as NSString)

        return (startDateString, endDateString)
    } // func startAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String, endDateString: String)
    
    public func longStartAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String, endDateString: String) {
        let eventIsAllDay = event.isAllDay(for: self)
        let startDateString = eventIsAllDay ? self.dateString(now: event.startDate) : self.dateTimeString(now: event.startDate)
        let endDate: Date = event.endDate - 1
        let endDateString = eventIsAllDay ? self.dateString(now: endDate) : self.dateTimeString(now: endDate)
        
        return (startDateString, endDateString)
    } // func longStartAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String, endDateString: String)
        
    var supportsExternalEvents: Bool {
        return self.calendar.usesISOTime && self.isICalendarCompatible
    }
} // extension ASAClock


// MARK:  -

extension Array where Element == ASAClock {
    func processed(now:  Date) -> Array<ASAProcessedClock> {
        var result:  Array<ASAProcessedClock> = []

        for row in self {
            let processedClock = ASAProcessedClock(clock: row, now: now, isForComplications: false)
            result.append(processedClock)
        }

        return result
    } // func processed(now:  Date) -> Array<ASAProcessedClock>

    var byLocation: Array<ASALocationWithClocks> {
        var result:  Array<ASALocationWithClocks> = []

        for clock in self {
            let key = clock.locationData
            let index = result.firstIndex(where: {$0.location == key})
            if index == nil {
                result.append(ASALocationWithClocks(location: key, clocks: [clock], usesDeviceLocation: clock.usesDeviceLocation))
            } else {
                let itemAtIndex = result[index!]
                itemAtIndex.clocks.append(clock)
                result[index!] = itemAtIndex
            }
        } // for for clock in self

        return result
    } // func clocksByPlaceName(now:  Date) -> Array<ASALocationWithClocks>

    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }
} // extension Array where Element == ASAClock
