//
//  ASAWeeks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 01/08/2024.
//  Copyright © 2024 Adelsoft. All rights reserved.
//

import Foundation

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
    let fullWeekStart = nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, monthLength: monthLength, targetWeekday: firstDayOfWeek, recurrence: fullWeek, daysPerWeek: daysPerWeek)
    guard let fullWeekStart = fullWeekStart else { return nil }
    return (fullWeekStart, fullWeekStart + daysPerWeek - 1)
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

