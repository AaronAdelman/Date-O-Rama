//
//  ASAWeeks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/08/2024.
//  Copyright © 2024 Adelsoft. All rights reserved.
//

import Foundation

// Based on:
/*
Module : AAEaster.cpp
Purpose: Implementation for the algorithms which calculate the date of Easter
Created: PJN / 29-12-2003
History: PJN / 07-07-2016 1. Fixed a compiler warning in CAAEaster::Calculate as reported at
                          http://stackoverflow.com/questions/2348415/objective-c-astronomy-library.

Copyright (c) 2003 - 2019 by PJ Naughter (Web: www.naughter.com, Email: pjna@naughter.com)

All rights reserved.

Copyright / Usage Details:

You are allowed to include the source code in any product (commercial, shareware, freeware or otherwise)
when your product is released in binary form. You are allowed to modify the source code in any way you want
except you cannot modify the copyright details at the top of each module. If you want to distribute source
code with your application, then you are only allowed to distribute versions released by the author. This is
to maintain a single distribution point for the source code.

*/
// It was easier to just translate the relevant function into Swift that to coerce Xcode to use the original C++ somehow.

func calculateEaster(nYear: Int, GregorianCalendar: Bool) -> (month: Int, day: Int) {
    if (GregorianCalendar) {
        let a: Int = nYear % 19
        let b: Int = nYear / 100
        let c: Int = nYear % 100
        let d: Int = b / 4
        let e: Int = b % 4
        let f: Int = (b + 8) / 25
        let g: Int = (b - f + 1) / 3
        let h: Int = (19 * a + b - d - g + 15) % 30
        let i: Int = c / 4
        let k: Int = c % 4
        let l: Int = (32 + 2 * e + 2 * i - h - k) % 7
        let m: Int = (a + 11 * h + 22 * l) / 451
        let n: Int = (h + l - 7 * m + 114) / 31
        let p: Int = (h + l - 7 * m + 114) % 31
        let day: Int = p + 1
        return (n, day)
    } else {
        let a: Int = nYear % 4
        let b: Int = nYear % 7
        let c: Int = nYear % 19
        let d: Int = ((19 * c) + 15) % 30
        let e: Int = ((2 * a) + (4 * b) - d + 34) % 7
        let f: Int = (d + e + 114) / 31
        let g: Int = (d + e + 114) % 31
        let day: Int = g + 1
        return (f, day)
    }
} // func calculateEaster(nYear: Int, GregorianCalendar: Bool) -> (month: Int, day: Int)

// MARK:  -

/// Calculates the weekday of the first day of the month.
/// - Parameters:
///   - day: The day of the month
///   - weekday: The day of the week of said day of the month (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: The weekday as an integer (1…the number of days per week)
func weekdayOfFirstDayOfMonth(day: Int, weekday: Int, daysPerWeek: Int) -> Int {
    let offset = day - 1
    var weekdayOfFirstDayOfMonth = (weekday - offset) % daysPerWeek
    if weekdayOfFirstDayOfMonth <= 0 {
        weekdayOfFirstDayOfMonth += daysPerWeek
    }
    return weekdayOfFirstDayOfMonth
} // func weekdayOfFirstDay(day: Int, weekday: Int, daysPerWeek: Int) -> Int

/// Calculates the first and last days of a specified full week (beginning on the first day of the week) of a month.
/// - Parameters:
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - weekdayOfFirstDayOfMonth: The weekday of the first day of the month as an integer (1…the number of days per week)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: A tuple containing the starting and end days in the month for the specified full week
func daysOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int, monthLength: Int, firstDayOfWeek: Int) -> (Int, Int)? {
    if fullWeek >= 1 {
        let fullWeekStart = nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, monthLength: monthLength, targetWeekday: firstDayOfWeek, recurrence: fullWeek, daysPerWeek: daysPerWeek)
        guard let fullWeekStart = fullWeekStart else { return nil }
        return (fullWeekStart, fullWeekStart + daysPerWeek - 1)
    } else {
        // Full weeks counting from the end of the month
        let lastFullWeekStart = nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, monthLength: monthLength, targetWeekday: firstDayOfWeek, recurrence: -1, daysPerWeek: daysPerWeek)
        guard var lastFullWeekStart = lastFullWeekStart else { return nil }
        var lastFullWeekEnd: Int = lastFullWeekStart + daysPerWeek - 1
        if lastFullWeekEnd > monthLength {
            // This is not the actual last full week
            lastFullWeekStart -= daysPerWeek
            lastFullWeekEnd   -= daysPerWeek
        }
        let fullWeekStart = lastFullWeekStart + (fullWeek + 1) * daysPerWeek
        let fullWeekEnd = lastFullWeekEnd + (fullWeek + 1) * daysPerWeek
        return (fullWeekStart, fullWeekEnd)
    }
} // func daysOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> (Int, Int)

/// Calculates the first and last days of a specified full week (beginning on the first day of the week) of a month.
/// - Parameters:
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - day: The day of the month
///   - weekday: The day of the week of said day of the month (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: A tuple containing the starting and end days in the month for the specified full week
func daysOf(fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int, monthLength: Int, firstDayOfWeek: Int) -> (Int, Int)? {
    let weekdayOfFirstDayOfMonth = weekdayOfFirstDayOfMonth(day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    let result = daysOf(fullWeek: fullWeek, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek, monthLength: monthLength, firstDayOfWeek: firstDayOfWeek)
    return result
} // func daysOf(fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> (Int, Int)

/// Calculates the day of the month on which a specified day of the week in a specified full week falls.
/// - Parameters:
///   - weekdayOfFullWeek: The day of the week of the specified full week (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - day: The day of the month
///   - weekday: The day of the week of said day of the month (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: The day of the month on which the specified day of the week in the specified full week falls
func dayGiven(weekdayOfFullWeek: Int, fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int, monthLength: Int, firstDayOfWeek: Int) -> Int {
    // TODO:  May need to put in something to handle last full week of the month.
    
    let weekdayOfFirstDayOfMonth = weekdayOfFirstDayOfMonth(day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    let fullWeekStart = nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, monthLength: monthLength, targetWeekday: firstDayOfWeek, recurrence: fullWeek, daysPerWeek: daysPerWeek)
    var offset = weekdayOfFullWeek - firstDayOfWeek
    if offset < 0 {
        offset += daysPerWeek
    }
    
    return fullWeekStart! + offset
} // func dayGiven(weekdayOfFullWeek: Int, fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int, monthLength: Int, firstDayOfWeek: Int) -> Int

/// Calculates the weekday of a specific day
func weekdayOf(day: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> Int {
    // Calculate the offset from the first day of the month to the specific day
    let offset = (day - 1) % daysPerWeek
    // Calculate the weekday of the specific day
    let specificDayWeekday = (weekdayOfFirstDayOfMonth + offset - 1) % daysPerWeek + 1
    return specificDayWeekday
} // func weekdayOf(day: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> Int

/// Calculates the day in a run that falls on a specified weekday
func dayInRunWithWeekday(weekdayOfFirstDayOfMonth: Int, runStart: Int, runEnd: Int, targetWeekday: Int, daysPerWeek: Int) -> Int? {
    guard runEnd >= runStart else { return nil }
    guard targetWeekday >= 1 && targetWeekday <= daysPerWeek else { return nil }

    // Calculate the weekday of the first day in the run
    let runStartWeekday = weekdayOf(day: runStart, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
    
    // Calculate the offset to the target weekday from the run start weekday
    let daysToTarget = (targetWeekday - runStartWeekday + daysPerWeek) % daysPerWeek
    let targetDay = runStart + daysToTarget
    
    // Check if the target day is within the run bounds
    return targetDay <= runEnd ? targetDay : nil
}

func nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: Int, monthLength: Int, targetWeekday: Int, recurrence: Int, daysPerWeek: Int) -> Int? {
    guard weekdayOfFirstDayOfMonth >= 1 && weekdayOfFirstDayOfMonth <= daysPerWeek else { return nil }
    guard targetWeekday >= 1 && targetWeekday <= daysPerWeek else { return nil }
    guard monthLength > 0 else { return nil }

    // Calculate the day of the first occurrence of the target weekday
    let daysFromFirstDay = (targetWeekday - weekdayOfFirstDayOfMonth + daysPerWeek) % daysPerWeek
    let firstOccurrence = 1 + daysFromFirstDay

    if recurrence > 0 {
        // Calculate the n-th positive recurrence
        let nthOccurrence = firstOccurrence + (recurrence - 1) * daysPerWeek
        return nthOccurrence <= monthLength ? nthOccurrence : nil
    } else if recurrence < 0 {
        // Calculate the n-th negative recurrence
        var lastOccurrence = firstOccurrence
        while lastOccurrence + daysPerWeek <= monthLength {
            lastOccurrence += daysPerWeek
        }
        let nthNegativeOccurrence = lastOccurrence + (recurrence + 1) * daysPerWeek
        return nthNegativeOccurrence > 0 ? nthNegativeOccurrence : nil
    } else {
        // Recurrence cannot be zero
        return nil
    }
} // func nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: Int, monthLength: Int, targetWeekday: Int, recurrence: Int, daysPerWeek: Int) -> Int?


// MARK: -

fileprivate func delegatedRangedMonthAndDayForWeekday(_ components: ASADateComponents, era: Int?, year: Int?, month: Int, descriptionDay: Int, descriptionThroughDay: Int, descriptionWeekday: Int, daysPerWeek: Int) -> (month: Int?, day: Int?) {
    let newComponents = ASADateComponents(calendar: components.calendar, locationData: components.locationData, era: era, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
    let startOfFirstDayOfMonth = newComponents.date!
    let weekdayOfFirstDayOfMonth = components.calendar.dateComponents([.weekday], from: startOfFirstDayOfMonth, locationData: components.locationData).weekday!
    let month = month
    let day = dayInRunWithWeekday(weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, runStart: descriptionDay, runEnd: descriptionThroughDay, targetWeekday: descriptionWeekday, daysPerWeek: daysPerWeek)
    return (month, day)
} // func delegatedRangedMonthAndDayForWeekday(_ components: ASADateComponents, era: Int?, year: Int?, month: Int, descriptionDay: Int, descriptionThroughDay: Int, descriptionWeekday: Int, daysPerWeek: Int) -> (month: Int?, day: Int?)

func rangedMonthAndDayForWeekday(components: ASADateComponents, daysPerWeek: Int, era: Int?, year: Int?, descriptionMonth: Int, descriptionThroughMonth: Int?, descriptionDay: Int, descriptionThroughDay: Int, descriptionWeekday: Int) -> (month: Int?, day: Int?) {
    if descriptionThroughMonth == nil {
        return delegatedRangedMonthAndDayForWeekday(components, era: era, year: year, month: descriptionMonth, descriptionDay: descriptionDay, descriptionThroughDay: descriptionThroughDay, descriptionWeekday: descriptionWeekday, daysPerWeek: daysPerWeek)
    } else {
        // We need to split this up into two checks:  one for the first month and one for the last month.
        let lastDayInFirstMonth = (components.calendar.daysInMonth(locationData: components.locationData, era: era!, year: year!, month: descriptionMonth))!
        let (firstMonth, firstDay) = delegatedRangedMonthAndDayForWeekday(components, era: era, year: year, month: descriptionMonth, descriptionDay: descriptionDay, descriptionThroughDay: lastDayInFirstMonth, descriptionWeekday: descriptionWeekday, daysPerWeek: daysPerWeek)
        if firstMonth != nil && firstDay != nil {
            return (firstMonth, firstDay)
        }
        
        let (lastMonth, lastDay) = delegatedRangedMonthAndDayForWeekday(components, era: era, year: year, month: descriptionThroughMonth!, descriptionDay: 1, descriptionThroughDay: descriptionThroughDay, descriptionWeekday: descriptionWeekday, daysPerWeek: daysPerWeek)
        return (lastMonth, lastDay)
    }
} // func rangedMonthAndDayForWeekday(components: ASADateComponents, daysPerWeek: Int, era: Int?, year: Int?, descriptionMonth: Int, descriptionThroughMonth: Int?, descriptionDay: Int, descriptionThroughDay: Int, descriptionWeekday: Int) -> (month: Int?, day: Int?)
