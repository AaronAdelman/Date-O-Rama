//
//  ASAJudeoIslamicCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/12/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

class ASAJudeoIslamicCalendar: ASASolarTimeCalendar {
    private var dateFormatter = DateFormatter()
    
    private var applesCalendar: Calendar
    
    override init(calendarCode: ASACalendarCode) {
        let identifier = calendarCode.equivalentCalendarIdentifier
        if let identifier {
            self.applesCalendar = Calendar(identifier: identifier)
        } else {
            // Fallback to current calendar if no equivalent identifier is available
            self.applesCalendar = Calendar.current
        }

        super.init(calendarCode: calendarCode)

        dateFormatter.calendar = applesCalendar
    } // init(calendarCode: ASACalendarCode)
    
    // MARK: -
    
    override var midPointTransition: ASASolarEvent {
        switch self.calendarCode {
        case .hebrewMA:
            return .dawn72Minutes
            
        default:
            return .sunrise
        } // switch self.calendarCode
    } // var midPointTransition
    
    override var dateTransition: ASASolarEvent {
        switch self.calendarCode {
        case .hebrewMA:
            return .dusk72Minutes
            
        default:
            return .sunset
        } // switch self.calendarCode
    } // var dateTransition: ASASolarEvent
    
    override func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat, dateComponents: ASADateComponents) -> String {
        self.dateFormatter.apply(localeIdentifier: localeIdentifier, timeFormat: .none, timeZone: timeZone)
        
        self.dateFormatter.apply(dateFormat: dateFormat)
        
        let dateString = self.dateFormatter.string(from: fixedNow)
        return dateString
    } // func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat, dateComponents: ASADateComponents) -> String
    
    // MARK: -
    
    override func isValidDate(dateComponents: ASADateComponents) -> Bool {
        let applesDateComponents = dateComponents.applesDateComponents()
        return applesDateComponents.isValidDate
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    override func date(dateComponents: ASADateComponents) -> Date? {
        var applesDateComponents = dateComponents.applesDateComponents()
        // The next part is to ensure we get the right day and don't screw up Sunrise/Sunset calculations
        applesDateComponents.hour       = 12
        applesDateComponents.minute     =  0
        applesDateComponents.second     =  0
        applesDateComponents.nanosecond =  0
        
        return applesDateComponents.date
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    override func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        var applesComponents = Set<Calendar.Component>()
        for component in components {
            let applesCalendarComponent = component.calendarComponent()
            if applesCalendarComponent != nil {
                applesComponents.insert(applesCalendarComponent!)
            }
        } // for component in components
        
        let applesDateComponents = applesCalendar.dateComponents(applesComponents, from: fixedDate)
        var result = ASADateComponents.new(with: applesDateComponents, calendar: self, locationData: locationData)
        //                        debugPrint(#file, #function, "• Date:", date, "• Fixed date:", fixedDate, "• Result:", result)
        let timeComponents = self.timeComponents(date: date, transition: transition, locationData: locationData)
        
        if components.contains(.fractionalHour) {
            result.solarHours = timeComponents.fractionalHour
        }
        if components.contains(.dayHalf) {
            result.dayHalf = timeComponents.dayHalf
        }
        return result
    } // func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents
    
    
    // MARK: -
    
    override func maximumRange(of component: ASACalendarComponent, locationData: ASALocation) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        let applesComponent = component.calendarComponent()
        if applesComponent == nil {
            return nil
        }
        return self.applesCalendar.maximumRange(of: applesComponent!)
    } // func maximumRange(of component: ASACalendarComponent, locationData: ASALocation) -> Range<Int>?
    
    override func minimumRange(of component: ASACalendarComponent, locationData: ASALocation) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        let applesComponent = component.calendarComponent()
        if applesComponent == nil {
            return nil
        }
        return self.applesCalendar.minimumRange(of: applesComponent!)
    } // func minimumRange(of component: ASACalendarComponent, locationData: ASALocation) -> Range<Int>?
    
    override func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int? {
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)

        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        let applesSmaller = smaller.calendarComponent()
        let applesLarger  = larger.calendarComponent()
        if applesSmaller == nil || applesLarger == nil {
            return nil
        }
        return self.applesCalendar.ordinality(of: applesSmaller!, in: applesLarger!, for: fixedDate)
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Int?
    
    override func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>? {
        let (fixedDate, _) = date.solarCorrected(locationData: locationData, transitionEvent: self.dateTransition)

        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        let applesSmaller = smaller.calendarComponent()
        let applesLarger  = larger.calendarComponent()
        if applesSmaller == nil || applesLarger == nil {
            return nil
        }
        
        var result = self.applesCalendar.range(of: applesSmaller!, in: applesLarger!, for: fixedDate)
        if result?.lowerBound == result?.upperBound {
            let upperBound = result?.upperBound ?? 1
            result = Range(uncheckedBounds: (1, upperBound))
        }
        return result
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date, locationData: ASALocation) -> Range<Int>?
    
    
    // MARK: -
    
    override func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.weekdaySymbols(localeIdentifier: localeIdentifier)
    } // func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortStandaloneWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func weekendDays(for regionCode: String?) -> Array<Int> {
        self.applesCalendar.weekendDays(for: regionCode)
    } // func weekendDays(for regionCode: String?) -> Array<Int>
    
    
    // MARK: -
    
    override func monthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.monthSymbols(localeIdentifier: localeIdentifier)
    } // func monthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.veryShortStandaloneMonthSymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: -
    
    override func quarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.quarterSymbols(localeIdentifier: localeIdentifier)
    } // func quarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortQuarterSymbols(localeIdentifier: localeIdentifier)
    } // func shortQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.standaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    } // func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.shortStandaloneQuarterSymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: -
    
    override func eraSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.eraSymbols(localeIdentifier: localeIdentifier)
    } // func eraSymbols(localeIdentifier: String) -> Array<String>
    
    // TODO: Point of expansion
    override func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return self.applesCalendar.longEraSymbols(localeIdentifier: localeIdentifier)
    } // func longEraSymbols(localeIdentifier: String) -> Array<String>
} // class ASAJudeoIslamicCalendar
