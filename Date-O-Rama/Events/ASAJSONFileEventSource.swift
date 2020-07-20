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

extension ASADateComponents {
    func matches(startDateSpecification:  ASADateSpecification, recurrenceRules:  Array<ASARecurrenceRule>?) -> Bool {
        let supportsYear: Bool = self.calendar.supports(calendarComponent: .year)
        let supportsMonth: Bool = self.calendar.supports(calendarComponent: .month)
        let supportsDay: Bool = self.calendar.supports(calendarComponent: .day)
        
        // Perfect matching
        if supportsDay {
            if self.day == startDateSpecification.day {
                if supportsYear && supportsMonth {
                    if self.year == startDateSpecification.year && self.month == startDateSpecification.month {
                        return true
                    }
                } else {
                    return true
                }
            }
        } else {
            debugPrint(#file, #function, "Somehow this calendar doesn’t have days!")
        }
        
        // Recurring events
        
        
        let hasRecurrenceRules = recurrenceRules != nil && recurrenceRules?.count ?? 0 >= 1
        
        let recurrenceRule = hasRecurrenceRules ? recurrenceRules![0] : nil
        
        return false
    } // func matches(startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?) -> Bool
} // extension ASADateComponents


// MARK: -

class ASAJSONFileEventSource:  ASAInternalEventSource {
    var eventsFile:  ASAInternalEventsFile?
    
    init(fileName:  String) {
        let fileURL = Bundle.main.url(forResource:fileName, withExtension: "json")!
        
             let jsonData = (try? Data(contentsOf: fileURL))!
            let newJSONDecoder = JSONDecoder()
        do {
            let eventsFile = try newJSONDecoder.decode(ASAInternalEventsFile.self, from: jsonData)
            self.eventsFile = eventsFile
        } catch {
            debugPrint(#file, #function, error)
        }
    }
    
    var eventSourceCode: ASAInternalEventSourceCode {
        get {
            return ASAInternalEventSourceCode.init(rawValue: self.eventsFile!.eventSourceCode.rawValue)!
        }
    }
    
    func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocationData, eventCalendarName: String) -> Array<ASAEvent> {
//        let location = locationData.location!
//        let timeZone = locationData.timeZone!
        
//        debugPrint(#file, #function, startDate, endDate, location, timeZone)
        var now = startDate.noon(timeZone: locationData.timeZone!).oneDayBefore
        var result:  Array<ASAEvent> = []
        var oldNow = now
        repeat {
            let temp = self.eventDetails(date: now, locationData: locationData, eventCalendarName: eventCalendarName)
            for event in temp {
//                debugPrint(#file, #function, startDate, endDate, event.title ?? "No title", event.startDate ?? "No start date", event.endDate ?? "No end date")
                
                if !(event.endDate < startDate || event.startDate >= endDate) {
                    result.append(event)
                }
            } // for event in tempResult
            oldNow = now
            now = now.oneDayAfter
        } while oldNow < endDate
        
        return result
    } // func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocationData, eventCalendarName: String) -> Array<ASAEvent>
    
    fileprivate func calendarColor() -> Color {
        return Color(self.eventsFile!.calendarColor)
    } // static func calendarColor() -> Color
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocationData, startDateSpecification:  ASADateSpecification, recurrenceRules:  Array<ASARecurrenceRule>?) -> Bool {
        let components = calendar.dateComponents([.year, .month, .day, .weekday
//            , .weekOfYear, .weekOfMonth
        ], from: date, locationData: locationData)

        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
        let supportsDay: Bool = calendar.supports(calendarComponent: .day)
        
        // Perfect matching
        if supportsDay {
            if components.day == startDateSpecification.day {
                if supportsYear && supportsMonth {
                    if components.year == startDateSpecification.year && components.month == startDateSpecification.month {
                        return true
                    }
                } else {
                    return true
                }
            }
        } else {
            debugPrint(#file, #function, "Somehow this calendar doesn’t have days!")
        }
                
        // Recurring events
        let hasRecurrenceRules = recurrenceRules != nil && recurrenceRules?.count ?? 0 >= 1

        if !hasRecurrenceRules {
            return false
        }

        if supportsYear && supportsMonth {
            if startDateSpecification.year > components.year! {
                return false
            }
            
            if startDateSpecification.year == components.year! {
                if startDateSpecification.month > components.month! {
                    return false
                }
                
                if startDateSpecification.month == components.month! {
                    if startDateSpecification.day > components.day! {
                        return false
                    }
                }

            }
        } else {
            if startDateSpecification.day > components.day! {
                return false
            }
        }
        
        
        let recurrenceRule = hasRecurrenceRules ? recurrenceRules![0] : nil
        
        switch recurrenceRule?.frequency {
        case .daily:
            if recurrenceRule?.interval == 1 {  // TODO:  Support other intervals
                return true
            } else {
                return false
            }
            
        case .weekly:
            if recurrenceRule?.interval == 1 { // TODO:  Support other
                if recurrenceRule?.daysOfTheWeek != nil {  // TODO:  Is this neccessary?
                    for dayOfTheWeek in recurrenceRule!.daysOfTheWeek! {
                        if dayOfTheWeek.weekNumber == 0 { // TODO:  Support specific weeks of the year
                            if dayOfTheWeek.dayOfTheWeek.rawValue == components.weekday! {
                                debugPrint(#file, #function, date, locationData, components, recurrenceRule as Any)
                                
                                return true
                            }
                        }
                    }
                    return false
                    
                }
                
            } else {
                return false
            }
            
        default:
            return false
        }
        
        return false
    } //
    
    func eventDetails(date:  Date, locationData:  ASALocationData, eventCalendarName: String) -> Array<ASAEvent> {
        let location = locationData.location!
        let timeZone = locationData.timeZone!
        
        let latitude  = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let calendarCode:  ASACalendarCode = (self.eventsFile?.calendarCode != nil ? self.eventsFile?.calendarCode : ASACalendarCode.Gregorian)!
        let calendar = ASACalendarFactory.calendar(code: calendarCode)
//        let components = calendar?.dateComponents([.year, .month,.day, .weekday, .weekOfYear, .weekOfMonth], from: date, locationData: locationData)
//        if components == nil {
//            return []
//        }
        
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
            if self.match(date: date, calendar: calendar!, locationData: locationData, startDateSpecification: eventSpecification.startDateSpecification, recurrenceRules: eventSpecification.recurrenceRules) {
                let title = eventSpecification.localizableTitle != nil ? NSLocalizedString(eventSpecification.localizableTitle!, comment: "") :  eventSpecification.title
                let color = self.calendarColor()
                let startDate = eventSpecification.startDateSpecification.date(date: date, latitude: latitude, longitude: longitude, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength)
                let endDate = eventSpecification.endDateSpecification == nil ? startDate : eventSpecification.endDateSpecification!.date(date: date, latitude: latitude, longitude: longitude, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength)
                let newEvent = ASAEvent(title:  title, startDate: startDate, endDate: endDate, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitle: eventCalendarName)
                result.append(newEvent)
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
    func date(date:  Date, latitude: Double, longitude:  Double, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double) -> Date? {
        switch self.type {
        case .degreesBelowHorizon:
            let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)
            
            let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
            let result = events[solarEvent]
            
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
        } // switch self.type
    } // func date(date:  Date, latitude: Double, longitude:  Double, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double) -> Date?
} // extension ASADateSpecification
