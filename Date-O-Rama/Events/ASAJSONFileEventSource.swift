//
//  ASAJSONFileEventSource.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

class ASAJSONFileEventSource {
    var eventsFile:  ASAInternalEventsFile?
    
    init(fileName:  String) {
        do {
            var fileURL = Bundle.main.url(forResource:fileName, withExtension: "json")
            if fileURL == nil {
                debugPrint(#file, #function, fileName, "Could not open!")
                
                fileURL = Bundle.main.url(forResource:"Solar events", withExtension: "json")
            }
            
            let jsonData = (try? Data(contentsOf: fileURL!))!
                let newJSONDecoder = JSONDecoder()

            let eventsFile = try newJSONDecoder.decode(ASAInternalEventsFile.self, from: jsonData)
            self.eventsFile = eventsFile
        } catch {
            debugPrint(#file, #function, fileName, error)
        }
    }
    
//    var eventSourceCode: String
    
    func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocationData, eventCalendarName: String, ISOCountryCode:  String?, requestedLocaleIdentifier:  String) -> Array<ASAEvent> {
        //        debugPrint(#file, #function, startDate, endDate, location, timeZone)
        let calendar = ASACalendarFactory.calendar(code: eventsFile!.calendarCode!)
//        var now = startDate.noon(timeZone: locationData.timeZone!).oneDayBefore
        let timeZone: TimeZone = locationData.timeZone ?? TimeZone.autoupdatingCurrent
        var now:  Date = calendar?.startOfDay(for: startDate, location: locationData.location, timeZone: timeZone) ?? startDate
        var result:  Array<ASAEvent> = []
        var oldNow = now
        repeat {
            let startOfDay:  Date = (calendar?.startOfDay(for: now, location: locationData.location, timeZone: timeZone))!
            let startOfNextDay:  Date = (calendar?.startOfNextDay(date: now, location: locationData.location, timeZone: timeZone))!
            let temp = self.eventDetails(date: now, locationData: locationData, eventCalendarName: eventCalendarName, calendar: calendar!, ISOCountryCode: ISOCountryCode, requestedLocaleIdentifier: requestedLocaleIdentifier, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
            for event in temp {
                //                debugPrint(#file, #function, startDate, endDate, event.title ?? "No title", event.startDate ?? "No start date", event.endDate ?? "No end date")
                
                if event.relevant(startDate:  startDate, endDate:  endDate) && !result.contains(event) {
                    result.append(event)
                }
            } // for event in tempResult
            oldNow = now
            now = now.oneDayAfter
        } while oldNow <= endDate
        
        return result
    } // func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocationData, eventCalendarName: String) -> Array<ASAEvent>
    
    fileprivate func calendarColor() -> Color {
        return Color(self.eventsFile!.calendarColor)
    } // static func calendarColor() -> Color

    func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar) -> ASADateSpecification {
        var tweakedDateSpecification = dateSpecification
        if tweakedDateSpecification.day ?? 1 < 0 {
            let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)
            let numberOfDaysInMonth = rangeOfDaysInMonth!.count
            tweakedDateSpecification.day! += (numberOfDaysInMonth + 1)
        }
        return tweakedDateSpecification
    } // func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar) -> ASADateSpecification
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocationData, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
//        var tweakedStartDateSpecification = startDateSpecification
//        if tweakedStartDateSpecification.day ?? 1 < 0 {
//            let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)
//            let numberOfDaysInMonth = rangeOfDaysInMonth!.count
//            tweakedStartDateSpecification.day! += (numberOfDaysInMonth + 1)
//        }
        let tweakedStartDateSpecification = self.tweak(dateSpecification: startDateSpecification, date: date, calendar: calendar)

        if endDateSpecification == nil {
            let matches = self.match(date: date, calendar: calendar, locationData: locationData, startDateSpecification: tweakedStartDateSpecification)
            return (matches, nil, nil)
        }

        let tweakedEndDateSpecification = self.tweak(dateSpecification: endDateSpecification!, date: date, calendar: calendar)
        
                let components = calendar.dateComponents([.year, .month, .day, .weekday
        //            , .weekOfYear, .weekOfMonth
                ], from: date, locationData: locationData)
        let eventStartDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false)
        if eventStartDate == nil {
            return (false, nil, nil)
        }
        let eventEndDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true)
        if eventEndDate == nil {
            return (false, nil, nil)
        }
        
        if !self.matchYearSupplemental(date: date, components: components, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }
        if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }
        
        let timeZone: TimeZone = locationData.timeZone ?? TimeZone.autoupdatingCurrent
        let dateStartOfDay = calendar.startOfDay(for: date, location: locationData.location, timeZone: timeZone)
        let dateEndOfDay = calendar.startOfNextDay(date: date, location: locationData.location, timeZone: timeZone)

        if eventStartDate == eventEndDate && eventStartDate == dateStartOfDay {
            return (true, eventStartDate, eventEndDate)
        }
        
        if dateEndOfDay <= eventStartDate! {
            return (false, nil, nil)
        }

        if dateStartOfDay >= eventEndDate! {
            return (false, nil, nil)
        }
        
        return (true, eventStartDate, eventEndDate)
    }
    
    func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfYear != nil {
            let rangeOfDaysInYear = calendar.range(of: .day, in: .year, for: date)
            let numberOfDaysInYear = rangeOfDaysInYear!.count
            //            debugPrint(#file, #function, rangeOfDaysInYear as Any, numberOfDaysInYear as Any)
            if !numberOfDaysInYear.matches(dateSpecification.lengthsOfYear) {
                return false
            }
        }
        
        if dateSpecification.dayOfYear != nil {
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)
            if dayOfYear == nil {
                return false
            }
            if !dayOfYear!.matches(dateSpecification.dayOfYear) {
                return false
            }
        }
        
        return true
    } // func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfMonth != nil {
            let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)
            let numberOfDaysInMonth = rangeOfDaysInMonth!.count
            if !numberOfDaysInMonth.matches(dateSpecification.lengthsOfMonth) {
                return false
            }
        }
        
        return true
    } // func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocationData, startDateSpecification:  ASADateSpecification) -> Bool {
        let components = calendar.dateComponents([.year, .month, .day, .weekday
//            , .weekOfYear, .weekOfMonth
        ], from: date, locationData: locationData)
        var tweakedStartDateSpecification = startDateSpecification
        if tweakedStartDateSpecification.day ?? 1 < 0 {
            let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)
            let numberOfDaysInMonth = rangeOfDaysInMonth!.count
            tweakedStartDateSpecification.day! += (numberOfDaysInMonth + 1)
        }

        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
        if supportsYear {
            if !(components.year?.matches(tweakedStartDateSpecification.year) ?? false) {
                return false
            }
            
            if !self.matchYearSupplemental(date: date, components: components, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
                return false
            }
        }
        
        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
        if supportsMonth {
            if !(components.month?.matches(tweakedStartDateSpecification.month) ?? false) {
                return false
            }
            
            if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
                return false
            }
        }
        
        let supportsDay: Bool = calendar.supports(calendarComponent: .day)
        if supportsDay {
            if !(components.day?.matches(tweakedStartDateSpecification.day) ?? false) {
                return false
            }
        }
        
        let supportsWeekday: Bool = calendar.supports(calendarComponent: .weekday)
        if supportsWeekday {
            if !(components.weekday?.matches(tweakedStartDateSpecification.weekdays) ?? false) {
                return false
            }
        }

        return true
    } // func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocationData, startDateSpecification:  ASADateSpecification) -> Bool
    
    func eventDetails(date:  Date, locationData:  ASALocationData, eventCalendarName: String, calendar:  ASACalendar, ISOCountryCode:  String?, requestedLocaleIdentifier:  String, startOfDay:  Date, startOfNextDay:  Date) -> Array<ASAEvent> {
        let location = locationData.location!
        let timeZone = locationData.timeZone!
        
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        let previousDate = date.oneDayBefore
        let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [.sunset, .dusk72Minutes], timeZone:  timeZone)
        let previousSunset:  Date = previousEvents[.sunset]!! // שקיעה
        let previousOtherDusk:  Date = previousEvents[.dusk72Minutes]!!
        
        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [.sunrise, .sunset, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
        
        // According to the גר״א
        let sunrise:  Date = events[.sunrise]!! // נץ
        let sunset:  Date = events[.sunset]!! // שקיעה
        
        let nightLength = sunrise.timeIntervalSince(previousSunset)
        let nightHourLength = nightLength / 12.0
        
        let dayLength = sunset.timeIntervalSince(sunrise)
        let hourLength = dayLength / 12.0
        
        // According to the מגן אברהם
        let otherDawn = events[.dawn72Minutes]!! // עלות השחר
        let otherDusk = events[.dusk72Minutes]!! // צאת הכוכבים
        
        let otherNightLength = otherDawn.timeIntervalSince(previousOtherDusk)
        let otherNightHourLength = otherNightLength / 12.0
        
        let otherDayLength = otherDusk.timeIntervalSince(otherDawn)
        let otherHourLength = otherDayLength / 12.0
        
        var result:  Array<ASAEvent> = []
        for eventSpecification in self.eventsFile!.eventSpecifications {
            let (matchesDateSpecifications, returnedStartDate, returnedEndDate) = self.match(date: date, calendar: calendar, locationData: locationData, startDateSpecification: eventSpecification.startDateSpecification, endDateSpecification: eventSpecification.endDateSpecification)
            if matchesDateSpecifications {
                let matchesCountryCode: Bool = eventSpecification.match(ISOCountryCode: ISOCountryCode)
                if matchesCountryCode {
                    let title = eventSpecification.eventTitle(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let color = self.calendarColor()
                    var startDate = returnedStartDate
                    var endDate = returnedEndDate
                    if startDate == nil {
                        startDate = eventSpecification.isAllDay ? calendar.startOfDay(for: date, location: location, timeZone: timeZone) : eventSpecification.startDateSpecification.date(date: date, latitude: latitude, longitude: longitude, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
                        endDate = eventSpecification.isAllDay ? (calendar.startOfNextDay(date: date, location: location, timeZone: timeZone)) : (eventSpecification.endDateSpecification == nil ? startDate : eventSpecification.endDateSpecification!.date(date: date, latitude: latitude, longitude: longitude, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay))
                    }
                    let newEvent = ASAEvent(title:  title, startDate: startDate, endDate: endDate, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName, calendarCode: calendar.calendarCode)
                    result.append(newEvent)
                }
            }
        } // for eventSpecification in self.eventsFile.eventSpecifications
        return result
    } // func eventDetails(date:  Date, location:  locationData:  ASALocationData, eventCalendarName: String) -> Array<ASAEvent>
    
    func eventCalendarName(locationData:  ASALocationData) -> String {
        let localizableTitle = self.eventsFile?.localizableTitle
        if localizableTitle != nil {
            return "\(NSLocalizedString(localizableTitle!, comment: "")) • \(locationData.formattedOneLineAddress())"
        } else {
            return "\(self.eventsFile?.title ?? "???") • \(locationData.formattedOneLineAddress())"
        }
    } // func eventCalendarName(locationData:  ASALocationData) -> String
    
    func eventSourceName() -> String {
        let localizableTitle = self.eventsFile?.localizableTitle
        if localizableTitle != nil {
            return NSLocalizedString(localizableTitle!, comment:  "")
        } else {
            return self.eventsFile?.title ?? "???"
        }
    } // func eventSourceName() -> String} // class ASASolarEventSource:  ASAInternalEventSource
} // class ASAJSONFileEventSource


// MARK: -

extension ASADateSpecification {
    fileprivate func dateWithAddedSolarTime(rawDate: Date?, hours: Double, dayHalf: ASATimeSpecificationDayHalf, latitude: CLLocationDegrees, longitude: CLLocationDegrees, timeZone: TimeZone, dayHalfStart: ASASolarEvent, dayHalfEnd: ASASolarEvent) -> Date? {
        switch dayHalf {
        case .night:
            let previousDate = rawDate!.oneDayBefore
            let previousEvents = previousDate.solarEvents(latitude: latitude, longitude: longitude, events: [dayHalfEnd], timeZone:  timeZone)
            let events = rawDate!.solarEvents(latitude: latitude, longitude: longitude, events: [dayHalfStart, dayHalfEnd, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
            
            let previousSunset:  Date = previousEvents[dayHalfEnd]!! // שקיעה
            let sunrise:  Date = events[dayHalfStart]!! // נץ
            let nightLength = sunrise.timeIntervalSince(previousSunset)
            let nightHourLength = nightLength / 12.0
            let result = previousSunset + hours * nightHourLength
            return result
            
        case .day:
            let events = rawDate!.solarEvents(latitude: latitude, longitude: longitude, events: [dayHalfStart, dayHalfEnd, .dawn72Minutes, .dusk72Minutes], timeZone:  timeZone)
            let sunrise:  Date = events[dayHalfStart]!! // נץ
            let sunset:  Date = events[dayHalfEnd]!! // שקיעה
            let dayLength = sunset.timeIntervalSince(sunrise)
            let hourLength = dayLength / 12.0
            let result = sunrise + hours * hourLength
            return result
        }
    }
    
    func date(dateComponents:  ASADateComponents, calendar:  ASACalendar, isEndDate:  Bool) -> Date? {
        var revisedDateComponents = dateComponents
        if self.year != nil {
            revisedDateComponents.year = self.year
        }
        if self.month != nil {
            revisedDateComponents.month = self.month
        }
        if self.day != nil {
            revisedDateComponents.day = self.day
        }
        
        revisedDateComponents.weekday = nil
        
        if !calendar.isValidDate(dateComponents: revisedDateComponents) {
            return nil
        }
        let rawDate = calendar.date(dateComponents: revisedDateComponents)
        if rawDate == nil {
            return nil
        }
        
        let latitude = revisedDateComponents.locationData.location?.coordinate.latitude ?? 0.0
        let longitude = revisedDateComponents.locationData.location?.coordinate.longitude ?? 0.0
        let timeZone = revisedDateComponents.locationData.timeZone  ?? TimeZone.autoupdatingCurrent

        switch self.type {
        case .allDay:
            if isEndDate {
                return calendar.startOfNextDay(date: rawDate!, location: revisedDateComponents.locationData.location, timeZone: revisedDateComponents.locationData.timeZone ?? TimeZone.autoupdatingCurrent)
            } else {
                return calendar.startOfDay(for: rawDate!, location: revisedDateComponents.locationData.location, timeZone: revisedDateComponents.locationData.timeZone ?? TimeZone.autoupdatingCurrent)
            }
        case .degreesBelowHorizon:
            let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)
            let events = rawDate!.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
            let result = events[solarEvent]
            if result == nil {
                return nil
            }
            if result! == nil {
                return nil
            }
            return result!
            
        case .solarTimeSunriseSunset:
            let hours = self.solarHours!
            let dayHalf = self.dayHalf!
            let dayHalfStart = ASASolarEvent.sunrise
            let dayHalfEnd   = ASASolarEvent.sunset
            return dateWithAddedSolarTime(rawDate: rawDate, hours: hours, dayHalf: dayHalf, latitude: latitude, longitude: longitude, timeZone:  timeZone , dayHalfStart:  dayHalfStart, dayHalfEnd:  dayHalfEnd)

        case .solarTimeDawn72MinutesDusk72Minutes:
            let hours = self.solarHours!
            let dayHalf = self.dayHalf!
            let dayHalfStart = ASASolarEvent.dawn72Minutes
            let dayHalfEnd   = ASASolarEvent.dusk72Minutes
            return dateWithAddedSolarTime(rawDate: rawDate, hours: hours, dayHalf: dayHalf, latitude: latitude, longitude: longitude, timeZone:  timeZone , dayHalfStart:  dayHalfStart, dayHalfEnd:  dayHalfEnd)
        } // switch self.type
    } //func date(dateComponents:  ASADateComponents, calendar:  ASACalendar, isEndDate:  Bool) -> Date?

    func rawDegreesBelowHorizon(date:  Date, latitude: Double, longitude:  Double, timeZone:  TimeZone) -> Date? {
        let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)

        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
        let result = events[solarEvent]
        return result!
    }
    
    func date(date:  Date, latitude: Double, longitude:  Double, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double, startOfDay:  Date, startOfNextDay:  Date) -> Date? {
        switch self.type {
        case .degreesBelowHorizon:
//            let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)
//
//            let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
//            let result = events[solarEvent]

            var result = self.rawDegreesBelowHorizon(date: date, latitude: latitude, longitude: longitude, timeZone: timeZone)

            if result! < startOfDay {
                result = self.rawDegreesBelowHorizon(date: date.oneDayAfter, latitude: latitude, longitude: longitude, timeZone: timeZone)
            } else if result! > startOfNextDay {
                result = self.rawDegreesBelowHorizon(date: date.oneDayBefore, latitude: latitude, longitude: longitude, timeZone: timeZone)
            }
            
            return result!
            
        case .solarTimeSunriseSunset:
            let hours = self.solarHours!
            let dayHalf = self.dayHalf!
            switch dayHalf {
            case .night:
                let result = previousSunset + hours * nightHourLength
                return result
                
            case .day:
                let result = sunrise + hours * hourLength
                return result
            } // switch dayHalf
            
        case .solarTimeDawn72MinutesDusk72Minutes:
            let hours = self.solarHours!
            let dayHalf = self.dayHalf!
            switch dayHalf {
            case .night:
                let result = previousOtherDusk + hours * otherNightHourLength
                return result
                
            case .day:
                let result = otherDawn + hours * otherHourLength
                return result
            } // switch dayHalf
            
        case .allDay:
            return date
        } // switch self.type
    } // func date(date:  Date, latitude: Double, longitude:  Double, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double) -> Date?
} // extension ASADateSpecification

extension Int {
    func matches(_ value:  Int?) -> Bool {
        if value == nil {
            return true
        }
        
        return self == value!
    } // func matches(_ value:  Int?) -> Bool
    
    func matches(_ values:  Array<Int>?) -> Bool {
        if values == nil {
            return true
        }
        
        return values!.contains(self)
    } // func matches(_ values:  Array<Int>?) -> Bool
    
    func matches(_ values:  Array<ASAWeekday>?) -> Bool {
        if values == nil {
            return true
        }
        
        return values!.contains(ASAWeekday(rawValue: self)!)
    } // func matches(_ values:  Array<ASAWeekday>?) -> Bool
} // extension Int

