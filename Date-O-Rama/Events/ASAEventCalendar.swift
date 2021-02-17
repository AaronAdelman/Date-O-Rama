//
//  ASAEventCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-26.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

class ASAEventCalendar {
    var fileName:  String
    var eventsFile:  ASAEventsFile?
    var error:  Error?
    var otherCalendars:  Dictionary<ASACalendarCode, ASACalendar> = [:]


    init(fileName:  String) {
        self.fileName = fileName
        (self.eventsFile, self.error) = ASAEventsFile.builtIn(fileName: fileName)

        if eventsFile != nil {
            if eventsFile!.otherCalendarCodes != nil {
                for calendarCode in eventsFile!.otherCalendarCodes! {
                    otherCalendars[calendarCode] = ASACalendarFactory.calendar(code: calendarCode)
                } // for calendarCode in eventsFile!.otherCalendarCodes!
            }
        }
    } // init(fileName:  String)

    func events(startDate: Date, endDate: Date, locationData:  ASALocation, eventCalendarName: String, calendarTitleWithoutLocation:  String, ISOCountryCode:  String?, requestedLocaleIdentifier:  String, calendar:  ASACalendar) -> Array<ASAEvent> {
        //        debugPrint(#file, #function, startDate, endDate, location, timeZone)

        if self.eventsFile == nil {
            // Something went wrong
            return []
        }

        let timeZone: TimeZone = locationData.timeZone 
        var now:  Date = startDate.oneDayBefore
        var result:  Array<ASAEvent> = []
        var oldNow = now
        repeat {
            let startOfDay:  Date = (calendar.startOfDay(for: now, locationData: locationData))
            let startOfNextDay:  Date = (calendar.startOfNextDay(date: now, locationData: locationData))
            let temp = self.events(date: now.noon(timeZone: timeZone), locationData: locationData, eventCalendarName: eventCalendarName, calendarTitleWithoutLocation: calendarTitleWithoutLocation, calendar: calendar, otherCalendars: otherCalendars, ISOCountryCode: ISOCountryCode, requestedLocaleIdentifier: requestedLocaleIdentifier, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
            for event in temp {
                if event.relevant(startDate:  startDate, endDate:  endDate) && !result.contains(event) {
                    result.append(event)
                } else {
                }
            } // for event in tempResult
            oldNow = now
            now = now.oneDayAfter
        } while oldNow < endDate

        return result
    } // func eventDetails(startDate: Date, endDate: Date, locationData:  ASALocation, eventCalendarName: String) -> Array<ASAEvent>
    
    var color:  Color {
        return Color(self.eventsFile!.calendarColor)
    } // static func calendarColor() -> Color

    func title(localeIdentifier:  String) -> String {
        return self.eventsFile!.titles[localeIdentifier] ?? "???"
    }

    func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar, templateDateComponents:  ASADateComponents, strong:  Bool) -> ASADateSpecification {
        var tweakedDateSpecification = dateSpecification

        if strong {
            if tweakedDateSpecification.era == nil {
                tweakedDateSpecification.era = templateDateComponents.era!
            }
            if tweakedDateSpecification.year == nil {
                tweakedDateSpecification.year = templateDateComponents.year!
            }
            if tweakedDateSpecification.month == nil {
                tweakedDateSpecification.month = templateDateComponents.month!
            }
            if tweakedDateSpecification.day == nil {
                tweakedDateSpecification.day = templateDateComponents.day!
            }
        }

        if tweakedDateSpecification.day! < 0 {
            let tweakedDate = calendar.date(dateComponents: ASADateComponents(calendar: calendar, locationData: templateDateComponents.locationData, era: tweakedDateSpecification.era, year: tweakedDateSpecification.year, yearForWeekOfYear: nil, quarter: nil, month: tweakedDateSpecification.month, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: tweakedDateSpecification.day, hour: nil, minute: nil, second: nil, nanosecond: nil))
            if tweakedDate != nil {
                let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: tweakedDate!)
                let numberOfDaysInMonth = rangeOfDaysInMonth!.count
                tweakedDateSpecification.day = tweakedDateSpecification.day! + (numberOfDaysInMonth + 1)

                //            debugPrint(#file, #function, "📆 Date:", date, "🔴 Original date specification:", dateSpecification, "🟢 Tweaked date specification:", tweakedDateSpecification, "🗓 Calendar:", calendar, "Template date components:", templateDateComponents)
            }
        }
        return tweakedDateSpecification
    } // func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar) -> ASADateSpecification
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?, components: ASADateComponents) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        
        let tweakedStartDateSpecification = self.tweak(dateSpecification: startDateSpecification, date: date, calendar: calendar, templateDateComponents: components, strong: true)

        if endDateSpecification == nil {
            let matches = self.match(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: tweakedStartDateSpecification, components: components)
            return (matches, nil, nil)
        }
        
        // Now we are clearly dealing with an event with specified start and end dates
        
//        let supportsEra: Bool = calendar.supports(calendarComponent: .era)
//        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
//        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
//        let supportsDay: Bool = calendar.supports(calendarComponent: .weekday)
//        let supportsWeekday: Bool = calendar.supports(calendarComponent: .weekday)
//        
//        if supportsEra {
//            let matching = components.matchEra(startDateSpecification: startDateSpecification, endDateSpecification: endDateSpecification!)
//            if matching == .success {
//                return (true, nil, nil)
//            }
//            if matching == .failure {
//                return (false, nil, nil)
//            }
//        }

        let tweakedEndDateSpecification = self.tweak(dateSpecification: endDateSpecification!, date: date, calendar: calendar, templateDateComponents: components, strong: true)
        
        let eventStartDateSpecification = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false)
        if eventStartDateSpecification == nil {
            return (false, nil, nil)
        }
        let eventEndDateSpecification = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true)
        if eventEndDateSpecification == nil {
            return (false, nil, nil)
        }
        
        if !self.matchYearSupplemental(date: date, components: components, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }
        if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }
        
        let dateStartOfDay = calendar.startOfDay(for: date, locationData: locationData)
        let dateEndOfDay = calendar.startOfNextDay(date: date, locationData: locationData)

        if eventStartDateSpecification == eventEndDateSpecification && eventStartDateSpecification == dateStartOfDay {
            return (true, eventStartDateSpecification, eventEndDateSpecification)
        }
        
        if dateEndOfDay <= eventStartDateSpecification! {
            return (false, nil, nil)
        }

        if dateStartOfDay >= eventEndDateSpecification! {
            return (false, nil, nil)
        }
        
        return (true, eventStartDateSpecification, eventEndDateSpecification)
    }
    
    func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfYear != nil {
            let rangeOfDaysInYear = calendar.range(of: .day, in: .year, for: date)
            let numberOfDaysInYear = rangeOfDaysInYear!.count
            //            debugPrint(#file, #function, rangeOfDaysInYear as Any, numberOfDaysInYear as Any)
            if !numberOfDaysInYear.matches(values: dateSpecification.lengthsOfYear) {
                return false
            }
        }
        
        if dateSpecification.dayOfYear != nil {
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)
            if dayOfYear == nil {
                return false
            }
            if !dayOfYear!.matches(value: dateSpecification.dayOfYear) {
                return false
            }
        }

        if dateSpecification.yearDivisor != nil && dateSpecification.yearRemainder != nil {
            let year = components.year
            let (_, remainder) = year!.quotientAndRemainder(dividingBy:  dateSpecification.yearDivisor!)
            if !remainder.matches(value: dateSpecification.yearRemainder) {
                return false
            }
        }
        
        return true
    } // func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfMonth != nil {
            let rangeOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)
            let numberOfDaysInMonth = rangeOfDaysInMonth!.count
            if !numberOfDaysInMonth.matches(values: dateSpecification.lengthsOfMonth) {
                return false
            }
        }
        
        return true
    } // func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        let tweakedOnlyDateSpecification = onlyDateSpecification

        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
        if supportsYear {
            if !(components.era?.matches(value: tweakedOnlyDateSpecification.era) ?? false) {
                return false
            }

            if !(components.year?.matches(value: tweakedOnlyDateSpecification.year) ?? false) {
                return false
            }
            
            if !self.matchYearSupplemental(date: date, components: components, dateSpecification: tweakedOnlyDateSpecification, calendar: calendar) {
                return false
            }
        }
        
        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
        if supportsMonth {
            if !(components.month?.matches(value: tweakedOnlyDateSpecification.month) ?? false) {
                return false
            }
            
            if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: tweakedOnlyDateSpecification, calendar: calendar) {
                return false
            }
        }
        
        let supportsDay: Bool = calendar.supports(calendarComponent: .day)
        if supportsDay {
            if !(components.day?.matches(value: tweakedOnlyDateSpecification.day) ?? false) {
                return false
            }
        }
        
        let supportsWeekday: Bool = calendar.supports(calendarComponent: .weekday)
        if supportsWeekday {
            if !(components.weekday?.matches(weekdays: tweakedOnlyDateSpecification.weekdays) ?? false) {
                return false
            }
        }

        return true
    } // func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification) -> Bool
    
    func events(date:  Date, locationData:  ASALocation, eventCalendarName: String, calendarTitleWithoutLocation:  String, calendar:  ASACalendar, otherCalendars: Dictionary<ASACalendarCode, ASACalendar>, ISOCountryCode:  String?, requestedLocaleIdentifier:  String, startOfDay:  Date, startOfNextDay:  Date) -> Array<ASAEvent> {
        let location = locationData.location
        let timeZone = locationData.timeZone
        
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

        let components = calendar.dateComponents([.era, .year, .month, .day, .weekday], from: date, locationData: locationData)

        for eventSpecification in self.eventsFile!.eventSpecifications {
            assert(previousSunset.oneDayAfter > date)

            var appropriateCalendar:  ASACalendar = calendar
            if eventSpecification.calendarCode != nil {
                let probableAppropriateCalendar = otherCalendars[eventSpecification.calendarCode!]
                if probableAppropriateCalendar != nil {
                    appropriateCalendar = probableAppropriateCalendar!
                }
            }
            let (matchesDateSpecifications, returnedStartDate, returnedEndDate) = self.match(date: date, calendar: appropriateCalendar, locationData: locationData, startDateSpecification: eventSpecification.startDateSpecification, endDateSpecification: eventSpecification.endDateSpecification, components: components)
            if matchesDateSpecifications {
                let matchesCountryCode: Bool = eventSpecification.match(ISOCountryCode: ISOCountryCode)
                if matchesCountryCode {
                    let title = eventSpecification.eventTitle(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let color = self.color
                    var startDate = returnedStartDate
                    var endDate = returnedEndDate

                    // We have to make sure that solar events after Sunset happen on the correct day.  This is an issue on Sunset transition calendars.
                    var fixedDate:  Date
                    if appropriateCalendar.transitionType == .sunset
                        && !eventSpecification.isAllDay
                        && eventSpecification.startDateSpecification.type == .degreesBelowHorizon
                        && eventSpecification.startDateSpecification.rising == false
                        && eventSpecification.startDateSpecification.offset ?? -1 >= 0 {
                        fixedDate = date.oneDayBefore
                    } else {
                        fixedDate = date
                    }

                    if startDate == nil {
                        startDate = eventSpecification.isAllDay ? appropriateCalendar.startOfDay(for: date, locationData: locationData) : eventSpecification.startDateSpecification.date(date: fixedDate, latitude: latitude, longitude: longitude, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
                        endDate = eventSpecification.isAllDay ? (appropriateCalendar.startOfNextDay(date: date, locationData: locationData)) : (eventSpecification.endDateSpecification == nil ? startDate : eventSpecification.endDateSpecification!.date(date: fixedDate, latitude: latitude, longitude: longitude, timeZone: timeZone, previousSunset: previousSunset, nightHourLength: nightHourLength, sunrise: sunrise, hourLength: hourLength, previousOtherDusk: previousOtherDusk, otherNightHourLength: otherNightHourLength, otherDawn: otherDawn, otherHourLength: otherHourLength, startOfDay: startOfDay, startOfNextDay: startOfNextDay))
                    }
                    let newEvent = ASAEvent(title:  title, startDate: startDate, endDate: endDate, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, color: color, calendarTitleWithLocation: eventCalendarName, calendarTitleWithoutLocation: calendarTitleWithoutLocation, calendarCode: appropriateCalendar.calendarCode, locationData:  locationData)
                    result.append(newEvent)
                }
            }
        } // for eventSpecification in self.eventsFile.eventSpecifications
        return result
    } // func eventDetails(date:  Date, location:  locationData:  ASALocation, eventCalendarName: String) -> Array<ASAEvent>
    
    func eventCalendarNameWithPlaceName(locationData:  ASALocation, localeIdentifier:  String) -> String {
        let localizableTitle = self.eventCalendarNameWithoutPlaceName(localeIdentifier: localeIdentifier)
        let oneLineAddress = locationData.shortFormattedOneLineAddress
        return "\(NSLocalizedString(localizableTitle, comment: "")) • \(oneLineAddress)"
    } // func eventCalendarName(locationData:  ASALocation) -> String
    
    func eventCalendarNameWithoutPlaceName(localeIdentifier:  String) -> String {
        if self.eventsFile == nil {
            return self.fileName
        }
        
        let titles = self.eventsFile!.titles

        let userLocaleIdentifier = localeIdentifier == "" ? Locale.autoupdatingCurrent.identifier : localeIdentifier
        let firstAttempt = titles[userLocaleIdentifier]
        if firstAttempt != nil {
            return firstAttempt!
        }

        let userLanguageCode = userLocaleIdentifier.localeLanguageCode
        if userLanguageCode != nil {
            let secondAttempt = titles[userLanguageCode!]
            if secondAttempt != nil {
                return secondAttempt!
            }
        }

        let thirdAttempt = titles["en"]
        if thirdAttempt != nil {
            return thirdAttempt!
        }

        return "???"
    } // func eventSourceName() -> String
} // class ASAEventCalendar


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
        if self.era != nil {
            revisedDateComponents.era = self.era
        }
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
        
        let latitude = revisedDateComponents.locationData.location.coordinate.latitude 
        let longitude = revisedDateComponents.locationData.location.coordinate.longitude 
        let timeZone = revisedDateComponents.locationData.timeZone
        
        switch self.type {
        case .allDay:
            if isEndDate {
                return calendar.startOfNextDay(date: rawDate!, locationData: revisedDateComponents.locationData )
            } else {
                return calendar.startOfDay(for: rawDate!, locationData: revisedDateComponents.locationData )
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

    func rawDegreesBelowHorizon(date:  Date, latitude: CLLocationDegrees, longitude: CLLocationDegrees, timeZone:  TimeZone) -> Date? {
        let solarEvent = ASASolarEvent(degreesBelowHorizon: self.degreesBelowHorizon!, rising: self.rising!, offset: self.offset!)

        let events = date.solarEvents(latitude: latitude, longitude: longitude, events: [solarEvent], timeZone:  timeZone)
        let result = events[solarEvent]
        return result!
    }
    
    func date(date:  Date, latitude: CLLocationDegrees, longitude: CLLocationDegrees, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double, startOfDay:  Date, startOfNextDay:  Date) -> Date? {
        switch self.type {
        case .degreesBelowHorizon:
            let result = self.rawDegreesBelowHorizon(date: date, latitude: latitude, longitude: longitude, timeZone: timeZone)
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
    } // func date(date:  Date, latitude: CLLocationDegrees, longitude: CLLocationDegrees, timeZone:  TimeZone, previousSunset:  Date, nightHourLength:  Double, sunrise:  Date, hourLength:  Double, previousOtherDusk:  Date, otherNightHourLength:  Double, otherDawn:  Date, otherHourLength:  Double) -> Date?
} // extension ASADateSpecification


// MARK: -

extension ASAEventCalendar {
    class func builtInEventCalendarFileNames(calendarCode:  ASACalendarCode) -> Array<String> {
        let mainBundle = Bundle.main
        let URLs = mainBundle.urls(forResourcesWithExtension: "json", subdirectory: nil)
        let rawFileNames: Array<String> = URLs!.map {
            $0.deletingPathExtension().lastPathComponent
        }
        var unsortedFileNames:  Array<String> = []
        for fileName in rawFileNames {
            let (eventsFile, _) = ASAEventsFile.builtIn(fileName: fileName)
            if eventsFile?.calendarCode == calendarCode {
                unsortedFileNames.append(fileName)
            }
        }
        let fileNames = unsortedFileNames.sorted(by: {NSLocalizedString($0, comment: "") < NSLocalizedString($1, comment: "")})
        debugPrint(#file, #function, fileNames)

        return fileNames
    } // static var builtInEventCalendarFileNames
} // extension ASAEventCalendar


// MARK:  -

extension Array where Element == ASAEventCompatible {
    func nextEvents(now:  Date) -> Array<ASAEventCompatible> {
        let firstIndex = self.firstIndex(where: { $0.startDate > now })
        if firstIndex == nil {
            return []
        }
        let firstItemStartDate = self[firstIndex!].startDate

        var result:  Array<ASAEventCompatible> = []
        for i in firstIndex!..<self.count {
            let item_i: ASAEventCompatible = self[i]
            if item_i.startDate == firstItemStartDate {
                result.append(item_i)
            } else {
                break
            }
        } // for i

        return result
    } // func nextEvent(now:  Date) -> ASAEventCompatible?
} // extension Array where Element == ASAEventCompatible
