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

let TIME_ZONE_KEY: String              = "timeZone"
let USES_DEVICE_LOCATION_KEY: String   = "usesDeviceLocation"
let LATITUDE_KEY: String               = "latitude"
let LONGITUDE_KEY: String              = "longitude"
let ALTITUDE_KEY: String               = "altitude"
let HORIZONTAL_ACCURACY_KEY: String    = "haccuracy"
let VERTICAL_ACCURACY_KEY: String      = "vaccuracy"
let PLACE_NAME_KEY: String             = "placeName"
let LOCALITY_KEY                       = "locality"
let COUNTRY_KEY                        = "country"
let ISO_COUNTRY_CODE_KEY               = "ISOCountryCode"
let POSTAL_CODE_KEY: String            = "postalCode"
let ADMINISTRATIVE_AREA_KEY: String    = "administrativeArea"
let SUBADMINISTRATIVE_AREA_KEY: String = "subAdministrativeArea"
let SUBLOCALITY_KEY: String            = "subLocality"
let THOROUGHFARE_KEY: String           = "thoroughfare"
let SUBTHOROUGHFARE_KEY: String        = "subThoroughfare"
let TYPE_KEY: String                   = "type"

let UUID_KEY: String                      = "UUID"
let LOCALE_KEY: String                    = "locale"
let CALENDAR_KEY: String                  = "calendar"
let DATE_FORMAT_KEY: String               = "dateFormat"
let TIME_FORMAT_KEY: String               = "timeFormat"
let BUILT_IN_EVENT_CALENDARS_KEY: String  = "builtInEventCalendars"
let ICALENDAR_EVENT_CALENDARS_KEY: String = "iCalendarEventCalendars"


// MARK:  -

class ASAClock: NSObject, ObservableObject, Identifiable {
    var uuid = UUID()

    @Published var localeIdentifier:  String = ""
    
    
    // MARK: -
    
    override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleStoreChanged(notification:)), name: .EKEventStoreChanged, object: nil)
    } // override init()
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    } // deinit
    
    
    @objc func handleStoreChanged(notification:  Notification) -> Void {
        self.clearCacheObjects()
    } // func handleStoreChanged(notification:  Notification) -> Void

    public func enforceSelfConsistency(location: ASALocation, usesDeviceLocation: Bool) {
        if !self.isICalendarCompatible(location: location, usesDeviceLocation: usesDeviceLocation) {
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
            enforceDateAndTimeFormatSelfConsistency()

            if !startingUp {
                self.clearCacheObjects()
            }
        } // didSet
    } // var calendar

    public func enforceDateAndTimeFormatSelfConsistency() {
        if !self.calendar.supportedDateFormats.contains(self.dateFormat) && !self.calendar.supportedWatchDateFormats.contains(self.dateFormat) {
            self.dateFormat = self.calendar.defaultDateFormat
        }
        
        if !self.calendar.supportedTimeFormats.contains(self.timeFormat) {
            self.timeFormat = self.calendar.defaultTimeFormat
        }
    }
    
    @Published var dateFormat:  ASADateFormat = .full {
        didSet {
            enforceDateAndTimeFormatSelfConsistency()
            
            if !startingUp {
                self.clearCacheObjects()
            }
        } // didSet
    } // var dateFormat

    @Published var timeFormat:  ASATimeFormat = .medium {
        didSet {
            enforceDateAndTimeFormatSelfConsistency()

            if !startingUp {
                self.clearCacheObjects()
            }
        } // didSet
    } // var timeFormat

    @Published var builtInEventCalendars:  Array<ASAEventCalendar> = [] {
        didSet {
            if !startingUp {
                self.clearCacheObjects()
            }
        } // didSet
    } // var builtInEventCalendars

    @Published var iCalendarEventCalendars:  Array<EKCalendar> = [] {
        didSet {
            if !startingUp {
                self.clearCacheObjects()
            }
        } // didSet
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
        
    public func dictionary(forComplication:  Bool, location: ASALocation, usesDeviceLocation: Bool) ->  Dictionary<String, Any> {
        //        debugPrint(#file, #function)

        var result = [
            UUID_KEY:  uuid.uuidString,
            LOCALE_KEY:  localeIdentifier,
            CALENDAR_KEY:  calendar.calendarCode.rawValue,
            DATE_FORMAT_KEY:  dateFormat.rawValue ,
            TIME_FORMAT_KEY:  timeFormat.rawValue ,
            TIME_ZONE_KEY:  location.timeZone.identifier,
            BUILT_IN_EVENT_CALENDARS_KEY:  self.builtInEventCalendars.map{ $0.fileName },
            USES_DEVICE_LOCATION_KEY:  usesDeviceLocation
        ] as [String : Any]

        if self.isICalendarCompatible(location: location, usesDeviceLocation: usesDeviceLocation) && !forComplication {
            result[ICALENDAR_EVENT_CALENDARS_KEY] =  self.iCalendarEventCalendars.map{ $0.title }
        }
        
        result[LATITUDE_KEY] = location.location.coordinate.latitude
        result[LONGITUDE_KEY] = location.location.coordinate.longitude
        result[ALTITUDE_KEY] = location.location.altitude
        result[HORIZONTAL_ACCURACY_KEY] = location.location.horizontalAccuracy
        result[VERTICAL_ACCURACY_KEY] = location.location.verticalAccuracy

        if location.name != nil {
            result[PLACE_NAME_KEY] = location.name
        }
        if location.locality != nil {
            result[LOCALITY_KEY] = location.locality
        }
        if location.country != nil {
            result[COUNTRY_KEY] = location.country
        }
        if location.regionCode != nil {
            result[ISO_COUNTRY_CODE_KEY] = location.regionCode
        }
        
        if location.postalCode != nil {
            result[POSTAL_CODE_KEY] = location.postalCode
        }
        
        if location.administrativeArea != nil {
            result[ADMINISTRATIVE_AREA_KEY] = location.administrativeArea
        }

        if location.subAdministrativeArea != nil {
            result[SUBADMINISTRATIVE_AREA_KEY] = location.subAdministrativeArea
        }

        if location.subLocality != nil {
            result[SUBLOCALITY_KEY] = location.subLocality
        }

        if location.thoroughfare != nil {
            result[THOROUGHFARE_KEY] = location.thoroughfare
        }

        if location.subThoroughfare != nil {
            result[SUBTHOROUGHFARE_KEY] = location.subThoroughfare
        }
        
        result[TYPE_KEY] = location.type.rawValue

        //        debugPrint(#file, #function, result)
        return result
    } // func dictionary(forComplication:  Bool, location: ASALocation, usesDeviceLocation: Bool) ->  Dictionary<String, Any>

    private var startingUp = true
    
    public class func new(dictionary:  Dictionary<String, Any>) -> (clock: ASAClock, location: ASALocation, usesDeviceLocation: Bool) {
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
//        newClock.usesDeviceLocation = usesDeviceLocation ?? true
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
        
        let rawType = dictionary[TYPE_KEY] as? String
        let type: ASALocationType = (rawType == nil) ? .EarthLocation : ASALocationType(rawValue: rawType!)!

        let newLocationData = ASALocation(id: UUID(), location: newLocation, name: newName, locality: newLocality, country: newCountry, regionCode: newISOCountryCode, postalCode: newPostalCode, administrativeArea: newAdministrativeArea, subAdministrativeArea: newSubAdministrativeArea, subLocality: newSubLocality, thoroughfare: newThoroughfare, subThoroughfare: newSubThoroughfare, timeZone: TimeZone(identifier: timeZoneIdentifier!) ?? TimeZone.GMT, type: type)

        newClock.startingUp = false
        newClock.enforceSelfConsistency(location: newLocationData, usesDeviceLocation: usesDeviceLocation ?? false)
        return (newClock, newLocationData, usesDeviceLocation ?? false)
    } // class func new(dictionary:  Dictionary<String, Any>) -> (clock: ASAClock, location: ASALocation, usesDeviceLocation: Bool)


    // MARK:  -

    func events(startDate:  Date, endDate:  Date, locationData: ASALocation, usesDeviceLocation: Bool) -> (dateEvents: Array<ASAEventCompatible>, timeEvents: Array<ASAEventCompatible>) {
        if self.eventCacheStartDate == startDate && self.eventCacheEndDate == endDate {
            return self.eventCacheValue
        }

//        debugPrint(#file, #function, self.calendar.calendarCode, self.locationData.formattedOneLineAddress, "Did not find events in cache")

        var unsortedDateEvents: [ASAEventCompatible] = []
        var unsortedTimeEvents: [ASAEventCompatible] = []
        
        let currentLocaleIdentifier: String = Locale.current.identifier
        let regionCode = locationData.regionCode
        for eventCalendar in self.builtInEventCalendars {
            let eventCalendarName: String = eventCalendar.eventCalendarNameWithPlaceName(locationData: locationData, localeIdentifier: currentLocaleIdentifier)
            let eventCalendarNameWithoutLocation: String = eventCalendar.eventCalendarNameWithoutPlaceName(localeIdentifier: currentLocaleIdentifier)
            let eventCalendarEvents = eventCalendar.events(startDate: startDate, endDate: endDate, locationData: locationData, eventCalendarName: eventCalendarName, calendarTitle: eventCalendarNameWithoutLocation, regionCode: regionCode, requestedLocaleIdentifier: self.localeIdentifier, calendar: self.calendar, clock: self)
            unsortedDateEvents.add(events: eventCalendarEvents.dateEvents)
            unsortedTimeEvents.add(events: eventCalendarEvents.timeEvents)
        } // for eventCalendar in self.builtInEventCalendars
        
        if self.isICalendarCompatible(location: locationData, usesDeviceLocation: usesDeviceLocation) && self.iCalendarEventCalendars.count > 0 {
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

    func isICalendarCompatible(location: ASALocation, usesDeviceLocation: Bool) -> Bool {
        return self.calendar.usesISOTime && (usesDeviceLocation || location.timeZone.isCurrent)
    }
    
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
    
    func weekendDays(location: ASALocation) -> Array<Int>? {
        if self.calendar is ASACalendarSupportingWeeks {
            let calendarSupportingWeeks = self.calendar as! ASACalendarSupportingWeeks
            return calendarSupportingWeeks.weekendDays(for: location.regionCode)

        } else {
            return nil
        }
    } // func weekendDays(location: ASALocation) -> Array<Int>?
    
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
    public func dateStringTimeStringDateComponents(now: Date, location: ASALocation) -> (dateString: String, timeString: String?, dateComponents: ASADateComponents) {
        let properDateFormat = self.dateFormat
        return self.calendar.dateStringTimeStringDateComponents(now: now, localeIdentifier: self.localeIdentifier, dateFormat: properDateFormat, timeFormat: self.timeFormat, locationData: location)
    }

    public func dateString(now:  Date, location: ASALocation) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: self.dateFormat, timeFormat: .none, locationData: location)
    } // func dateTimeString(now:  Date) -> String

    public func dateTimeString(now:  Date, location: ASALocation) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: self.dateFormat, timeFormat: self.timeFormat, locationData: location)
    } // func dateTimeString(now:  Date) -> String
    
    func startOfDay(date:  Date, location: ASALocation) -> Date {
        return self.calendar.startOfDay(for: date, locationData: location)
    } // func startODay(date:  Date) -> Date

    func startOfNextDay(date:  Date, location: ASALocation) -> Date {
        return self.calendar.startOfNextDay(date: date, locationData: location)
    } // func startOfNextDay(now:  Date) -> Date

    public func timeString(now:  Date, location: ASALocation) -> String {
        return self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .none, timeFormat: self.timeFormat, locationData: location)
    } // func timeString(now:  Date) -> String
    
    public var supportsLocales:  Bool {
        return self.calendar.supportsLocales
    } // var supportsLocales:  Bool

//    public func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, location: ASALocation) -> ASADateComponents {
//        self.calendar.dateComponents(components, from: date, locationData: location)
//    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData:  ASALocation) -> ASADateComponents

    public func shortenedDateTimeString(now:  Date, location: ASALocation) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.shortened
        let timeFormat: ASATimeFormat = self.timeFormat
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: location)
        return result
    } // func shortenedDateTimeString(now:  Date) -> String

    public func shortenedDateString(now:  Date, location: ASALocation) -> String {
        let dateFormat: ASADateFormat = self.dateFormat.shortened
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: location)
        return result
    } // func shortenedDateString(now:  Date) -> String
    
    public func yearOnlyDateString(now:  Date, location: ASALocation) -> String {
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .shortYearOnly, timeFormat: .none, locationData: location)
        return result
    } // func yearOnlyDateString(now:  Date, location: ASALocation) -> String
    
    public func yearAndMonthOnlyDateString(now:  Date, location: ASALocation) -> String {
        let result: String = self.calendar.dateTimeString(now: now, localeIdentifier: self.localeIdentifier, dateFormat: .shortYearAndMonthOnly, timeFormat: .none, locationData: location)
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
    public func updateWithGenericBuiltInEventCalendars(regionCode: String) {
        let builtInCalendarNames = self.calendar.calendarCode.genericBuiltInEventCalendarNames(regionCode: regionCode)
        for fileName in builtInCalendarNames {
            let newEventCalendar = ASAEventCalendar(fileName: fileName)
            if newEventCalendar.eventsFile != nil {
                self.builtInEventCalendars.append(newEventCalendar)
            }
        } // for fileName in builtInCalendarNames
    }
    
    static func generic(calendarCode:  ASACalendarCode, dateFormat:  ASADateFormat, regionCode: String) ->  ASAClock {
        let clock = ASAClock.generic(calendarCode: calendarCode, dateFormat: .full)
        var code: String? = regionCode
        repeat {
        clock.updateWithGenericBuiltInEventCalendars(regionCode: code!)
        code = code!.superregionCode
        } while code != nil
        return clock
    } // static func generic(calendarCode:  ASACalendarCode, dateFormat:  ASADateFormat, regionCode: String) ->  ASAClock
    
    static func generic(calendarCode:  ASACalendarCode, dateFormat:  ASADateFormat) ->  ASAClock {
        let temp = ASAClock()
        temp.calendar = ASACalendarFactory.calendar(code: calendarCode)!
        temp.localeIdentifier = ""
        temp.dateFormat = dateFormat
        return temp
    } // static func generic(calendarCode:  ASACalendarCode) ->  ASAClock

    static var generic:  ASAClock {
        return ASAClock.generic(calendarCode: .Gregorian, dateFormat: .full)
    } // static var generic:  ASAClock
} // extension ASAClock

//extension ASAClock {
//    public func countryCodeEmoji(date:  Date) -> String {
//        let regionCode: String = self.locationData.regionCode ?? ""
//        let result: String = regionCode.flag
////        debugPrint(#file, #function, "Region code:", regionCode, "Flag:", result)
//        return result
//    } // public func countryCodeEmoji(date:  Date) -> String
//} // extension ASAClock

class ASAStartAndEndDateStrings {
    var startDateString: String?
    var endDateString: String
    
    init(startDateString: String?, endDateString: String) {
        self.startDateString = startDateString
        self.endDateString   = endDateString
    }
}

extension ASAClock {
    func properlyShortenedString(date:  Date, eventIsTodayOnly: Bool, eventIsAllDay: Bool, location: ASALocation) -> String {
        return (eventIsTodayOnly && !eventIsAllDay) ? self.timeString(now: date, location: location) : self.shortenedDateTimeString(now: date, location: location)
     } // func properlyShortenedString(date:  Date, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> String
    
    private func genericStartAndEndDateStrings(event: ASAEventCompatible,                                               eventIsTodayOnly: Bool, location: ASALocation) -> (startDateString: String?, endDateString: String) {
        var startDateString: String?
        var endDateString: String
        
        if event.startDate == event.endDate {
            startDateString = nil
        } else {
            startDateString = self.properlyShortenedString(date: event.startDate, eventIsTodayOnly: eventIsTodayOnly, eventIsAllDay: event.isAllDay, location: location)
        }
        endDateString = self.properlyShortenedString(date: event.endDate ?? event.startDate, eventIsTodayOnly: eventIsTodayOnly, eventIsAllDay: event.isAllDay, location: location)
        
        return (startDateString, endDateString)
    } // func genericStartAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String?, endDateString: String)
    
    public func startAndEndDateStrings(event: ASAEventCompatible, eventIsTodayOnly: Bool, location: ASALocation) -> (startDateString: String?, endDateString: String) {
        // Cache code
        if let cachedVersion = startAndEndDateStringsCache.object(forKey: event.eventIdentifier! as NSString) {
            // use the cached version
            return (cachedVersion.startDateString, cachedVersion.endDateString)
        }
        
        var startDateString: String?
        var endDateString: String
        
        let eventIsAllDay = event.isAllDay(for: self, location: location)
        if !eventIsAllDay {
            (startDateString, endDateString) = genericStartAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location)
        } else {
            switch event.type {
            case .multiYear:
                startDateString = self.yearOnlyDateString(now: event.startDate, location: location)
                endDateString = self.yearOnlyDateString(now: event.endDate - 1, location: location)
            case .oneYear:
                startDateString = nil
                endDateString = self.yearOnlyDateString(now: event.startDate, location: location)
            case .multiMonth:
                startDateString = self.yearAndMonthOnlyDateString(now: event.startDate, location: location)
                endDateString = event.endDate == nil ? "???" : self.yearAndMonthOnlyDateString(now: event.endDate - 1, location: location)
            case .oneMonth:
                startDateString = nil
                endDateString = self.yearAndMonthOnlyDateString(now: event.startDate, location: location)
            case .multiDay:
                startDateString = self.shortenedDateString(now: event.startDate, location: location)
                endDateString = event.endDate == nil ? "???" : self.shortenedDateString(now: event.endDate - 1, location: location)
            case .oneDay:
                startDateString = nil
                endDateString = self.shortenedDateString(now: event.startDate + (event.endDate.timeIntervalSince(event.startDate) / 2), location: location)
            default:
                (startDateString, endDateString) = genericStartAndEndDateStrings(event: event, eventIsTodayOnly: eventIsTodayOnly, location: location)
            } // switch event.type
        }
        
        // create it from scratch then store in the cache
        let myObject = ASAStartAndEndDateStrings(startDateString: startDateString, endDateString: endDateString)
        startAndEndDateStringsCache.setObject(myObject, forKey: event.eventIdentifier! as NSString)

        return (startDateString, endDateString)
    } // func startAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String, endDateString: String)
    
    public func longStartAndEndDateStrings(event: ASAEventCompatible, eventIsTodayOnly: Bool, location: ASALocation) -> (startDateString: String, endDateString: String) {
        let eventIsAllDay = event.isAllDay(for: self, location: location)
        let startDateString = eventIsAllDay ? self.dateString(now: event.startDate, location: location) : self.dateTimeString(now: event.startDate, location: location)
        let endDate: Date = event.endDate - 1
        let endDateString = eventIsAllDay ? self.dateString(now: endDate, location: location) : self.dateTimeString(now: endDate, location: location)
        
        return (startDateString, endDateString)
    } // func longStartAndEndDateStrings(event: ASAEventCompatible, isPrimaryClock: Bool, eventIsTodayOnly: Bool) -> (startDateString: String, endDateString: String)
        
    func supportsExternalEvents(location: ASALocation, usesDeviceLocation: Bool) -> Bool {
        return self.calendar.usesISOTime && self.isICalendarCompatible(location: location, usesDeviceLocation: usesDeviceLocation)
    }
    
    var eventsShouldShowSecondaryDates: Bool {
        return self.calendar.calendarCode != .Gregorian
    }
} // extension ASAClock


// MARK:  -

extension Array where Element == ASAClock {
    func processed(now:  Date, location: ASALocation, usesDeviceLocation: Bool) -> Array<ASAProcessedClock> {
        var result:  Array<ASAProcessedClock> = []

        for row in self {
            let processedClock = ASAProcessedClock(clock: row, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
            result.append(processedClock)
        }

        return result
    } // func processed(now:  Date) -> Array<ASAProcessedClock>

    fileprivate func noCountryString() -> String {
        return NSLocalizedString("NO_COUNTRY_OR_REGION", comment: "")
    }
} // extension Array where Element == ASAClock
