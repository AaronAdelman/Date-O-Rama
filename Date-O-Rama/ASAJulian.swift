//
//  ASAJulian.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

// Based on “Algorithms for Julian Dates” by Richard L. Branham, Jr. (https://dl.acm.org/doi/pdf/10.1145/219340.219343).
// Comments are left intact to make it easier to figure out what is going on.

/*
 Routine to calculate a Julian day number for a year, month, and day given on the Julian calendar. Dates B.C. should be expressed in astronomical format (.i.e.) dateB.C. = -(date - 1). Thus, 747B.C. = -746. Input to routine are the year, month, and day expressed as integers; output is the Julian day number as a double-precision floating-point number.
 */

func julian(year: Int, mo: Int, day: Int) -> Double {
    var jd: Double
    var sum = 0
    var begin_year: Int
    
    /* Correct for difference between astronomical and civil time */
    var dayAsDouble: Double = Double(day)
    dayAsDouble -= 0.5
    /* Calculate Julian day number for the beginning of the year. */
    begin_year = ((1461*(4712 + year) - 1)/4)
    jd = Double(begin_year)
    if (year == -4712) {
        jd -= 1
    }
    /* Add the number of days in the month */
    jd += dayAsDouble
    /* Sum the number of days in the preceding months */
    for i in 1..<mo {
        if (i == 2) {
            sum += 28
        } else {
            if i == 4 || i == 6 || i == 9 || i == 11 {
                sum += 30
            } else {
                sum += 31
            }
        }
    }
    jd += Double(sum)
    
    /* Add one more day if a leap year */
    if (mo > 2 && (4 * (year / 4) - year ) == 0 ) {
        jd += 1
    }
    return jd
} // func julian(year: Int, mo: Int, day: Int) -> Double


/*
Function to take a Julian date and convert it to a day, month and year on the Julian calendar. The program or function that calls this routine must pass the addresses of the integer variables yr (year) and mo (month) and the double-precision variable day.
 */

func julian_ymd(jd: Double) -> (yr: Int, mo: Int, day: Double) {
    var begin_year: Int
    var jdhold: Double
    var yr: Int
    var mo: Int
    var day: Double
    
    if (fabs(jd) < 1e-15) { /* Consider JD 0 a special case */
        yr = -4712;
        mo = 1
        day = 0.5
        return (yr, mo, day)
    }
    
    jdhold = jd;
    /* Find number of Julian years in the Julian date */
    var JulianDate = jd
    JulianDate /= 365.25
    JulianDate -= 4712.0 // Subtract origin of Julian date
    /* Calculate the year */
    yr = Int(JulianDate);
    if (JulianDate < 0.0) {
        yr -= 1
    }
    /* Find Julian day number of beginning of year */
    begin_year = (1461 * (4712 + yr) - 1) / 4
    /* Find number of days since beginning of year */
    day = jdhold - Double(begin_year) + 0.5
    mo = 1  /* Calculate the month and day */
    if (day > 31.0) {
        while(day > 31.0) {
            if (mo == 2) {
                if (yr % 4 == 0) {
                    day -= 29.0
                } else {
                    day -= 28.0
                }
            } else {
                if (mo == 4 || mo == 6 || mo == 9 || mo == 11) {
                    day -= 30.0
                } else {
                    day -= 31.0
                }
            }
            mo += 1
        }
    }
    return (yr, mo, day)
} // func julian_ymd(jd: Double) -> (yr: Int, mo: Int, day: Double)

/*
Function to calculate the day of the week that corresponds with a day, month, and year on the Julian calendar. The routine returns a pointer to a string. The calling program or function should declare a pointer-to-string variable to receive the value return.
*/

func day_of_week(year inYear: Int, mo inMo: Int, day: Int) -> Int {
    var year = inYear
    var mo   = inMo
    
    var m: Int
    var n: Int
    year += 4732 /* Make all years positive */
    if (mo == 1 || mo == 2) { /* January and February are months 13 and 14 of the preceding year */
        mo += 12
        year -= 1
    }
   /* Calculate a parameter "n" that gives the day of the week */
    m = day + 2 * mo + (3 * mo + 3) / 5 + year + year / 4 + 6
    n = m % 7 + 1
    assert(n >= 1)
    assert(n <= 7)
    return n
} // func day_of_week(year inYear: Int, mo inMo: Int, day: Int) -> Int


// MARK: -

func JulianComponents(date: Date, timeZone: TimeZone) -> (year: Int, month: Int, day: Int, weekday: Int) {
    var dateAsJulianDate = date.addingTimeInterval(-18.0 * 60.0 * 60.0 - Double(timeZone.secondsFromGMT(for: date))).JulianDate
    
    var GregorianCalendar = Calendar.gregorian
    GregorianCalendar.timeZone = timeZone
    let GregorianComponents = GregorianCalendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
    if GregorianComponents.hour == 0 && GregorianComponents.minute == 0 && GregorianComponents.second == 0 && GregorianComponents.nanosecond == 0 {
        dateAsJulianDate += 1
    }
    
    let JulianComponents = julian_ymd(jd: dateAsJulianDate)
    let day: Int = Int(ceil(JulianComponents.day))
    let JulianDayOfWeek = day_of_week(year: JulianComponents.yr, mo: JulianComponents.mo, day: day)
    return (JulianComponents.yr, JulianComponents.mo, Int(ceil(JulianComponents.day)), JulianDayOfWeek)
} // func JulianComponents(date: Date, timeZone: TimeZone) -> (year: Int, month: Int, day: Int, weekday: Int)

func dateFromJulianComponents(year: Int, month: Int, day: Int, timeZone: TimeZone) -> Date? {
    guard month >=  1 else { return nil }
    guard month <= 12 else { return nil }
    guard day   >=  1 else { return nil }
    guard day   <= 31 else { return nil }
    
    let JulianDate = julian(year: year, mo: month, day: day)
    let secondsFromGMT = timeZone.secondsFromGMT()
    let date = Date.date(JulianDate: JulianDate).addingTimeInterval(TimeInterval(secondsFromGMT))
    return date
} // func dateFromJulianComponents(year: Int, month: Int, day: Int, timeZone: TimeZone) -> Date?
