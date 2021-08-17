//
//  Date_O_RamaTests.swift
//  Date-O-RamaTests
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import XCTest
@testable import Date_O_Rama
import CoreLocation
import SwiftAA

class Date_O_RamaTests: XCTestCase {
    let testDate:  Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 12
        dateComponents.day = 16
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        dateComponents.hour = 10
        dateComponents.minute = 57

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)!
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

    func examineJulianDayCalendar(code:  ASACalendarCode, expectedResult:  String) {
        let LOCALE_IDENTIFIER = "en_US"
        let DATE_FORMAT       = ASADateFormat.full
        let TIME_FORMAT       = ASATimeFormat.medium

        let calendar = ASACalendarFactory.calendar(code: code)
        let result = calendar?.dateTimeString(now: testDate, localeIdentifier: LOCALE_IDENTIFIER, dateFormat: DATE_FORMAT, timeFormat: TIME_FORMAT, locationData: ASALocation.NullIsland)
        XCTAssert(result == expectedResult)
    } // func examineJulianDayCalendar(code:  ASACalendarCode, expectedResult:  String)
    
    func testHebrewNumerals() throws {
        XCTAssert(1.HebrewNumeral == "א׳")
        XCTAssert(2.HebrewNumeral == "ב׳")
        XCTAssert(3.HebrewNumeral == "ג׳")
        XCTAssert(4.HebrewNumeral == "ד׳")
        XCTAssert(5.HebrewNumeral == "ה׳")
        XCTAssert(6.HebrewNumeral == "ו׳")
        XCTAssert(7.HebrewNumeral == "ז׳")
        XCTAssert(8.HebrewNumeral == "ח׳")
        XCTAssert(9.HebrewNumeral == "ט׳")
        XCTAssert(10.HebrewNumeral == "י׳")
        XCTAssert(11.HebrewNumeral == "י״א")
        XCTAssert(12.HebrewNumeral == "י״ב")
        XCTAssert(13.HebrewNumeral == "י״ג")
        XCTAssert(14.HebrewNumeral == "י״ד")
        XCTAssert(15.HebrewNumeral == "ט״ו")
        XCTAssert(16.HebrewNumeral == "ט״ז")
        XCTAssert(17.HebrewNumeral == "י״ז")
        XCTAssert(18.HebrewNumeral == "י״ח")
        XCTAssert(19.HebrewNumeral == "י״ט")
        XCTAssert(20.HebrewNumeral == "כ׳")
        XCTAssert(21.HebrewNumeral == "כ״א")
        XCTAssert(22.HebrewNumeral == "כ״ב")
        XCTAssert(23.HebrewNumeral == "כ״ג")
        XCTAssert(24.HebrewNumeral == "כ״ד")
        XCTAssert(25.HebrewNumeral == "כ״ה")
        XCTAssert(26.HebrewNumeral == "כ״ו")
        XCTAssert(27.HebrewNumeral == "כ״ז")
        XCTAssert(28.HebrewNumeral == "כ״ח")
        XCTAssert(29.HebrewNumeral == "כ״ט")
        XCTAssert(30.HebrewNumeral == "ל׳")
    } // func testHebrewNumerals() throws

    func testJulianDates() throws {
        XCTAssert(testDate.JulianDate == 2459199.95625)

        examineJulianDayCalendar(code: .JulianDay, expectedResult: "2459199.956250")
        examineJulianDayCalendar(code: .ReducedJulianDay, expectedResult: "59199.956250")
        examineJulianDayCalendar(code: .ModifiedJulianDay, expectedResult: "59199.456250")
        examineJulianDayCalendar(code: .TruncatedJulianDay, expectedResult: "19199")
        examineJulianDayCalendar(code: .DublinJulianDay, expectedResult: "44179.956250")
        examineJulianDayCalendar(code: .CNESJulianDay, expectedResult: "25917.456250")
        examineJulianDayCalendar(code: .CCSDSJulianDay, expectedResult: "22995.456250")
        examineJulianDayCalendar(code: .LilianDate, expectedResult: "160040")
        examineJulianDayCalendar(code: .RataDie, expectedResult: "737775")
    } // func testJulianDates() throws
    
    func testMatchingNumbers() throws {
        XCTAssert(0.matches(value: nil))
        XCTAssert(0.matches(value: 0))
        XCTAssertFalse(0.matches(value: 1))

        XCTAssert(0.matches(values: nil))
        XCTAssert(0.matches(values: [0]))
        XCTAssert(0.matches(values: [0, 1]))
        XCTAssertFalse(0.matches(values: [1]))

//        XCTAssert(1.matches(weekdays: nil))
        XCTAssert(1.matches(weekdays: [ASAWeekday.sunday]))
        XCTAssert(1.matches(weekdays: [ASAWeekday.sunday, ASAWeekday.monday]))
        XCTAssertFalse(1.matches(weekdays: [ASAWeekday.monday]))
    } // func testMatching() throws
    
    func testMatchingStartAndEnd() throws {
        //        let BCE = 0
        let CE = 1
        
        let components0 = ASADateComponents(calendar: ASACalendarFactory.calendar(code: .Gregorian)!, locationData: ASALocation.NullIsland, era: CE, year: 2021, yearForWeekOfYear: nil, quarter: nil, month: 2, isLeapMonth: nil, weekOfMonth: nil, weekOfYear: nil, weekday: 4, weekdayOrdinal: nil, day: 17, hour: 14, minute: 32, second: 15, nanosecond: 123)
        let startDateSpecification0 = ASADateSpecification(month: 01, day: 01, weekdays: [ASAWeekday.sunday, ASAWeekday.monday, ASAWeekday.tuesday, ASAWeekday.wednesday, ASAWeekday.thursday, ASAWeekday.friday, ASAWeekday.saturday], type: ASATimeSpecificationType.oneDay)
        let endDateSpecification0 = ASADateSpecification(month: 12, day: 31, weekdays: [ASAWeekday.sunday, ASAWeekday.monday, ASAWeekday.tuesday, ASAWeekday.wednesday, ASAWeekday.thursday, ASAWeekday.friday, ASAWeekday.saturday], type: ASATimeSpecificationType.oneDay)
        
        let components0EYMD = components0.EYMD
        let startDateSpecification0EMYD = startDateSpecification0.EYMD
        let endDateSpecification0EYMD = endDateSpecification0.EYMD
        
        XCTAssert(components0EYMD == [CE, 2021, 2, 17])
        XCTAssert(startDateSpecification0EMYD == [nil, nil, 1, 1])
        XCTAssert(endDateSpecification0EYMD == [nil, nil, 12, 31])
        XCTAssert(components0EYMD.isWithin(start: startDateSpecification0EMYD, end: endDateSpecification0EYMD))
        
        let (filledInStartDateSpecification0EMYD, filledInEndDateSpecification0EMYD) = components0EYMD.fillInFor(start: startDateSpecification0EMYD, end: endDateSpecification0EYMD)
        XCTAssert(filledInStartDateSpecification0EMYD == [CE, 2021, 1, 1])
        XCTAssert(filledInEndDateSpecification0EMYD   == [CE, 2021, 12, 31])
        
        let filledInStartDateSpecification0 = startDateSpecification0.fillIn(EYMD: filledInStartDateSpecification0EMYD)
        let filledInEndDateSpecification0 = endDateSpecification0.fillIn(EYMD: filledInEndDateSpecification0EMYD)
        XCTAssert(filledInStartDateSpecification0.era == CE)
        XCTAssert(filledInStartDateSpecification0.year == 2021)
        XCTAssert(filledInStartDateSpecification0.month == 1)
        XCTAssert(filledInStartDateSpecification0.day == 1)
        XCTAssert(filledInEndDateSpecification0.era == CE)
        XCTAssert(filledInEndDateSpecification0.year == 2021)
        XCTAssert(filledInEndDateSpecification0.month == 12)
        XCTAssert(filledInEndDateSpecification0.day == 31)
        
        let AbstractDecember30: Array<Int?> = [nil, nil, 12, 30]
        let AbstractJanuary2: Array<Int?> = [nil, nil, 1, 2]
        
        let December29: Array<Int?> = [1, 2020, 12, 29]
        let December30: Array<Int?> = [1, 2020, 12, 30]
        let December31: Array<Int?> = [1, 2020, 12, 31]
        let January1: Array<Int?> = [1, 2021, 1, 1]
        let January2: Array<Int?> = [1, 2021, 1, 2]
        let January3: Array<Int?> = [1, 2021, 1, 3]
        
        XCTAssertFalse(December29.isWithin(start: AbstractDecember30, end: AbstractJanuary2))
        XCTAssert(December30.isWithin(start: AbstractDecember30, end: AbstractJanuary2))
        XCTAssert(December31.isWithin(start: AbstractDecember30, end: AbstractJanuary2))
        XCTAssert(January1.isWithin(start: AbstractDecember30, end: AbstractJanuary2))
        XCTAssert(January2.isWithin(start: AbstractDecember30, end: AbstractJanuary2))
        XCTAssertFalse(January3.isWithin(start: AbstractDecember30, end: AbstractJanuary2))
        
        let foo = ([1, 2020, 12, 30], [1, 2021, 1, 2])
        XCTAssert(December30.fillInFor(start: AbstractDecember30, end: AbstractJanuary2) == foo)
        XCTAssert(December31.fillInFor(start: AbstractDecember30, end: AbstractJanuary2) == foo)
        XCTAssert(January1.fillInFor(start: AbstractDecember30, end: AbstractJanuary2) == foo)
        XCTAssert(January2.fillInFor(start: AbstractDecember30, end: AbstractJanuary2) == foo)
        
        let SecondAbstractDecember30: Array<Int?> = [nil, 2020, 12, 30]
        let SecondAbstractJanuary2: Array<Int?> = [nil, 2021, 1, 2]
        
        XCTAssertFalse(December29.isWithin(start: SecondAbstractDecember30, end: SecondAbstractJanuary2))
        XCTAssert(December30.isWithin(start: SecondAbstractDecember30, end: SecondAbstractJanuary2))
        XCTAssert(December31.isWithin(start: SecondAbstractDecember30, end: SecondAbstractJanuary2))
        XCTAssert(January1.isWithin(start: SecondAbstractDecember30, end: SecondAbstractJanuary2))
        XCTAssert(January2.isWithin(start: SecondAbstractDecember30, end: SecondAbstractJanuary2))
        XCTAssertFalse(January3.isWithin(start: SecondAbstractDecember30, end: SecondAbstractJanuary2))
        
        XCTAssert(December30.fillInFor(start: SecondAbstractDecember30, end: SecondAbstractJanuary2) == foo)
        XCTAssert(December31.fillInFor(start: SecondAbstractDecember30, end: SecondAbstractJanuary2) == foo)
        XCTAssert(January1.fillInFor(start: SecondAbstractDecember30, end: SecondAbstractJanuary2) == foo)
        XCTAssert(January2.fillInFor(start: SecondAbstractDecember30, end: SecondAbstractJanuary2) == foo)
        
        let ThirdAbstractDecember30: Array<Int?> = [nil, 2020, 12, 30]
        let ThirdAbstractJanuary2: Array<Int?> = [nil, 2021, 1, 2]
        
        XCTAssertFalse(December29.isWithin(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2))
        XCTAssert(December30.isWithin(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2))
        XCTAssert(December31.isWithin(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2))
        XCTAssert(January1.isWithin(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2))
        XCTAssert(January2.isWithin(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2))
        XCTAssertFalse(January3.isWithin(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2))
        
        XCTAssert(December30.fillInFor(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2) == foo)
        XCTAssert(December31.fillInFor(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2) == foo)
        XCTAssert(January1.fillInFor(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2) == foo)
        XCTAssert(January2.fillInFor(start: ThirdAbstractDecember30, end: ThirdAbstractJanuary2) == foo)
        
        let AbstractMarch6: Array<Int?> = [nil, nil, 3, 6]
        let AbstractMarch28: Array<Int?> = [nil, nil, 3, 28]
        let AbstractApril1: Array<Int?> = [nil, nil, 4, 1]
        
        XCTAssertFalse(December29.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(December29.isWithin(start: AbstractMarch28, end: AbstractMarch6))
        XCTAssertFalse(December29.isWithin(start: AbstractMarch6, end: AbstractApril1))
        XCTAssert(December29.isWithin(start: AbstractApril1, end: AbstractMarch6))
        
        XCTAssert(December29.fillInFor(start: AbstractMarch28, end: AbstractMarch6) == ([1, 2020, 3, 28], [1, 2021, 3, 6]))
        XCTAssert(December29.fillInFor(start: AbstractApril1, end: AbstractMarch6) == ([1, 2020, 4, 1], [1, 2021, 3, 6]))
        
        let March1: Array<Int?> = [1, 2021, 3, 1]
        let March2: Array<Int?> = [1, 2021, 3, 2]
        let March3: Array<Int?> = [1, 2021, 3, 3]
        let March4: Array<Int?> = [1, 2021, 3, 4]
        let March5: Array<Int?> = [1, 2021, 3, 5]
        let March6: Array<Int?> = [1, 2021, 3, 6]
        let March7: Array<Int?> = [1, 2021, 3, 7]
        let March8: Array<Int?> = [1, 2021, 3, 8]
        let March9: Array<Int?> = [1, 2021, 3, 9]
        let March10: Array<Int?> = [1, 2021, 3, 10]
        let March11: Array<Int?> = [1, 2021, 3, 11]
        let March12: Array<Int?> = [1, 2021, 3, 12]
        let March13: Array<Int?> = [1, 2021, 3, 13]
        let March14: Array<Int?> = [1, 2021, 3, 14]
        let March15: Array<Int?> = [1, 2021, 3, 15]
        let March16: Array<Int?> = [1, 2021, 3, 16]
        let March17: Array<Int?> = [1, 2021, 3, 17]
        let March18: Array<Int?> = [1, 2021, 3, 18]
        let March19: Array<Int?> = [1, 2021, 3, 19]
        let March20: Array<Int?> = [1, 2021, 3, 20]
        let March21: Array<Int?> = [1, 2021, 3, 21]
        let March22: Array<Int?> = [1, 2021, 3, 22]
        let March23: Array<Int?> = [1, 2021, 3, 23]
        let March24: Array<Int?> = [1, 2021, 3, 24]
        let March25: Array<Int?> = [1, 2021, 3, 25]
        let March26: Array<Int?> = [1, 2021, 3, 26]
        let March27: Array<Int?> = [1, 2021, 3, 27]
        let March28: Array<Int?> = [1, 2021, 3, 28]
        let March29: Array<Int?> = [1, 2021, 3, 29]
        let March30: Array<Int?> = [1, 2021, 3, 30]
        
        XCTAssertFalse(March1.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssertFalse(March2.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssertFalse(March3.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssertFalse(March4.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssertFalse(March5.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March6.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March7.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March8.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March9.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March10.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March11.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March12.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March13.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March14.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March15.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March16.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March17.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March18.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March19.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March20.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March21.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March22.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March23.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March24.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March25.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March26.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March27.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssert(March28.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssertFalse(March29.isWithin(start: AbstractMarch6, end: AbstractMarch28))
        XCTAssertFalse(March30.isWithin(start: AbstractMarch6, end: AbstractMarch28))

        let foo2 = ([1, 2021, 3, 6], [1, 2021, 3, 28])
        
        XCTAssert(March6.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March7.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March8.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March9.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March10.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March11.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March12.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March13.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March14.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March15.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March16.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March17.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March18.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March19.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March20.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March21.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March22.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March23.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March24.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March25.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March26.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March27.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
        XCTAssert(March28.fillInFor(start: AbstractMarch6, end: AbstractMarch28) == foo2)
    } // func testMatchingStartAndEnd() throws
    
    func testMatchingStartAndEnd2() throws {
        let bar: Array<Int?> = [0, 5781, 8, 2]
        let quux0: Array<Int?> = [nil, nil, 1, 1]
        let quux1: Array<Int?> = [nil, nil, 1, 10]
        XCTAssertFalse(bar.isWithin(start: quux0, end: quux1))
    } // func testMatchingStartAndEnd2() throws
    
    func testMatchingStartAndEnd3() throws {
        // Inspired by יום גאולה של יוסף יצחק שניאורסאהן, which falls on י״ב בתמוז and י״ג בתמוז
        let Tammuz12: Array<Int?> = [0, 5781, 11, 12]
        let Tammuz13: Array<Int?> = [0, 5781, 11, 13]
        let Tammuz14: Array<Int?> = [0, 5781, 11, 14]
        let Tammuz15: Array<Int?> = [0, 5781, 11, 15]
        let eventStart: Array<Int?> = [nil, nil, 11, 12]
        let eventEnd: Array<Int?> = [nil, nil, 11, 13]
        
        XCTAssert(Tammuz12.isWithin(start: eventStart, end: eventEnd))
        XCTAssert(Tammuz13.isWithin(start: eventStart, end: eventEnd))
        XCTAssertFalse(Tammuz14.isWithin(start: eventStart, end: eventEnd))
        XCTAssertFalse(Tammuz15.isWithin(start: eventStart, end: eventEnd))

        let (_, filledInEndDateEYMDTammuz12) = Tammuz12.fillInFor(start: eventStart, end: eventEnd)
        XCTAssertFalse(filledInEndDateEYMDTammuz12[1] == 5782)

        let (_, filledInEndDateEYMDTammuz13) = Tammuz13.fillInFor(start: eventStart, end: eventEnd)
        XCTAssertFalse(filledInEndDateEYMDTammuz13[1] == 5782)
        
        let EYMD0: Array<Int?> = [nil, nil, 11, 12]
        let EYMD1: Array<Int?> = [nil, nil, 11, 13]
        
        XCTAssert(Array.areBoring(start: EYMD0, end: EYMD1))
        XCTAssertFalse(Array.areBoring(start: EYMD1, end: EYMD0))
    }
    
    func testChangingTheCalendarOfAClock() throws {
        let clock = ASARow()
        clock.calendar = ASACalendarFactory.calendar(code: .Gregorian)!

        clock.iCalendarEventCalendars =  ASAEKEventManager.shared.EKCalendars(titles: ["A", "B", "C"])
        clock.builtInEventCalendars = [ASAEventCalendar(fileName: "Western zodiac events")]
        
        clock.calendar = ASACalendarFactory.calendar(code: .CCSDSJulianDay)!
        XCTAssert(clock.iCalendarEventCalendars.count == 0)
        XCTAssert(clock.builtInEventCalendars.count == 0)
    } // func testChangingTheCalendarOfAClock() throws
    
    func testExtremeTimeZoneAbbreviation() throws {
        let now = Date(timeIntervalSinceNow: 0.0)
        let SECONDS_PER_HOUR = 60 * 60
        
        XCTAssert(TimeZone(secondsFromGMT: 0)!.extremeAbbreviation(for: now) == "0")
        XCTAssert(TimeZone(secondsFromGMT: 1 * SECONDS_PER_HOUR)!.extremeAbbreviation(for: now) == "‎+1")
        XCTAssert(TimeZone(secondsFromGMT: Int(1.25 * Double(SECONDS_PER_HOUR)))!.extremeAbbreviation(for: now) == "‎+1.25")
        XCTAssert(TimeZone(secondsFromGMT: Int(1.5 * Double(SECONDS_PER_HOUR)))!.extremeAbbreviation(for: now) == "‎+1.5")
        XCTAssert(TimeZone(secondsFromGMT: 2 * SECONDS_PER_HOUR)!.extremeAbbreviation(for: now) == "‎+2")
        XCTAssert(TimeZone(secondsFromGMT: -1 * SECONDS_PER_HOUR)!.extremeAbbreviation(for: now) == "‎-1")
    } // func testExtremeTimeZoneAbbreviation() throws
    
    func testIslamicPrayerTimes() throws {
        let timeZoneSeconds = 3 * 60 * 60

        let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(secondsFromGMT: timeZoneSeconds), year: 2021, month: 7, day: 13, hour: 12, minute: 0, second: 0)
        let calendar = Calendar(identifier: .gregorian)
        let date: Date = calendar.date(from: dateComponents)!

        let events: [ASAIslamicPrayerTimeEvent] = [.Fajr, .Sunrise, .Dhuhr, .Asr, .Sunset, .Maghrib, .Isha]
        let times = date.prayerTimesSunsetTransition(latitude: 32.088889, longitude: 34.886389, calcMethod: .Jafari, asrJuristic: .Shafii, dhuhrMinutes: 0.0, adjustHighLats: .midnight, events: events)

        let formatter1 = DateFormatter()
        formatter1.locale = Locale(identifier: "en_US")

        formatter1.dateStyle = .medium
        formatter1.timeStyle = .medium
        formatter1.timeZone = .current

        var transformedTimes: Dictionary<ASAIslamicPrayerTimeEvent, String> = [:]
        for (key, value) in times ?? [:] {
            transformedTimes[key] = formatter1.string(from: value)
        } // for (key, value) in times ?? [:]
                
        let SunriseString = transformedTimes[.Sunrise]!
        XCTAssert(SunriseString == "Jul 13, 2021 at 5:43:57 AM", "Sunrise:  \(SunriseString)")

        let MaghribString = transformedTimes[.Maghrib]!
        XCTAssert(MaghribString == "Jul 12, 2021 at 8:05:36 PM", "Maghrib:  \(MaghribString)")

        let FajrString = transformedTimes[.Fajr]!
        XCTAssert(FajrString == "Jul 13, 2021 at 4:18:39 AM", "Fajr:  \(FajrString)")

        let AsrString = transformedTimes[.Asr]!
        XCTAssert(AsrString == "Jul 13, 2021 at 4:27:10 PM", "Asr:  \(AsrString)")

        let DhuhrString = transformedTimes[.Dhuhr]!
        XCTAssert(DhuhrString == "Jul 13, 2021 at 12:46:17 PM", "Dhuhr:  \(DhuhrString)")

        let IshaString = transformedTimes[.Isha]!
        XCTAssert(IshaString == "Jul 12, 2021 at 9:01:58 PM", "Isha:  \(IshaString)")

        let SunsetString = transformedTimes[.Sunset]!
        XCTAssert(SunsetString == "Jul 12, 2021 at 7:48:42 PM", "Sunset:  \(SunsetString)")
    } // func testIslamicPrayerTimes() throws
    
    func testFirst() throws {
        let first1: Array<Int?> = [nil, nil, nil, nil]
        let first2: Array<Int?> = [1, 2019, 1, 4]

        let start1: Array<Int?> = [1, 2022, 1, 4]
        let start2: Array<Int?> = [1, 2021, 1, 4]
        let start3: Array<Int?> = [1, 2020, 1, 4]
        let start4: Array<Int?> = [1, 2019, 1, 4]
        let start5: Array<Int?> = [1, 2018, 1, 4]
        
        XCTAssert(start1.isAfterOrEqual(first: first1))
    
        XCTAssert(start1.isAfterOrEqual(first: first2))
        XCTAssert(start2.isAfterOrEqual(first: first2))
        XCTAssert(start3.isAfterOrEqual(first: first2))
        XCTAssert(start4.isAfterOrEqual(first: first2))
        XCTAssertFalse(start5.isAfterOrEqual(first: first2))
    } // func testFirst() throws
    
    func testNthRecurrenceOfWeekdayInMonth() throws {
        let LENGTH_OF_WEEK = 7
        
        XCTAssert(1.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(2.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(3.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(4.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(5.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(6.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(7.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(8.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(9.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(10.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(11.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(12.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(13.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(14.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(15.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(16.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(17.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(18.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(19.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(20.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(21.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(22.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(23.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(24.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(25.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(26.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(27.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(28.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(29.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(30.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(31.matches(recurrence: 1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        
        XCTAssertFalse(1.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(2.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(3.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(4.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(5.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(6.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(7.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(8.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(9.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(10.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(11.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(12.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(13.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(14.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(15.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(16.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(17.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(18.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(19.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(20.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(21.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(22.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(23.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(24.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(25.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(26.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(27.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(28.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(29.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(30.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(31.matches(recurrence: 2, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))

        XCTAssertFalse(1.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(2.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(3.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(4.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(5.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(6.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(7.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(8.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(9.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(10.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(11.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(12.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(13.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(14.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(15.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(16.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(17.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(18.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(19.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(20.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(21.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(22.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(23.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(24.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(25.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(26.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(27.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(28.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(29.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(30.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(31.matches(recurrence: 3, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        
        XCTAssertFalse(1.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(2.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(3.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(4.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(5.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(6.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(7.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(8.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(9.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(10.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(11.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(12.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(13.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(14.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(15.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(16.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(17.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(18.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(19.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(20.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(21.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(22.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(23.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(24.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(25.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(26.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(27.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(28.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(29.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(30.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(31.matches(recurrence: 4, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        
        XCTAssertFalse(1.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(2.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(3.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(4.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(5.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(6.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(7.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(8.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(9.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(10.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(11.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(12.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(13.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(14.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(15.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(16.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(17.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(18.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(19.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(20.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(21.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(22.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(23.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(24.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(25.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(26.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(27.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(28.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(29.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(30.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(31.matches(recurrence: 5, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))

        XCTAssertFalse(1.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(2.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(3.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(4.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(5.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(6.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(7.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(8.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(9.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(10.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(11.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(12.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(13.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(14.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(15.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(16.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(17.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(18.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(19.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(20.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(21.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(22.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(23.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssertFalse(24.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(25.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(26.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(27.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(28.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(29.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(30.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
        XCTAssert(31.matches(recurrence: -1, lengthOfWeek: LENGTH_OF_WEEK, lengthOfMonth: 31))
    } // func testNthRecurrenceOfWeekdayInMonth() throws
    
    func testMoon() throws {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")

        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current

        let now = JulianDay(year: 2021, month: 8, day: 12)
        let luna = Moon(julianDay: now, highPrecision: true)
        
        let julianDayOfNextNewMoon: JulianDay = luna.time(of: .newMoon, forward: true, mean: false)
        let nextNewMoon = julianDayOfNextNewMoon.date
        let nextNewMoonString = formatter.string(from: nextNewMoon)
        debugPrint(#file, #function, julianDayOfNextNewMoon, nextNewMoonString)

        let julianDayOfNextFirstQuarter: JulianDay = luna.time(of: .firstQuarter, forward: true, mean: false)
        let nextFirstQuarter = julianDayOfNextFirstQuarter.date
        let nextFirstQuarterString = formatter.string(from: nextFirstQuarter)
        debugPrint(#file, #function, julianDayOfNextFirstQuarter, nextFirstQuarterString)

        let julianDayOfNextFullMoon: JulianDay = luna.time(of: .fullMoon, forward: true, mean: false)
        let nextFullMoon = julianDayOfNextFullMoon.date
        let nextFullMoonString = formatter.string(from: nextFullMoon)
        debugPrint(#file, #function, julianDayOfNextFullMoon, nextFullMoonString)
        
        let julianDayOfNextThirdQuarter: JulianDay = luna.time(of: .lastQuarter, forward: true, mean: false)
        let nextThirdQuarter = julianDayOfNextThirdQuarter.date
        let nextThirdQuarterString = formatter.string(from: nextThirdQuarter)
        debugPrint(#file, #function, julianDayOfNextThirdQuarter, nextThirdQuarterString)
    } // func testMoon() throws
    
    func testSun() throws {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")

        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current

        let now = JulianDay(year: 2021, month: 8, day: 16)
        let terra = Earth(julianDay: now, highPrecision: true)
        let sunrise_sunset = terra.twilights(forSunAltitude: TwilightSunAltitude.upperLimbOnHorizonWithRefraction.rawValue, coordinates: GeographicCoordinates(CLLocation(latitude: 32.088889, longitude: 34.886389)))
        let sunrise = sunrise_sunset.riseTime
        let transit = sunrise_sunset.transitTime
        let sunset = sunrise_sunset.setTime
        guard let sunriseDate = sunrise?.date else { return }
        guard let transitDate = transit?.date else { return  }
        guard let sunsetDate = sunset?.date else { return  }
        let sunriseString = formatter.string(from: sunriseDate)
        let transitString = formatter.string(from: transitDate)
        let sunsetString = formatter.string(from: sunsetDate)
        debugPrint(#file, #function, sunriseString, transitString, sunsetString)
    }
} // class Date_O_RamaTests
