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
    var firstDayWeekday = (weekday - offset) % daysPerWeek
    if firstDayWeekday <= 0 {
        firstDayWeekday += daysPerWeek
    }
    return firstDayWeekday
} // func weekdayOfFirstDay(day: Int, weekday: Int, daysPerWeek: Int) -> Int

func eveOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> Int {
    let offset = weekdayOfFirstDayOfMonth == 1 ? 0: (daysPerWeek + 1 - weekdayOfFirstDayOfMonth)
    let base = offset + (fullWeek - 1) * daysPerWeek
    return base
}

// TODO:  Expand the following function to accomodate full weeks starting on an arbitrary weekday.  (Thank you Europe and ISO.)
/// Calculates the first and last days of a specified full week (beginning on the first day of the week) of a month.
/// - Parameters:
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - weekdayOfFirstDayOfMonth: The weekday of the first day of the month as an integer (1…the number of days per week)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: A tuple containing the starting and end days in the month for the specified full week
func daysOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> (Int, Int) {
    let eve = eveOf(fullWeek: fullWeek, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
    return (eve + 1, eve + daysPerWeek)
} // func daysOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> (Int, Int)

/// Calculates the first and last days of a specified full week (beginning on the first day of the week) of a month.
/// - Parameters:
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - day: The day of the month
///   - weekday: The day of the week of said day of the month (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: A tuple containing the starting and end days in the month for the specified full week
func daysOf(fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> (Int, Int) {
    let weekdayOfFirstDayOfMonth = weekdayOfFirstDayOfMonth(day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    return daysOf(fullWeek: fullWeek, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
} // func daysOf(fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> (Int, Int)

func eveOf(fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> Int {
    let weekdayOfFirstDayOfMonth = weekdayOfFirstDayOfMonth(day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    let eve = eveOf(fullWeek: fullWeek, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
    return eve
}

/// Calculates the day of the month on which a specified day of the week in a specified full week falls.
/// - Parameters:
///   - weekdayOfFullWeek: The day of the week of the specified full week (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - day: The day of the month
///   - weekday: The day of the week of said day of the month (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: The day of the month on which the specified day of the week in the specified full week falls
func dayGiven(weekdayOfFullWeek: Int, fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> Int {
    // TODO:  May need to put in something to handle last full week of the month.
    let eve = eveOf(fullWeek: fullWeek, day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    return eve + weekdayOfFullWeek
} // func day(weekdayOfFullWeek: Int, fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> Int

/// Calculates the weekday of a specific day
func weekdayOf(day: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> Int {
    // Calculate the offset from the first day of the month to the specific day
    let offset = (day - 1) % daysPerWeek
    // Calculate the weekday of the specific day
    let specificDayWeekday = (weekdayOfFirstDayOfMonth + offset - 1) % daysPerWeek + 1
    return specificDayWeekday
}

/// Calculates the day in a run that falls on a specified weekday
func dayInRunWithWeekday(weekdayOfFirstDayOfMonth: Int, runStart: Int, runEnd: Int, targetWeekday: Int, daysPerWeek: Int) -> Int? {
    guard runEnd >= runStart else { return nil }
    guard targetWeekday >= 1 && targetWeekday <= daysPerWeek else { return nil }

    // Calculate the weekday of the first day in the run
    let runStartWeekday = weekdayOf(day: runStart, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
    
    // Calculate the offset to the target weekday from the run start weekday
    let daysToTarget = (targetWeekday - runStartWeekday + daysPerWeek) % 7
    let targetDay = runStart + daysToTarget
    
    // Check if the target day is within the run bounds
    return targetDay <= runEnd ? targetDay : nil
}

