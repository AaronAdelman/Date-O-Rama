//
//  ASAAppleCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-20.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

class ASAAppleCalendar: ASACalendar, ASACalendarWithWeeks, ASACalendarWithMonths, ASACalendarWithQuarters, ASACalendarWithEras, ASACalendarWithAMAndPM {
    var defaultDateFormat: ASADateFormat = .full
    
    var calendarCode: ASACalendarCode
    
    var dateFormatter = DateFormatter()
    lazy var isoDateFormatter = ISO8601DateFormatter()

    private var applesCalendar: Calendar
    
    init(calendarCode: ASACalendarCode) {
        self.calendarCode = calendarCode
        let identifier = self.calendarCode.equivalentCalendarIdentifier
        applesCalendar = Calendar(identifier: identifier!)
        dateFormatter.calendar = applesCalendar
    } // init(calendarCode: ASACalendarCode)

    func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents) {
        let dateString = self.dateTimeString(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: .none, locationData: locationData)
        let timeString = self.dateTimeString(now: now, localeIdentifier: localeIdentifier, dateFormat: .none, timeFormat: timeFormat, locationData: locationData)
        let dateComponents = self.dateComponents([.era, .year, .month, .day, .weekday, .hour, .minute, .second], from: now, locationData: locationData)
        return (dateString, timeString, dateComponents)
    } // func dateStringTimeStringDateComponents(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> (dateString: String, timeString: String, dateComponents: ASADateComponents)
    
    func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: timeFormat, timeZone: locationData.timeZone)
        
        switch dateFormat {
        case .iso8601YearDay, .iso8601YearMonthDay, .iso8601YearWeekDay:
            return isoDateTimeString(now: now, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: locationData)
        
        default:
            self.dateFormatter.apply(dateFormat: dateFormat)
        } // switch dateFormat
        
        return self.dateFormatter.string(from: now)
    } // func dateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String
    
    func isoDateTimeString(now: Date, localeIdentifier: String, dateFormat: ASADateFormat, timeFormat: ASATimeFormat, locationData: ASALocation) -> String {
        var dateString: String
        
        var formatterOptions: ISO8601DateFormatter.Options = []
        switch dateFormat {
        case .none:
            formatterOptions = []
        case .full:
            formatterOptions = [.withFullDate]
        case .iso8601YearMonthDay:
            formatterOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        case .iso8601YearWeekDay:
            formatterOptions = [.withYear, .withWeekOfYear, .withDay, .withDashSeparatorInDate]
        case .iso8601YearDay:
            formatterOptions = [.withYear, .withDay, .withDashSeparatorInDate]
        default:
            formatterOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        } // switch dateFormat
        
        if timeFormat != .none {
            formatterOptions.insert(.withTime)
            formatterOptions.insert(.withColonSeparatorInTime)
        }
        
        self.isoDateFormatter.formatOptions = formatterOptions

        let timeZone = locationData.timeZone
        self.isoDateFormatter.timeZone = timeZone

        dateString = self.isoDateFormatter.string(from: now)
        return dateString
    }

    var supportsLocales: Bool = true
    
    func startOfDay(for date: Date, locationData: ASALocation) -> Date {
        let timeZone = locationData.timeZone
        self.applesCalendar.timeZone = timeZone
        return self.applesCalendar.startOfDay(for: date)
    } // func startOfDay(for date: Date, locationData: ASALocation) -> Date
    
    func startOfNextDay(date: Date, locationData: ASALocation) -> Date {
        self.applesCalendar.timeZone = locationData.timeZone
        return self.applesCalendar.startOfDay(for: date.oneDayAfter)
    } // func startOfNextDay(now: Date, locationData: ASALocation) -> Date
        
    var supportsTimeZones: Bool = true
    
    var supportsLocations: Bool = true

    var supportsTimes: Bool = true
    
    var supportedDateFormats: Array<ASADateFormat> {
        return [
            .full
        ]
    }

    var supportedWatchDateFormats: Array<ASADateFormat> {
        return [
            .full,
            .long,
            .medium,
            .mediumWithWeekday,
            .short,
            .shortWithWeekday,
            .abbreviatedWeekday,
            .dayOfMonth,
            .abbreviatedWeekdayWithDayOfMonth,
            .shortWithWeekdayWithoutYear,
            .mediumWithWeekdayWithoutYear,
            .fullWithoutYear,
            .longWithoutYear,
            .mediumWithoutYear,
            .shortWithoutYear
        ]
    }
    
    var supportedTimeFormats: Array<ASATimeFormat> = [
        .medium
    ]
        
    var canSplitTimeFromDate: Bool = true
    
    var defaultTimeFormat: ASATimeFormat = .medium
    
    
    // MARK: - Date components
    
    func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let applesDateComponents = dateComponents.applesDateComponents()
        return applesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    func date(dateComponents: ASADateComponents) -> Date? {
        let applesDateComponents = dateComponents.applesDateComponents()

        return applesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    
    // MARK: - Extracting Components
    
    func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        // Returns all the date components of a date.
        var applesComponents = Set<Calendar.Component>()
        for component in components {
            let applesCalendarComponent = component.calendarComponent()
            if applesCalendarComponent != nil {
                applesComponents.insert(applesCalendarComponent!)
            }
        } // for component in components
        
        var calendar = self.applesCalendar
        calendar.timeZone = locationData.timeZone 
        let applesDateComponents = calendar.dateComponents(applesComponents, from: date)
//        if self.calendarCode == .vikram {
//            debugPrint(#file, #function, applesDateComponents)
//            debugPrint("--------------------------------------------")
//        }
        return ASADateComponents.new(with: applesDateComponents, calendar: self, locationData: locationData)
    } // func dateComponents(_ components: Set<ASACalendarComponent>, from date: Date) -> ASADateComponents
    
    // MARK: - Getting Calendar Information
    
    func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        let applesComponent = component.calendarComponent()
        if applesComponent == nil {
            return nil
        }
        return self.applesCalendar.maximumRange(of: applesComponent!)
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        let ApplesComponent = component.calendarComponent()
        if ApplesComponent == nil {
            return nil
        }
        return self.applesCalendar.minimumRange(of: ApplesComponent!)
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        let applesSmaller = smaller.calendarComponent()
        let applesLarger = larger.calendarComponent()
        if applesSmaller == nil || applesLarger == nil {
            return nil
        }
        return self.applesCalendar.ordinality(of: applesSmaller!, in: applesLarger!, for: date)
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int?
    
    func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        let applesSmaller = smaller.calendarComponent()
        let applesLarger = larger.calendarComponent()
        if applesSmaller == nil || applesLarger == nil {
            return nil
        }
        return self.applesCalendar.range(of: applesSmaller!, in: applesLarger!, for: date)
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>?
    
    
    // MARK: -
    
    func supports(calendarComponent: ASACalendarComponent) -> Bool {
        switch calendarComponent {
        case .era, .year, .yearForWeekOfYear, .quarter, .month, .weekOfYear, .weekOfMonth, .weekday, .weekdayOrdinal, .day:
            return true
            
        case .hour, .minute, .second, .nanosecond:
            return true
            
        case .calendar, .timeZone:
            return true
        case .fractionalHour, .dayHalf:
            return false
        } // switch calendarComponent
    } // func supports(calendarComponent: ASACalendarComponent) -> Bool


    // MARK: -

    public var transitionType: ASATransitionType = .midnight

    func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.weekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    func amSymbol(localeIdentifier: String) -> String {
        return self.applesCalendar.amSymbol(localeIdentifier: localeIdentifier)
    }
    
    func pmSymbol(localeIdentifier: String) -> String {
        return self.applesCalendar.pmSymbol(localeIdentifier: localeIdentifier)
    }

    var usesISOTime: Bool = true

    var daysPerWeek: Int = 7
    
    func weekendDays(for regionCode: String?) -> Array<Int> {
        self.applesCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK: - ASACalendarWithMonths
    
    func monthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.monthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    }
    
    
    // MARK: - ASACalendarWithQuarters
    
    func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.quarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
    
    func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    }
 
    
    // MARK: - ASACalendarWithEras
    
    func eraSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.eraSymbols(localeIdentifier: localeIdentifier)
    }
    
    func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.longEraSymbols(localeIdentifier: localeIdentifier)
    }

    
    // MARK: - Time zone-dependent modified Julian day
    
    func localModifiedJulianDay(date: Date, locationData: ASALocation) -> Int {
        let timeZone = locationData.timeZone
        return date.localModifiedJulianDay(timeZone: timeZone)
    } // func localModifiedJulianDay(date: Date, timeZone: TimeZone) -> Int

    
    // MARK: - Cycles
    
    func cycleNumberFormat(locale: Locale) -> ASANumberFormat {
        if self.calendarCode.isHebrewCalendar && locale.language.languageCode?.identifier == "he" {
            return .hebrew
        }
        
        return .system
    } // func cycleNumberFormat(locale: Locale) -> ASANumberFormat
} // class ASAAppleCalendar
