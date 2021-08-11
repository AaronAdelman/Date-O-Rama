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
        return self.eventsFile!.calendarColor
    } // var color

    func title(localeIdentifier:  String) -> String {
        return self.eventsFile!.titles[localeIdentifier] ?? "???"
    }

    func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar, templateDateComponents:  ASADateComponents
//               , strong:  Bool
    ) -> ASADateSpecification {
        var tweakedDateSpecification = dateSpecification

//        if strong {
            if tweakedDateSpecification.era == nil && templateDateComponents.era != nil {
                tweakedDateSpecification.era = templateDateComponents.era!
            }
            if tweakedDateSpecification.year == nil && templateDateComponents.year != nil {
                tweakedDateSpecification.year = templateDateComponents.year!
            }
            if tweakedDateSpecification.month == nil && templateDateComponents.month != nil {
                tweakedDateSpecification.month = templateDateComponents.month!
            }
            if tweakedDateSpecification.day == nil && templateDateComponents.day != nil {
                tweakedDateSpecification.day = templateDateComponents.day!
            }
//        }

        if tweakedDateSpecification.day! < 0 {
            let tweakedDate = calendar.date(dateComponents: ASADateComponents(calendar: calendar, locationData: templateDateComponents.locationData, era: tweakedDateSpecification.era, year: tweakedDateSpecification.year, yearForWeekOfYear: nil, quarter: nil, month: tweakedDateSpecification.month, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: nil, weekdayOrdinal: nil, day: tweakedDateSpecification.day, hour: nil, minute: nil, second: nil, nanosecond: nil))
            if tweakedDate != nil {
                let numberOfDaysInMonth = calendar.maximumValue(of: .day, in: .month, for: tweakedDate!)!
                tweakedDateSpecification.day = tweakedDateSpecification.day! + (numberOfDaysInMonth + 1)

                //            debugPrint(#file, #function, "📆 Date:", date, "🔴 Original date specification:", dateSpecification, "🟢 Tweaked date specification:", tweakedDateSpecification, "🗓 Calendar:", calendar, "Template date components:", templateDateComponents)
            }
        }
        return tweakedDateSpecification
    } // func tweak(dateSpecification:  ASADateSpecification, date:  Date, calendar:  ASACalendar) -> ASADateSpecification
    
    func matchTimeChange(timeZone: TimeZone, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let oneSecondBeforeStartOfDay = startOfDay.addingTimeInterval(-1.0)
        let nextDaylightSavingTimeTransition = timeZone.nextDaylightSavingTimeTransition(after: oneSecondBeforeStartOfDay)
        if nextDaylightSavingTimeTransition != nil {
            let nextTransition: Date = nextDaylightSavingTimeTransition!
            if startOfDay <= nextTransition && nextTransition < startOfNextDay {
               return (true, nextTransition, nextTransition)
            }
        }
        
        return (false, nil, nil)
    } // func matchTimeChange(timeZone: TimeZone, startOfDay:  Date, startOfNextDay:  Date) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?, components: ASADateComponents, startOfDay:  Date, startOfNextDay:  Date, firstDateSpecification: ASADateSpecification?) -> (matches:  Bool, startDate:  Date?, endDate:  Date?) {
        let MATCH_FAILURE: (matches:  Bool, startDate:  Date?, endDate:  Date?) = (false, nil, nil)
                    
        // Time change events
        if startDateSpecification.type == .timeChange {
            return matchTimeChange(timeZone: locationData.timeZone, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
        }
        
        var tweakedStartDateSpecification = self.tweak(dateSpecification: startDateSpecification, date: date, calendar: calendar, templateDateComponents: components)
        
        // Check whether the event is before the first occurrence
        if firstDateSpecification != nil {            
            let start = tweakedStartDateSpecification.EYMD
            let first = firstDateSpecification!.EYMD
                        
            if !start.isAfterOrEqual(first: first) {
                return MATCH_FAILURE
            }
        }

        // All-year events
        if startDateSpecification.type == .allYear {
            assert(endDateSpecification == nil)
            let matches = self.matchAllYear(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: tweakedStartDateSpecification, components: components)
            if matches {
                let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
                let endDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
                return (true, startDate, endDate)
            } else {
                return MATCH_FAILURE
            }
        }
        
        // Multi-year events
        if startDateSpecification.type == .multiYear {
            assert(endDateSpecification != nil)
            
            let dateEY: Array<Int?>      = components.EY
            let startDateEY: Array<Int?> = startDateSpecification.EY
            let endDateEY: Array<Int?>   = endDateSpecification!.EY
            let within: Bool = dateEY.isWithin(start: startDateEY, end: endDateEY)
            
            if !within {
                return (false, nil, nil)
            }
            
            let (filledInStartDateEY, filledInEndDateEY) = dateEY.fillInFor(start: startDateEY, end: endDateEY)
            
            tweakedStartDateSpecification = startDateSpecification.fillIn(EY: filledInStartDateEY)
            
            let tweakedEndDateSpecification = endDateSpecification!.fillIn(EY: filledInEndDateEY)

            let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
            let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
            return (true, startDate, endDate)
        }
        
        // All-month events
        if startDateSpecification.type == .allMonth {
            assert(endDateSpecification == nil)
            
            let matches = self.matchAllMonth(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: tweakedStartDateSpecification, components: components)
            if matches {
                let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
                let endDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
                return (true, startDate, endDate)
            } else {
                return (false, nil, nil)
            }
        }
        
        // Multi-month events
        if startDateSpecification.type == .multiMonth {
            assert(endDateSpecification != nil)
            
            if !matchAllYear(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: startDateSpecification, components: components) {
                return (false, nil, nil)
            }
            
            let dateEYM: Array<Int?>      = components.EYM
            let startDateEYM: Array<Int?> = startDateSpecification.EYM
            let endDateEYM: Array<Int?>   = endDateSpecification!.EYM
            let within: Bool = dateEYM.isWithin(start: startDateEYM, end: endDateEYM)
            
            if !within {
                return (false, nil, nil)
            }
            
            let (filledInStartDateEYM, filledInEndDateEYM) = dateEYM.fillInFor(start: startDateEYM, end: endDateEYM)
            
            tweakedStartDateSpecification = startDateSpecification.fillIn(EYM: filledInStartDateEYM)
            
            let tweakedEndDateSpecification = endDateSpecification!.fillIn(EYM: filledInEndDateEYM)

            let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
            let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
            return (true, startDate, endDate)
        }

        if endDateSpecification == nil {
            // One-day and one-instant events
            assert(endDateSpecification?.type != .multiDay)
            let matches = self.matchOneDayOrInstant(date: date, calendar: calendar, locationData: locationData, dateSpecification: tweakedStartDateSpecification, components: components)
            
            if matches && tweakedStartDateSpecification.type == .IslamicPrayerTime {
                if tweakedStartDateSpecification.event == nil {
                    // Major error!
                    debugPrint(#file, #function, "Missing Islamic prayer event!")
                    return (false, nil, nil)
                }
                let events = date.prayerTimesSunsetTransition(latitude: locationData.location.coordinate.latitude, longitude: locationData.location.coordinate.longitude, calcMethod: tweakedStartDateSpecification.calculationMethod ?? .Jafari, asrJuristic: tweakedStartDateSpecification.asrJuristicMethod ?? .Shafii, dhuhrMinutes: tweakedStartDateSpecification.dhuhrMinutes ?? 0.0, adjustHighLats: tweakedStartDateSpecification.adjustingMethodForHigherLatitudes ?? .midnight, events: [tweakedStartDateSpecification.event!])
                let startDate = events![tweakedStartDateSpecification.event!]
                return (matches, startDate, startDate)
            } else {
                return (matches, nil, nil)
            }
        }
        
        // Now we are clearly dealing with an event with specified start and end dates
        let dateEYMD: Array<Int?>      = components.EYMD
        let startDateEYMD: Array<Int?> = startDateSpecification.EYMD
        let endDateEYMD: Array<Int?>   = endDateSpecification!.EYMD
        let within: Bool = dateEYMD.isWithin(start: startDateEYMD, end: endDateEYMD)
        
        if !within {
            return (false, nil, nil)
        }
        
        let (filledInStartDateEYMD, filledInEndDateEYMD) = dateEYMD.fillInFor(start: startDateEYMD, end: endDateEYMD)
        
        tweakedStartDateSpecification = startDateSpecification.fillIn(EYMD: filledInStartDateEYMD)
        
        let tweakedEndDateSpecification = endDateSpecification!.fillIn(EYMD: filledInEndDateEYMD)
        
        let eventStartDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date)
        if eventStartDate == nil {
            return (false, nil, nil)
        }
        let eventEndDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date)
        if eventEndDate == nil {
            return (false, nil, nil)
        }
        
        let eventStartComponents = calendar.dateComponents([.era, .year, .month, .day, .weekday], from: eventStartDate!, locationData: locationData)
        let eventEndComponents = calendar.dateComponents([.era, .year, .month, .day, .weekday], from: eventEndDate!, locationData: locationData)
        
        if !self.matchYearSupplemental(date: eventStartDate!, components: eventStartComponents, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }
        
        if !self.matchYearSupplemental(date: eventEndDate!, components: eventEndComponents, dateSpecification: tweakedEndDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }
        
        if !self.matchMonthSupplemental(date: eventStartDate!, components: eventStartComponents, dateSpecification: tweakedStartDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }

        if !self.matchMonthSupplemental(date: eventEndDate!, components: eventEndComponents, dateSpecification: tweakedEndDateSpecification, calendar: calendar) {
            return (false, nil, nil)
        }

        let dateStartOfDay = calendar.startOfDay(for: date, locationData: locationData)
        let dateEndOfDay = calendar.startOfNextDay(date: date, locationData: locationData)

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
    } // func match(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, startDateSpecification:  ASADateSpecification, endDateSpecification:  ASADateSpecification?, components: ASADateComponents) -> (matches:  Bool, startDate:  Date?, endDate:  Date?)
    
    func matchYearSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool {
        if dateSpecification.lengthsOfYear != nil {
            let numberOfDaysInYear = calendar.maximumValue(of: .day, in: .year, for: date)!
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
            let numberOfDaysInMonth = calendar.maximumValue(of: .day, in: .month, for: date)!
            if !numberOfDaysInMonth.matches(values: dateSpecification.lengthsOfMonth) {
                return false
            }
        }
        
        return true
    } // func matchMonthSupplemental(date:  Date, components:  ASADateComponents, dateSpecification:  ASADateSpecification, calendar:  ASACalendar) -> Bool
    
    func matchAllYear(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        let supportsEra: Bool = calendar.supports(calendarComponent: .era)
        if supportsEra {
            if !(components.era?.matches(value: onlyDateSpecification.era) ?? false) {
                return false
            }
        }

        let supportsYear: Bool = calendar.supports(calendarComponent: .year)
        if supportsYear {
            if !(components.year?.matches(value: onlyDateSpecification.year) ?? false) {
                return false
            }
            
            if !self.matchYearSupplemental(date: date, components: components, dateSpecification: onlyDateSpecification, calendar: calendar) {
                return false
            }
        }
        
        return true
    } // func matchAllYear(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool
    
    func matchAllMonth(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        if !matchAllYear(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: onlyDateSpecification, components: components) {
            return false
        }
        
        let supportsMonth: Bool = calendar.supports(calendarComponent: .month)
        if supportsMonth {
            if !(components.month?.matches(value: onlyDateSpecification.month) ?? false) {
                return false
            }
            
            if !self.matchMonthSupplemental(date: date, components: components, dateSpecification: onlyDateSpecification, calendar: calendar) {
                return false
            }
        }

        return true
    } // func matchAllMonth(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, onlyDateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool
    
    func matchOneDayOrInstant(date:  Date, calendar:  ASACalendar, locationData:  ASALocation, dateSpecification:  ASADateSpecification, components: ASADateComponents) -> Bool {
        if !matchAllMonth(date: date, calendar: calendar, locationData: locationData, onlyDateSpecification: dateSpecification, components: components) {
            return false
        }
        
        let supportsDay: Bool = calendar.supports(calendarComponent: .day)
        if supportsDay {
            if dateSpecification.day != nil {
                // Check specified day of month
                if !(components.day!.matches(value: dateSpecification.day!) ) {
                    return false
                }
            }
        }
        
        let supportsWeekday: Bool = calendar.supports(calendarComponent: .weekday)
        if supportsWeekday {
            if !(components.weekday?.matches(weekdays: dateSpecification.weekdays) ?? false) {
                return false
            }
        }
        
        if dateSpecification.weekdayRecurrence != nil && dateSpecification.weekdays != nil {
            let daysInMonth = calendar.maximumValue(of: .day, in: .month, for: date) ?? 1
            
            if !(components.day!.matches(recurrence: dateSpecification.weekdayRecurrence!, lengthOfWeek: calendar.daysPerWeek!, lengthOfMonth: daysInMonth)) {
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
            var appropriateComponents: ASADateComponents
            if calendar.calendarCode == appropriateCalendar.calendarCode {
                appropriateComponents = components
            } else {
                appropriateComponents = appropriateCalendar.dateComponents([.era, .year, .month, .day, .weekday], from: date, locationData: locationData)
            }
            
            let (matchesDateSpecifications, returnedStartDate, returnedEndDate) = self.match(date: date, calendar: appropriateCalendar, locationData: locationData, startDateSpecification: eventSpecification.startDateSpecification, endDateSpecification: eventSpecification.endDateSpecification, components: appropriateComponents, startOfDay: startOfDay, startOfNextDay: startOfNextDay, firstDateSpecification: eventSpecification.firstDateSpecification)
            if matchesDateSpecifications {
                let matchesRegionCode: Bool = eventSpecification.match(regionCode: ISOCountryCode)
                if matchesRegionCode {
                    var title: String
                    if eventSpecification.startDateSpecification.type == .timeChange {
                        let oneSecondBeforeChange = returnedStartDate!.addingTimeInterval(-1.0)
                        let oneSecondAfterChange = returnedStartDate!.addingTimeInterval(1.0)
                        let offsetBeforeChange = timeZone.daylightSavingTimeOffset(for: oneSecondBeforeChange)
                        let offsetAfterChange = timeZone.daylightSavingTimeOffset(for: oneSecondAfterChange)
                        if offsetBeforeChange < offsetAfterChange {
                            title = NSLocalizedString("Spring ahead", comment: "")
                        } else {
                            title = NSLocalizedString("Fall back", comment: "")
                        }
                    } else {
                        title = eventSpecification.eventTitle(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale) ?? ""
                    }
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
                    
                    let location: String? = eventSpecification.eventLocation(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let url: URL? = eventSpecification.eventURL(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let notes: String? = eventSpecification.eventNotes(requestedLocaleIdentifier: requestedLocaleIdentifier, eventsFileDefaultLocaleIdentifier: eventsFile!.defaultLocale)
                    let category: ASAEventCategory = eventSpecification.category ?? .generic

                    let newEvent = ASAEvent(title:  title, location: location, startDate: startDate, endDate: endDate, isAllDay: eventSpecification.isAllDay, timeZone: timeZone, url: url, notes: notes, color: color, calendarTitleWithLocation: eventCalendarName, calendarTitleWithoutLocation: calendarTitleWithoutLocation, calendarCode: appropriateCalendar.calendarCode, locationData:  locationData, recurrenceRules: eventSpecification.recurrenceRules, regionCodes: eventSpecification.regionCodes, excludeRegionCodes: eventSpecification.excludeRegionCodes, category: category, emoji: eventSpecification.emoji, type: eventSpecification.startDateSpecification.type)
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
            if (eventsFile?.calendarCode ?? .none).matches(calendarCode) {
                unsortedFileNames.append(fileName)
            }
        }
        let fileNames = unsortedFileNames.sorted(by: {NSLocalizedString($0, comment: "") < NSLocalizedString($1, comment: "")})
//        debugPrint(#file, #function, fileNames)

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
