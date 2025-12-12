//
//  ASABahaiCalendar.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 11/12/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import Foundation

class ASABahaiCalendar: ASASolarTimeCalendar {
    override func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat) -> String {
        return ""
    } // func dateString(fixedNow: Date, localeIdentifier: String, timeZone: TimeZone, dateFormat: ASADateFormat) -> String
    
    // MARK: -
    
    override func isValidDate(dateComponents: ASADateComponents) -> Bool {
        return false
    } // func isValidDate(dateComponents: ASADateComponents) -> Bool
    
    override func date(dateComponents: ASADateComponents) -> Date? {
        return nil
    } // func date(dateComponents: ASADateComponents) -> Date?
    
    override func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents {
        
        
        
        return ASADateComponents(calendar: self, locationData: locationData)
    } // func dateComponents(fixedDate: Date, transition: Date??, components: Set<ASACalendarComponent>, from date: Date, locationData: ASALocation) -> ASADateComponents
    
    
    // MARK: -
    
    override func maximumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // The maximum range limits of the values that a given component can take on.
        return nil
    } // func maximumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    override func minimumRange(of component: ASACalendarComponent) -> Range<Int>? {
        // Returns the minimum range limits of the values that a given component can take on.
        return nil
    } // func minimumRange(of component: ASACalendarComponent) -> Range<Int>?
    
    override func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int? {
        // Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
        return nil
    } // func ordinality(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Int?
    
    override func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>? {
        // Returns the range of absolute time values that a smaller calendar component (such as a day) can take on in a larger calendar component (such as a month) that includes a specified absolute time.
        return nil
    } // func range(of smaller: ASACalendarComponent, in larger: ASACalendarComponent, for date: Date) -> Range<Int>?
    
    
    // MARK: -
    
    override func weekdaySymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "ar":
            return [
                "جمال",
                "كمال",
                "فضال",
                "عدال",
                "استجلال",
                "استقلال",
                "جلال"
            ]
            
        default:
            return [
                "Jamál",
                "Kamál",
                "Fiḍál",
                "ʻIdál",
                "Istijlál",
                "Istiqlál",
                "Jalál"
            ]
        }
    } // func weekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return self.weekdaySymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
    } // func veryShortWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return weekdaySymbols(localeIdentifier: localeIdentifier)
    } // func standaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return shortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String> {
        return veryShortWeekdaySymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneWeekdaySymbols(localeIdentifier: String) -> Array<String>
        
    
    // MARK: -
    
    override func monthSymbols(localeIdentifier: String) -> Array<String> {
        switch localeIdentifier.localeLanguageCode {
        case "ar":
            return [
            "بهاء",
            "جلال",
            "جمال",
            "عظمة",
            "نور",
            "رحمة",
            "كلمات",
            "كمال",
            "اسماء",
            "عزة",
            "مشية",
            "علم",
            "قدرة",
            "قول",
            "مسائل",
            "شرف",
            "سلطان",
            "ملك",
            "ايام الهاء",
            "علاء",
        ]
            
        default:
            return [
                "Bahá",
                "Jalál",
                "Jamál",
                "ʻAẓamat",
                "Núr",
                "Raḥmat",
                "Kalimát",
                "Kamál",
                "Asmáʼ",
                "ʻIzzat",
                "Mas͟híyyat",
                "ʻIlm",
                "Qudrat",
                "Qawl",
                "Masáʼil",
                "S͟haraf",
                "Sulṭán",
                "Mulk",
                "Ayyám-i-Há",
                "ʻAláʼ",
            ]
        }
    } // func monthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier)
    } // func shortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier).firstCharacterOfEachElement
    } // func veryShortMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return monthSymbols(localeIdentifier: localeIdentifier)
    } // func standaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return shortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func shortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    override func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String> {
        return veryShortMonthSymbols(localeIdentifier: localeIdentifier)
    } // func veryShortStandaloneMonthSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithQuarters
    
    override func quarterSymbols(localeIdentifier: String) -> Array<String> {
    return ["Q1", "Q2", "Q3", "Q4"]
    } // func quarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4"]
    } // func shortQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4"]
    } // func standaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    override func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String> {
        return ["Q1", "Q2", "Q3", "Q4"]
    } // func shortStandaloneQuarterSymbols(localeIdentifier: String) -> Array<String>
    
    
    // MARK: - ASACalendarWithEras
    
    override func eraSymbols(localeIdentifier: String) -> Array<String> {
        return ["BE"]
    } // func eraSymbols(localeIdentifier: String) -> Array<String>
    
    override func longEraSymbols(localeIdentifier: String) -> Array<String> {
        return eraSymbols(localeIdentifier: localeIdentifier)
    } // func longEraSymbols(localeIdentifier: String) -> Array<String>
    
} // class ASABahaiCalendar
