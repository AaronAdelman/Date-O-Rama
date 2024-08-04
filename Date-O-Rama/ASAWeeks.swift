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

func baseForDaysOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> Int {
    let offset = weekdayOfFirstDayOfMonth == 1 ? 0: (daysPerWeek + 1 - weekdayOfFirstDayOfMonth)
    let base = offset + (fullWeek - 1) * daysPerWeek
    return base
}

/// Calculates the first and last days of a specified full week (beginning on the first day of the week) of a month.
/// - Parameters:
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - weekdayOfFirstDayOfMonth: The weekday of the first day of the month as an integer (1…the number of days per week)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: A tuple containing the starting and end days in the month for the specified full week
func daysOf(fullWeek: Int, weekdayOfFirstDayOfMonth: Int, daysPerWeek: Int) -> (Int, Int) {
    let base = baseForDaysOf(fullWeek: fullWeek, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
    return (base + 1, base + daysPerWeek)
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

func baseOfDaysOf(fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> Int {
    let weekdayOfFirstDayOfMonth = weekdayOfFirstDayOfMonth(day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    let base = baseForDaysOf(fullWeek: fullWeek, weekdayOfFirstDayOfMonth: weekdayOfFirstDayOfMonth, daysPerWeek: daysPerWeek)
    return base
}

/// Calculates the day of the month on which a specified day of the week in a specified full week falls.
/// - Parameters:
///   - weekdayOfFullWeek: The day of the week of the specified full week (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - fullWeek: Which full week (starting on the first weekday) of the month (on the Gregorian calendar 1…4)
///   - day: The day of the month
///   - weekday: The day of the week of said day of the month (for the Gregorian calendar:  Sunday = 1, Monday = 2,… Saturday = 7)
///   - daysPerWeek: The number of days per week (for the Gregorian calendar:  7)
/// - Returns: The day of the month on which the specified day of the week in the specified full week falls
func day(weekdayOfFullWeek: Int, fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> Int {
    let base = baseOfDaysOf(fullWeek: fullWeek, day: day, weekday: weekday, daysPerWeek: daysPerWeek)
    return base + weekdayOfFullWeek
} // func day(weekdayOfFullWeek: Int, fullWeek: Int, day: Int, weekday: Int, daysPerWeek: Int) -> Int
