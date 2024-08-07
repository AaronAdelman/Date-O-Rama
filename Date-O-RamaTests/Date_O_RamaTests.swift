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

fileprivate func GregorianDate(era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, secondsFromGMT: Int) -> Date {
    var dateComponents = DateComponents()
    dateComponents.era      = era
    dateComponents.year     = year
    dateComponents.month    = month
    dateComponents.day      = day
    dateComponents.timeZone = TimeZone(secondsFromGMT: secondsFromGMT)
    dateComponents.hour     = hour
    dateComponents.minute   = minute
    dateComponents.second   = second

    // Create date from components
    let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
    return userCalendar.date(from: dateComponents)!
} // func GregorianDate(era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, secondsFromGMT: Int) -> Date


class Date_O_RamaTests: XCTestCase {
    
    let CharlestonLocation = CLLocation(latitude: 32.783333, longitude: -79.933333)
    let CharlestonTimeZone = TimeZone(identifier: "America/New_York")!
    
    let testDate:  Date = {
        return GregorianDate(era: 1, year: 2020, month: 12, day: 16, hour: 10, minute: 57, second: 0, secondsFromGMT: 0)
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
        
        let components0 = ASADateComponents(calendar: ASACalendarFactory.calendar(code: .Gregorian)!, locationData: ASALocation.NullIsland, era: CE, year: 2021, month: 2, weekday: 4, day: 17, hour: 14, minute: 32, second: 15, nanosecond: 123)
        let startDateSpecification0 = ASADateSpecification(month: 01, day: 01, weekdays: [ASAWeekday.sunday, ASAWeekday.monday, ASAWeekday.tuesday, ASAWeekday.wednesday, ASAWeekday.thursday, ASAWeekday.friday, ASAWeekday.saturday])
        let endDateSpecification0 = ASADateSpecification(month: 12, day: 31, weekdays: [ASAWeekday.sunday, ASAWeekday.monday, ASAWeekday.tuesday, ASAWeekday.wednesday, ASAWeekday.thursday, ASAWeekday.friday, ASAWeekday.saturday])
        
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
    
//    func testChangingTheCalendarOfAClock() throws {
//        let clock = ASAClock()
//        clock.calendar = ASACalendarFactory.calendar(code: .Gregorian)!
//
//        clock.iCalendarEventCalendars =  ASAEKEventManager.shared.EKCalendars(titles: ["A", "B", "C"])
//        clock.builtInEventCalendars = [ASAEventCalendar(fileName: "Western zodiac events")]
//        
//        clock.calendar = ASACalendarFactory.calendar(code: .CCSDSJulianDay)!
//        XCTAssert(clock.iCalendarEventCalendars.count == 0)
//        XCTAssert(clock.builtInEventCalendars.count == 0)
//    } // func testChangingTheCalendarOfAClock() throws
    
//    func testExtremeTimeZoneAbbreviation() throws {
//        let now = Date(timeIntervalSinceNow: 0.0)
//        let SECONDS_PER_HOUR = 60 * 60
//        
//        XCTAssert(TimeZone(secondsFromGMT: 0)!.extremeAbbreviation(for: now) == "0")
//        XCTAssert(TimeZone(secondsFromGMT: 1 * SECONDS_PER_HOUR)!.extremeAbbreviation(for: now) == "‎+1")
//        XCTAssert(TimeZone(secondsFromGMT: Int(1.25 * Double(SECONDS_PER_HOUR)))!.extremeAbbreviation(for: now) == "‎+1.25")
//        XCTAssert(TimeZone(secondsFromGMT: Int(1.5 * Double(SECONDS_PER_HOUR)))!.extremeAbbreviation(for: now) == "‎+1.5")
//        XCTAssert(TimeZone(secondsFromGMT: 2 * SECONDS_PER_HOUR)!.extremeAbbreviation(for: now) == "‎+2")
//        XCTAssert(TimeZone(secondsFromGMT: -1 * SECONDS_PER_HOUR)!.extremeAbbreviation(for: now) == "‎-1")
//    } // func testExtremeTimeZoneAbbreviation() throws
    
//    func testIslamicPrayerTimes() throws {
//        let timeZoneSeconds = 3 * 60 * 60
//
//        let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(secondsFromGMT: timeZoneSeconds), year: 2021, month: 7, day: 13, hour: 12, minute: 0, second: 0)
//        let calendar = Calendar(identifier: .gregorian)
//        let date: Date = calendar.date(from: dateComponents)!
//
//        let events: [ASAIslamicPrayerTimeEvent] = [.Fajr, .Sunrise, .Dhuhr, .Asr, .Sunset, .Maghrib, .Isha]
//        let times = date.prayerTimesSunsetTransition(latitude: 32.088889, longitude: 34.886389, calcMethod: .Jafari, asrJuristic: .Shafii, dhuhrMinutes: 0.0, adjustHighLats: .midnight, events: events)
//
//        let formatter1 = DateFormatter()
//        formatter1.locale = Locale(identifier: "en_US")
//
//        formatter1.dateStyle = .medium
//        formatter1.timeStyle = .medium
//        formatter1.timeZone = .current
//
//        var transformedTimes: Dictionary<ASAIslamicPrayerTimeEvent, String> = [:]
//        for (key, value) in times ?? [:] {
//            transformedTimes[key] = formatter1.string(from: value)
//        } // for (key, value) in times ?? [:]
//                
//        let SunriseString = transformedTimes[.Sunrise]!
//        XCTAssert(SunriseString == "Jul 13, 2021 at 5:43:57 AM", "Sunrise:  \(SunriseString)")
//
//        let MaghribString = transformedTimes[.Maghrib]!
//        XCTAssert(MaghribString == "Jul 12, 2021 at 8:05:36 PM", "Maghrib:  \(MaghribString)")
//
//        let FajrString = transformedTimes[.Fajr]!
//        XCTAssert(FajrString == "Jul 13, 2021 at 4:18:39 AM", "Fajr:  \(FajrString)")
//
//        let AsrString = transformedTimes[.Asr]!
//        XCTAssert(AsrString == "Jul 13, 2021 at 4:27:10 PM", "Asr:  \(AsrString)")
//
//        let DhuhrString = transformedTimes[.Dhuhr]!
//        XCTAssert(DhuhrString == "Jul 13, 2021 at 12:46:17 PM", "Dhuhr:  \(DhuhrString)")
//
//        let IshaString = transformedTimes[.Isha]!
//        XCTAssert(IshaString == "Jul 12, 2021 at 9:01:58 PM", "Isha:  \(IshaString)")
//
//        let SunsetString = transformedTimes[.Sunset]!
//        XCTAssert(SunsetString == "Jul 12, 2021 at 7:48:42 PM", "Sunset:  \(SunsetString)")
//    } // func testIslamicPrayerTimes() throws
    
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
    
//    func testMoonPhases() throws {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .medium
//        formatter.timeZone = .current
//
//        let now = JulianDay(year: 2021, month: 8, day: 12)
//        let luna = Moon(julianDay: now, highPrecision: true)
//
//        let julianDayOfNextNewMoon: JulianDay = luna.time(of: .newMoon, forward: true, mean: false)
//        let nextNewMoon = julianDayOfNextNewMoon.date
//        let nextNewMoonString = formatter.string(from: nextNewMoon)
//        debugPrint(#file, #function, julianDayOfNextNewMoon, nextNewMoonString)
//
//        let julianDayOfNextFirstQuarter: JulianDay = luna.time(of: .firstQuarter, forward: true, mean: false)
//        let nextFirstQuarter = julianDayOfNextFirstQuarter.date
//        let nextFirstQuarterString = formatter.string(from: nextFirstQuarter)
//        debugPrint(#file, #function, julianDayOfNextFirstQuarter, nextFirstQuarterString)
//
//        let julianDayOfNextFullMoon: JulianDay = luna.time(of: .fullMoon, forward: true, mean: false)
//        let nextFullMoon = julianDayOfNextFullMoon.date
//        let nextFullMoonString = formatter.string(from: nextFullMoon)
//        debugPrint(#file, #function, julianDayOfNextFullMoon, nextFullMoonString)
//
//        let julianDayOfNextThirdQuarter: JulianDay = luna.time(of: .lastQuarter, forward: true, mean: false)
//        let nextThirdQuarter = julianDayOfNextThirdQuarter.date
//        let nextThirdQuarterString = formatter.string(from: nextThirdQuarter)
//        debugPrint(#file, #function, julianDayOfNextThirdQuarter, nextThirdQuarterString)
//    } // func testMoonPhases() throws
    
//    func testMoonRiseSet() throws {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .medium
//        formatter.timeZone = TimeZone(secondsFromGMT: 3 * 60 * 60)
//
//        let now = JulianDay(year: 2021, month: 8, day: 21)
//        let luna = Moon(julianDay: now, highPrecision: true)
//        let riseTransitSet = luna.riseTransitSetTimes(for: GeographicCoordinates(CLLocation(latitude: 32.088889, longitude: 34.886389)))
//        let rise = riseTransitSet.riseTime?.date
//        let transit = riseTransitSet.transitTime?.date
//        let set = riseTransitSet.setTime?.date
//
//        debugPrint(#file, #function, "Rise:", rise as Any, "Transit:", transit as Any, "Transit error:", riseTransitSet.transitError as Any, "Set:", set as Any)
//    }
    
//    func testSun() throws {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .medium
//        formatter.timeZone = .current
//
//        let now = JulianDay(year: 2021, month: 8, day: 16)
//        let terra = Earth(julianDay: now, highPrecision: true)
//        let sunrise_sunset = terra.twilights(forSunAltitude: TwilightSunAltitude.upperLimbOnHorizonWithRefraction.rawValue, coordinates: GeographicCoordinates(CLLocation(latitude: 32.088889, longitude: 34.886389)))
//        let sunrise = sunrise_sunset.riseTime
//        let transit = sunrise_sunset.transitTime
//        let sunset = sunrise_sunset.setTime
//        guard let sunriseDate = sunrise?.date else { return }
//        guard let transitDate = transit?.date else { return  }
//        guard let sunsetDate = sunset?.date else { return  }
//        let sunriseString = formatter.string(from: sunriseDate)
//        let transitString = formatter.string(from: transitDate)
//        let sunsetString = formatter.string(from: sunsetDate)
//        debugPrint(#file, #function, sunriseString, transitString, sunsetString)
//    }
    
//    func testEquinoxesAndSolstices() throws {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .medium
//        formatter.timeZone = .current
//
//        let now = JulianDay(year: 2021, month: 8, day: 16)
//        let terra = Earth(julianDay: now, highPrecision: true)
//        
//        let MarchEquinox = terra.equinox(of: .northwardSpring)
//        let MarchEquinoxDate = MarchEquinox.date
//        let MarchEquinoxString = formatter.string(from: MarchEquinoxDate)
//        
//        let JuneSolstice = terra.solstice(of: .northernSummer)
//        let JuneSolsticeDate = JuneSolstice.date
//        let JuneSolsticeString = formatter.string(from: JuneSolsticeDate)
//        
//        let SeptemberEquinox = terra.equinox(of: .southwardSpring)
//        let SeptemberEquinoxDate = SeptemberEquinox.date
//        let SeptemberEquinoxString = formatter.string(from: SeptemberEquinoxDate)
//
//        let DecemberSolstice = terra.solstice(of: .southernSummer)
//        let DecemberSolsticeDate = DecemberSolstice.date
//        let DecemberSolsticeString = formatter.string(from: DecemberSolsticeDate)
//
//        debugPrint(#file, #function, MarchEquinoxString, JuneSolsticeString, SeptemberEquinoxString, DecemberSolsticeString)
//
//    }
    
    func testMatchRegionCodes() throws {
        let codes1 = ["a", "b", "c", REGION_CODE_Northern_Hemisphere]
        let codes2 = ["a", "b", "c", REGION_CODE_Southern_Hemisphere]
        let codes3 = [REGION_CODE_Northern_Hemisphere]
        
        XCTAssert(codes1.matches(regionCode: "a", latitude: 10.0))
        XCTAssert(codes1.matches(regionCode: "b", latitude: 10.0))
        XCTAssert(codes1.matches(regionCode: "c", latitude: 10.0))
        XCTAssert(codes1.matches(regionCode: "d", latitude: 10.0))

        XCTAssert(codes2.matches(regionCode: "a", latitude: 10.0))
        XCTAssert(codes2.matches(regionCode: "b", latitude: 10.0))
        XCTAssert(codes2.matches(regionCode: "c", latitude: 10.0))
        XCTAssertFalse(codes2.matches(regionCode: "d", latitude: 10.0))

        XCTAssert(codes1.matches(regionCode: "a", latitude: -10.0))
        XCTAssert(codes1.matches(regionCode: "b", latitude: -10.0))
        XCTAssert(codes1.matches(regionCode: "c", latitude: -10.0))
        XCTAssertFalse(codes1.matches(regionCode: "d", latitude: -10.0))

        XCTAssert(codes2.matches(regionCode: "a", latitude: -10.0))
        XCTAssert(codes2.matches(regionCode: "b", latitude: -10.0))
        XCTAssert(codes2.matches(regionCode: "c", latitude: -10.0))
        XCTAssert(codes2.matches(regionCode: "d", latitude: -10.0))
        
        XCTAssert(codes3.matches(regionCode: "IL", latitude: 34.0))
    }
    
//    func testEventMatching() throws {
//        let calendar = ASACalendarFactory.calendar(code: .HebrewGRA)!
//        let timeZone: TimeZone = TimeZone(identifier: "Asia/Jerusalem")!
//        let location = ASALocation(id: UUID(), location: CLLocation(latitude: 32.088889, longitude: 34.886389), name: "רוטשילד 101", locality: "פתח תקווה", country: "ישראל", regionCode: "IL", postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: timeZone)
////        let calendarTitle = "יהדות"
////        let calendarTitle = "יהדות · פתח תקווה"
////        let otherCalendars = [ASACalendarCode.Coptic: ASACalendarFactory.calendar(code: .Coptic)!]
//        let calendarTitle = "ירח"
//        let calendarTitle = "ירח · פתח תקווה"
////        let otherCalendars: Dictionary<ASACalendarCode, ASACalendar> = [:]
//        let regionCode = "IL"
//        let localeIdentifier = "he_IL"
//
////        let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: timeZone, era: 1, year: 2021, month: 9, day: 7, hour: 12, minute: 0, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
//        let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: timeZone, era: 1, year: 2021, month: 8, day:26, hour: 12, minute: 0, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
//
//        let date = dateComponents.date!
//        let startOfDay = calendar.startOfDay(for: date, locationData: location)
//        let startOfNextDay = calendar.startOfNextDay(date: date, locationData: location)
//        debugPrint(#file, #function, date, startOfDay, startOfNextDay)
//
////        let eventCalendar = ASAEventCalendar(fileName: "Judaism")
//        let eventCalendar = ASAEventCalendar(fileName: "Moon")
////        let events = eventCalendar.events(date: date, locationData: location, eventCalendarName: calendarTitle, calendarTitle: calendarTitle, calendar: calendar, otherCalendars: otherCalendars, regionCode: regionCode, requestedLocaleIdentifier: localeIdentifier, startOfDay: startOfDay, startOfNextDay: startOfNextDay)
//        let events = eventCalendar.events(startDate: startOfDay, endDate: startOfNextDay, locationData: location, eventCalendarName: calendarTitle, calendarTitle: calendarTitle, regionCode: regionCode, requestedLocaleIdentifier: localeIdentifier, calendar: calendar)
//
//        debugPrint(#file, #function, events)
//    }
    
    fileprivate func subtestEaster(year: Int, month: Int, day: Int, GregorianCalendar: Bool) {
        let Easter = calculateEaster(nYear: year, GregorianCalendar: GregorianCalendar)
        XCTAssert(Easter.month == month)
        XCTAssert(Easter.day == day)
    } // func subtestEaster(year: Int, month: Int, day: Int, GregorianCalendar: Bool)
    
    func testEaster() throws {
        subtestEaster(year: 2016, month: 3, day: 27, GregorianCalendar: true)
        subtestEaster(year: 2017, month: 4, day: 16, GregorianCalendar: true)
        subtestEaster(year: 2018, month: 4, day: 1, GregorianCalendar: true)
        subtestEaster(year: 2019, month: 4, day: 21, GregorianCalendar: true)
        subtestEaster(year: 2020, month: 4, day: 12, GregorianCalendar: true)
        subtestEaster(year: 2021, month: 4, day: 4, GregorianCalendar: true)
        subtestEaster(year: 2022, month: 4, day: 17, GregorianCalendar: true)
        subtestEaster(year: 2023, month: 4, day: 9, GregorianCalendar: true)
        subtestEaster(year: 2024, month: 3, day: 31, GregorianCalendar: true)
        subtestEaster(year: 2025, month: 4, day: 20, GregorianCalendar: true)
        subtestEaster(year: 2026, month: 4, day: 5, GregorianCalendar: true)

        subtestEaster(year: 2008, month: 4, day: 14, GregorianCalendar: false)
        subtestEaster(year: 2009, month: 4, day: 6, GregorianCalendar: false)
        subtestEaster(year: 2010, month: 3, day: 22, GregorianCalendar: false)
        subtestEaster(year: 2011, month: 4, day: 11, GregorianCalendar: false)
        subtestEaster(year: 2016, month: 4, day: 18, GregorianCalendar: false)
        subtestEaster(year: 2021, month: 4, day: 19, GregorianCalendar: false)
    } // func testEaster() throws
    
    func testLocalModifiedJulianDay() throws {
        let era   =    1
        let year  = 2020
        let month =   12
        let day   =   16
        let secondsFromGMT = 2 * 60 * 60
        
        let date0 = GregorianDate(era: era, year: year, month: month, day: day, hour: 0, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date1 = GregorianDate(era: era, year: year, month: month, day: day, hour: 1, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date2 = GregorianDate(era: era, year: year, month: month, day: day, hour: 2, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date3 = GregorianDate(era: era, year: year, month: month, day: day, hour: 3, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date4 = GregorianDate(era: era, year: year, month: month, day: day, hour: 4, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date5 = GregorianDate(era: era, year: year, month: month, day: day, hour: 5, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date6 = GregorianDate(era: era, year: year, month: month, day: day, hour: 6, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date7 = GregorianDate(era: era, year: year, month: month, day: day, hour: 7, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date8 = GregorianDate(era: era, year: year, month: month, day: day, hour: 8, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date9 = GregorianDate(era: era, year: year, month: month, day: day, hour: 9, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date10 = GregorianDate(era: era, year: year, month: month, day: day, hour: 10, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date11 = GregorianDate(era: era, year: year, month: month, day: day, hour: 11, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date12 = GregorianDate(era: era, year: year, month: month, day: day, hour: 12, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date13 = GregorianDate(era: era, year: year, month: month, day: day, hour: 13, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date14 = GregorianDate(era: era, year: year, month: month, day: day, hour: 14, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date15 = GregorianDate(era: era, year: year, month: month, day: day, hour: 15, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date16 = GregorianDate(era: era, year: year, month: month, day: day, hour: 16, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date17 = GregorianDate(era: era, year: year, month: month, day: day, hour: 17, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date18 = GregorianDate(era: era, year: year, month: month, day: day, hour: 18, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date19 = GregorianDate(era: era, year: year, month: month, day: day, hour: 19, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date20 = GregorianDate(era: era, year: year, month: month, day: day, hour: 20, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date21 = GregorianDate(era: era, year: year, month: month, day: day, hour: 21, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date22 = GregorianDate(era: era, year: year, month: month, day: day, hour: 22, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)
        let date23 = GregorianDate(era: era, year: year, month: month, day: day, hour: 23, minute: 0, second: 0, secondsFromGMT: secondsFromGMT)

        let timeZone = TimeZone(secondsFromGMT: secondsFromGMT)!
        let LMDJ0 = date0.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ1 = date1.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ2 = date2.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ3 = date3.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ4 = date4.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ5 = date5.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ6 = date6.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ7 = date7.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ8 = date8.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ9 = date9.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ10 = date10.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ11 = date11.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ12 = date12.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ13 = date13.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ14 = date14.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ15 = date15.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ16 = date16.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ17 = date17.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ18 = date18.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ19 = date19.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ20 = date20.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ21 = date21.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ22 = date22.localModifiedJulianDay(timeZone: timeZone)
        let LMDJ23 = date23.localModifiedJulianDay(timeZone: timeZone)
        
        debugPrint(#file, #function, LMDJ0, LMDJ1, LMDJ2, LMDJ3, LMDJ4, LMDJ5, LMDJ6, LMDJ7, LMDJ8, LMDJ9, LMDJ10, LMDJ11, LMDJ12, LMDJ13, LMDJ14, LMDJ15, LMDJ16, LMDJ17, LMDJ18, LMDJ19, LMDJ20, LMDJ21, LMDJ22, LMDJ23)

        XCTAssert(LMDJ0 == LMDJ1)
        XCTAssert(LMDJ0 == LMDJ2)
        XCTAssert(LMDJ0 == LMDJ3)
        XCTAssert(LMDJ0 == LMDJ4)
        XCTAssert(LMDJ0 == LMDJ5)
        XCTAssert(LMDJ0 == LMDJ6)
        XCTAssert(LMDJ0 == LMDJ7)
        XCTAssert(LMDJ0 == LMDJ8)
        XCTAssert(LMDJ0 == LMDJ9)
        XCTAssert(LMDJ0 == LMDJ10)
        XCTAssert(LMDJ0 == LMDJ11)
        XCTAssert(LMDJ0 == LMDJ12)
        XCTAssert(LMDJ0 == LMDJ13)
        XCTAssert(LMDJ0 == LMDJ14)
        XCTAssert(LMDJ0 == LMDJ15)
        XCTAssert(LMDJ0 == LMDJ16)
        XCTAssert(LMDJ0 == LMDJ17)
        XCTAssert(LMDJ0 == LMDJ18)
        XCTAssert(LMDJ0 == LMDJ19)
        XCTAssert(LMDJ0 == LMDJ20)
        XCTAssert(LMDJ0 == LMDJ21)
        XCTAssert(LMDJ0 == LMDJ22)
        XCTAssert(LMDJ0 == LMDJ23)
        
        let reverseDate0 = Date.date(localModifiedJulianDay: LMDJ0, timeZone: timeZone)
        let reverseDate1 = Date.date(localModifiedJulianDay: LMDJ1, timeZone: timeZone)
        let reverseDate2 = Date.date(localModifiedJulianDay: LMDJ2, timeZone: timeZone)
        let reverseDate3 = Date.date(localModifiedJulianDay: LMDJ3, timeZone: timeZone)
        let reverseDate4 = Date.date(localModifiedJulianDay: LMDJ4, timeZone: timeZone)
        let reverseDate5 = Date.date(localModifiedJulianDay: LMDJ5, timeZone: timeZone)
        let reverseDate6 = Date.date(localModifiedJulianDay: LMDJ6, timeZone: timeZone)
        let reverseDate7 = Date.date(localModifiedJulianDay: LMDJ7, timeZone: timeZone)
        let reverseDate8 = Date.date(localModifiedJulianDay: LMDJ8, timeZone: timeZone)
        let reverseDate9 = Date.date(localModifiedJulianDay: LMDJ9, timeZone: timeZone)
        let reverseDate10 = Date.date(localModifiedJulianDay: LMDJ10, timeZone: timeZone)
        let reverseDate11 = Date.date(localModifiedJulianDay: LMDJ11, timeZone: timeZone)
        let reverseDate12 = Date.date(localModifiedJulianDay: LMDJ12, timeZone: timeZone)
        let reverseDate13 = Date.date(localModifiedJulianDay: LMDJ13, timeZone: timeZone)
        let reverseDate14 = Date.date(localModifiedJulianDay: LMDJ14, timeZone: timeZone)
        let reverseDate15 = Date.date(localModifiedJulianDay: LMDJ15, timeZone: timeZone)
        let reverseDate16 = Date.date(localModifiedJulianDay: LMDJ16, timeZone: timeZone)
        let reverseDate17 = Date.date(localModifiedJulianDay: LMDJ17, timeZone: timeZone)
        let reverseDate18 = Date.date(localModifiedJulianDay: LMDJ18, timeZone: timeZone)
        let reverseDate19 = Date.date(localModifiedJulianDay: LMDJ19, timeZone: timeZone)
        let reverseDate20 = Date.date(localModifiedJulianDay: LMDJ20, timeZone: timeZone)
        let reverseDate21 = Date.date(localModifiedJulianDay: LMDJ21, timeZone: timeZone)
        let reverseDate22 = Date.date(localModifiedJulianDay: LMDJ22, timeZone: timeZone)
        let reverseDate23 = Date.date(localModifiedJulianDay: LMDJ23, timeZone: timeZone)
        
        XCTAssert(reverseDate0 == reverseDate1)
        XCTAssert(reverseDate0 == reverseDate2)
        XCTAssert(reverseDate0 == reverseDate3)
        XCTAssert(reverseDate0 == reverseDate4)
        XCTAssert(reverseDate0 == reverseDate5)
        XCTAssert(reverseDate0 == reverseDate6)
        XCTAssert(reverseDate0 == reverseDate7)
        XCTAssert(reverseDate0 == reverseDate8)
        XCTAssert(reverseDate0 == reverseDate9)
        XCTAssert(reverseDate0 == reverseDate10)
        XCTAssert(reverseDate0 == reverseDate11)
        XCTAssert(reverseDate0 == reverseDate12)
        XCTAssert(reverseDate0 == reverseDate13)
        XCTAssert(reverseDate0 == reverseDate14)
        XCTAssert(reverseDate0 == reverseDate15)
        XCTAssert(reverseDate0 == reverseDate16)
        XCTAssert(reverseDate0 == reverseDate17)
        XCTAssert(reverseDate0 == reverseDate18)
        XCTAssert(reverseDate0 == reverseDate19)
        XCTAssert(reverseDate0 == reverseDate20)
        XCTAssert(reverseDate0 == reverseDate21)
        XCTAssert(reverseDate0 == reverseDate22)
        XCTAssert(reverseDate0 == reverseDate23)
        
        debugPrint(#file, #function, reverseDate0, reverseDate1, reverseDate2, reverseDate3, reverseDate4, reverseDate5, reverseDate6, reverseDate7, reverseDate8, reverseDate9, reverseDate10, reverseDate11, reverseDate12, reverseDate13, reverseDate14, reverseDate15, reverseDate16, reverseDate17, reverseDate18, reverseDate19, reverseDate20, reverseDate21, reverseDate22, reverseDate23)
    } // func testLocalModifiedJulianDay() throws
    
    // Based on the examples in https://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
    func testDateFormatPatterns() throws {
        let pattern1 = "yyyy.MM.dd G 'at' HH:mm:ss zzz"
        let pattern1Components = pattern1.dateFormatPatternComponents
        XCTAssert(pattern1Components.count == 15)
        XCTAssert(pattern1Components[0].type == .symbol)
        XCTAssert(pattern1Components[0].string == "yyyy")
        XCTAssert(pattern1Components[1].type == .literal)
        XCTAssert(pattern1Components[1].string == ".")
        XCTAssert(pattern1Components[2].type == .symbol)
        XCTAssert(pattern1Components[2].string == "MM")
        XCTAssert(pattern1Components[3].type == .literal)
        XCTAssert(pattern1Components[3].string == ".")
        XCTAssert(pattern1Components[4].type == .symbol)
        XCTAssert(pattern1Components[4].string == "dd")
        XCTAssert(pattern1Components[5].type == .literal)
        XCTAssert(pattern1Components[5].string == " ")
        XCTAssert(pattern1Components[6].type == .symbol)
        XCTAssert(pattern1Components[6].string == "G")
        XCTAssert(pattern1Components[7].type == .literal)
        XCTAssert(pattern1Components[7].string == " at ")
        XCTAssert(pattern1Components[8].type == .symbol)
        XCTAssert(pattern1Components[8].string == "HH")
        XCTAssert(pattern1Components[9].type == .literal)
        XCTAssert(pattern1Components[9].string == ":")
        XCTAssert(pattern1Components[10].type == .symbol)
        XCTAssert(pattern1Components[10].string == "mm")
        XCTAssert(pattern1Components[11].type == .literal)
        XCTAssert(pattern1Components[11].string == ":")
        XCTAssert(pattern1Components[12].type == .symbol)
        XCTAssert(pattern1Components[12].string == "ss")
        XCTAssert(pattern1Components[13].type == .literal)
        XCTAssert(pattern1Components[13].string == " ")
        XCTAssert(pattern1Components[14].type == .symbol)
        XCTAssert(pattern1Components[14].string == "zzz")
        
        let pattern2 = "EEE, MMM d, ''yy"
        let pattern2Components = pattern2.dateFormatPatternComponents
        XCTAssert(pattern2Components.count == 7)
        XCTAssert(pattern2Components[0].type == .symbol)
        XCTAssert(pattern2Components[0].string == "EEE")
        XCTAssert(pattern2Components[1].type == .literal)
        XCTAssert(pattern2Components[1].string == ", ")
        XCTAssert(pattern2Components[2].type == .symbol)
        XCTAssert(pattern2Components[2].string == "MMM")
        XCTAssert(pattern2Components[3].type == .literal)
        XCTAssert(pattern2Components[3].string == " ")
        XCTAssert(pattern2Components[4].type == .symbol)
        XCTAssert(pattern2Components[4].string == "d")
        XCTAssert(pattern2Components[5].type == .literal)
        XCTAssert(pattern2Components[5].string == ", '")
        XCTAssert(pattern2Components[6].type == .symbol)
        XCTAssert(pattern2Components[6].string == "yy")

        let pattern3 = "h:mm a"
        let pattern3Components = pattern3.dateFormatPatternComponents
//        debugPrint(#file, #function, pattern3, pattern3Components)
        XCTAssert(pattern3Components.count == 5)
        XCTAssert(pattern3Components[0].type == .symbol)
        XCTAssert(pattern3Components[0].string == "h")
        XCTAssert(pattern3Components[1].type == .literal)
        XCTAssert(pattern3Components[1].string == ":")
        XCTAssert(pattern3Components[2].type == .symbol)
        XCTAssert(pattern3Components[2].string == "mm")
        XCTAssert(pattern3Components[3].type == .literal)
        XCTAssert(pattern3Components[3].string == " ")
        XCTAssert(pattern3Components[4].type == .symbol)
        XCTAssert(pattern3Components[4].string == "a")
        
        let pattern4 = "hh 'o''clock' a, zzzz"
        let pattern4Components = pattern4.dateFormatPatternComponents
        XCTAssert(pattern4Components.count == 5)
        XCTAssert(pattern4Components[0].type == .symbol)
        XCTAssert(pattern4Components[0].string == "hh")
        XCTAssert(pattern4Components[1].type == .literal)
        XCTAssert(pattern4Components[1].string == " o'clock ")
        XCTAssert(pattern4Components[2].type == .symbol)
        XCTAssert(pattern4Components[2].string == "a")
        XCTAssert(pattern4Components[3].type == .literal)
        XCTAssert(pattern4Components[3].string == ", ")
        XCTAssert(pattern4Components[4].type == .symbol)
        XCTAssert(pattern4Components[4].string == "zzzz")
        
        let pattern5 = "K:mm a, z"
        let pattern5Components = pattern5.dateFormatPatternComponents
        XCTAssert(pattern5Components.count == 7)
        XCTAssert(pattern5Components[0].type == .symbol)
        XCTAssert(pattern5Components[0].string == "K")
        XCTAssert(pattern5Components[1].type == .literal)
        XCTAssert(pattern5Components[1].string == ":")
        XCTAssert(pattern5Components[2].type == .symbol)
        XCTAssert(pattern5Components[2].string == "mm")
        XCTAssert(pattern5Components[3].type == .literal)
        XCTAssert(pattern5Components[3].string == " ")
        XCTAssert(pattern5Components[4].type == .symbol)
        XCTAssert(pattern5Components[4].string == "a")
        XCTAssert(pattern5Components[5].type == .literal)
        XCTAssert(pattern5Components[5].string == ", ")
        XCTAssert(pattern5Components[6].type == .symbol)
        XCTAssert(pattern5Components[6].string == "z")

        let pattern6 = "yyyyy.MMMM.dd GGG hh:mm aaa"
        let pattern6Components = pattern6.dateFormatPatternComponents
        XCTAssert(pattern6Components.count == 13)
        XCTAssert(pattern6Components[0].type == .symbol)
        XCTAssert(pattern6Components[0].string == "yyyyy")
        XCTAssert(pattern6Components[1].type == .literal)
        XCTAssert(pattern6Components[1].string == ".")
        XCTAssert(pattern6Components[2].type == .symbol)
        XCTAssert(pattern6Components[2].string == "MMMM")
        XCTAssert(pattern6Components[3].type == .literal)
        XCTAssert(pattern6Components[3].string == ".")
        XCTAssert(pattern6Components[4].type == .symbol)
        XCTAssert(pattern6Components[4].string == "dd")
        XCTAssert(pattern6Components[5].type == .literal)
        XCTAssert(pattern6Components[5].string == " ")
        XCTAssert(pattern6Components[6].type == .symbol)
        XCTAssert(pattern6Components[6].string == "GGG")
        XCTAssert(pattern6Components[7].type == .literal)
        XCTAssert(pattern6Components[7].string == " ")
        XCTAssert(pattern6Components[8].type == .symbol)
        XCTAssert(pattern6Components[8].string == "hh")
        XCTAssert(pattern6Components[9].type == .literal)
        XCTAssert(pattern6Components[9].string == ":")
        XCTAssert(pattern6Components[10].type == .symbol)
        XCTAssert(pattern6Components[10].string == "mm")
        XCTAssert(pattern6Components[11].type == .literal)
        XCTAssert(pattern6Components[11].string == " ")
        XCTAssert(pattern6Components[12].type == .symbol)
        XCTAssert(pattern6Components[12].string == "aaa")
    } // func testDateFormatPatterns() throws
    
    func testDateFormatPatterns2() throws {
        // Some language with the code "nnh"
        let pattern7 = "EEEE , \'lyɛ\'̌ʼ d \'na\' MMMM, y"
        let pattern7Components = pattern7.dateFormatPatternComponents
        debugPrint(#file, #function, pattern7, pattern7Components)
        XCTAssert(pattern7Components.count == 7)
        XCTAssert(pattern7Components[0].type == .symbol)
        XCTAssert(pattern7Components[0].string == "EEEE")
        XCTAssert(pattern7Components[1].type == .literal)
        XCTAssert(pattern7Components[1].string == " , lyɛ̌ʼ ")
        XCTAssert(pattern7Components[2].type == .symbol)
        XCTAssert(pattern7Components[2].string == "d")
        XCTAssert(pattern7Components[3].type == .literal)
        XCTAssert(pattern7Components[3].string == " na ")
        XCTAssert(pattern7Components[4].type == .symbol)
        XCTAssert(pattern7Components[4].string == "MMMM")
        XCTAssert(pattern7Components[5].type == .literal)
        XCTAssert(pattern7Components[5].string == ", ")
        XCTAssert(pattern7Components[6].type == .symbol)
        XCTAssert(pattern7Components[6].string == "y")

        // Basque (euskara)
        let pattern8 = "y(\'e\')\'ko\' MMMM\'ren\' d(\'a\'), EEEE"
        let pattern8Components = pattern8.dateFormatPatternComponents
        debugPrint(#file, #function, pattern8, pattern8Components)
        XCTAssert(pattern8Components.count == 7)
        XCTAssert(pattern8Components[0].type == .symbol)
        XCTAssert(pattern8Components[0].string == "y")
        XCTAssert(pattern8Components[1].type == .literal)
        XCTAssert(pattern8Components[1].string == "(e)ko ")
        XCTAssert(pattern8Components[2].type == .symbol)
        XCTAssert(pattern8Components[2].string == "MMMM")
        XCTAssert(pattern8Components[3].type == .literal)
        XCTAssert(pattern8Components[3].string == "ren ")
        XCTAssert(pattern8Components[4].type == .symbol)
        XCTAssert(pattern8Components[4].string == "d")
        XCTAssert(pattern8Components[5].type == .literal)
        XCTAssert(pattern8Components[5].string == "(a), ")
        XCTAssert(pattern8Components[6].type == .symbol)
        XCTAssert(pattern8Components[6].string == "EEEE")
    } // func testDateFormatPatterns2() throws
    
    func testApril30ToMay1() throws {
        // This test checks whether on April 30, 2021 and May 1, 2021 in Charleston, SC the code correctly reports there being both Sunrise and Sunset
        let events: Array<ASASolarEvent> = [.sunrise, .sunset]
        
        let April30 = GregorianDate(era: 1, year: 2021, month: 4, day: 30, hour: 16, minute: 0, second: 0, secondsFromGMT: 0)
        let April30Events = April30.solarEvents(location: CharlestonLocation, events: events, timeZone: CharlestonTimeZone)
        debugPrint(#file, #function, April30, April30Events)
        XCTAssert(April30Events.count == 2)

        let May1 = GregorianDate(era: 1, year: 2021, month: 5, day: 1, hour: 16, minute: 0, second: 0, secondsFromGMT: 0)
        let May1Events = May1.solarEvents(location: CharlestonLocation, events: events, timeZone: CharlestonTimeZone)
        debugPrint(#file, #function, May1, May1Events)
        XCTAssert(May1Events.count == 2)
    } // func testApril30ToMay1() throws
    
    func testPisces() throws {
        // This test checks whether multi-months are working right.  The Pisces event for the Jewish zodiac event calendars was reporting no end date, leading to a debugging session to find and fix the problem.
        let startDateSpecification = ASADateSpecification(pointEventType: nil, era: nil, year: nil, month: 6, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil, weekdays: nil, weekdayRecurrence: nil, lengthsOfMonth: nil, lengthsOfYear: [383, 384, 385], dayOfYear: nil, yearDivisor: nil, yearRemainder: nil, offsetDays: nil, throughDay: nil, degreesBelowHorizon: nil, rising: nil, offset: nil, solarHours: nil, dayHalf: nil, body: nil, calculationMethod: nil, asrJuristicMethod: nil, adjustingMethodForHigherLatitudes: nil, dhuhrMinutes: nil, Easter: nil, equinoxOrSolstice: nil, timeChange: nil, MoonPhase: nil)
        let endDateSpecification: ASADateSpecification = ASADateSpecification(pointEventType: nil, era: nil, year: nil, month: 7, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil, weekdays: nil, weekdayRecurrence: nil, lengthsOfMonth: nil, lengthsOfYear: [383, 384, 385], dayOfYear: nil, yearDivisor: nil, yearRemainder: nil, offsetDays: nil, throughDay: nil, degreesBelowHorizon: nil, rising: nil, offset: nil, solarHours: nil, dayHalf: nil, body: nil, calculationMethod: nil, asrJuristicMethod: nil, adjustingMethodForHigherLatitudes: nil, dhuhrMinutes: nil, Easter: nil, equinoxOrSolstice: nil, timeChange: nil, MoonPhase: nil)
        let filledInStartDateEYM: Array<Int?> = [0, 5782, 6]
        let filledInEndDateEYM: Array<Int?> = [0, 5782, 7]
        
        let tweakedStartDateSpecification = startDateSpecification.fillIn(EYM: filledInStartDateEYM)
        
        let tweakedEndDateSpecification = endDateSpecification.fillIn(EYM: filledInEndDateEYM)

        XCTAssert(tweakedStartDateSpecification.era == 0)
        XCTAssert(tweakedStartDateSpecification.year == 5782)
        XCTAssert(tweakedStartDateSpecification.month == 6)
        XCTAssert(tweakedEndDateSpecification.era == 0)
        XCTAssert(tweakedEndDateSpecification.year == 5782)
        XCTAssert(tweakedEndDateSpecification.month == 7)
        
        let calendar: ASACalendar = ASACalendarFactory.calendar(code: .HebrewGRA)!
        let date = GregorianDate(era: 1, year: 2021, month: 3, day: 3, hour: 16, minute: 8, second: 31, secondsFromGMT: 2 * 60 * 60)
        let timeZone = TimeZone(identifier: "Asia/Jerusalem")!
        let location = ASALocation(id: UUID(), location: CLLocation(latitude: 32.088889, longitude: 34.886389), name: "רוטשילד 101", locality: "פתח תקווה", country: "ישראל", regionCode: "IL", postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: timeZone, type: .EarthLocation)

        let components: ASADateComponents = ASADateComponents(calendar: calendar, locationData: location, era: 0, year: 5782, yearForWeekOfYear: nil, quarter: nil, month: 6, isLeapMonth: false, weekOfMonth: nil, weekOfYear: nil, weekday: 5, weekdayOrdinal: nil, day: 30, hour: 12, minute: nil, second: nil, nanosecond: nil, solarHours: nil, dayHalf: nil)

        let startDate = tweakedStartDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: false, baseDate: date, type: .multiMonth)
        let endDate = tweakedEndDateSpecification.date(dateComponents: components, calendar: calendar, isEndDate: true, baseDate: date, type: .multiMonth)
        
        debugPrint(#file, #function, startDate as Any, endDate as Any)
        XCTAssert(startDate != nil)
        XCTAssert(endDate != nil)
    }
    
    func testEventRelevance() throws {
        let startDate = GregorianDate(era: 1, year: 2022, month: 5, day: 26, hour: 3, minute: 17, second: 50, secondsFromGMT: 3 * Int(Date.SECONDS_PER_HOUR))
        let endDate = GregorianDate(era: 1, year: 2022, month: 5, day: 27, hour: 3, minute: 17, second: 50, secondsFromGMT: 3 * Int(Date.SECONDS_PER_HOUR))
        
        let eventStartDate = GregorianDate(era: 1, year: 2022, month: 5, day: 26, hour: 3, minute: 17, second: 11, secondsFromGMT: 3 * Int(Date.SECONDS_PER_HOUR))
        let eventEndDate = GregorianDate(era: 1, year: 2022, month: 5, day: 26, hour: 3, minute: 17, second: 50, secondsFromGMT: 3 * Int(Date.SECONDS_PER_HOUR))
        
        let event = ASAEvent(eventIdentifier: UUID().uuidString, title: "Foo", startDate: eventStartDate, endDate: eventEndDate, isAllDay: true, timeZone: CharlestonTimeZone, color: .blue, uuid: UUID(), calendarTitleWithLocation: "Foo", calendarTitle: "Foo", calendarCode: .HebrewGRA, locationData: ASALocation.NullIsland, status: .none, hasAttendees: false, attendees: nil, hasAlarms: false, availability: .notSupported, isReadOnly: true, type: .oneDay)
        
        XCTAssertFalse(event.relevant(startDate: startDate, endDate: endDate))
    }
    
    func reportOn(name: String, location: CLLocation, timeZone: TimeZone) {
        let previousDate = GregorianDate(era: 1, year: 2022, month: 5, day: 25, hour: 12, minute: 00, second: 00, secondsFromGMT: 3 * Int(Date.SECONDS_PER_HOUR))
        let date = GregorianDate(era: 1, year: 2022, month: 5, day: 26, hour: 12, minute: 00, second: 00, secondsFromGMT: 3 * Int(Date.SECONDS_PER_HOUR))
        let previousEvents = previousDate.solarEvents(location: location, events: [ASASolarEvent.sunrise, ASASolarEvent.sunset], timeZone: timeZone)
        let events = date.solarEvents(location: location, events: [ASASolarEvent.sunrise, ASASolarEvent.sunset], timeZone: timeZone)
        let previousSunrise: Date?? = previousEvents[.sunrise]
        let previousSunset: Date?? = previousEvents[.sunset]
        let sunrise: Date?? = events[.sunrise]
        let sunset: Date?? = events[.sunset]
        debugPrint("🔹 \(name):", "Offset from GMT:", Double(timeZone.secondsFromGMT(for: date))/Date.SECONDS_PER_HOUR, "Previous Sunrise:", previousSunrise!!, "Previous Sunset:", previousSunset!!, "Sunrise:", sunrise!!, "Sunset:", sunset!!)
    }
    
    func testSolarEvents() throws {
        let LosAngelesLocation = CLLocation(latitude: 34.05, longitude: -118.25)
        let LosAngelesTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        
        reportOn(name: "Charleston", location: CharlestonLocation, timeZone: CharlestonTimeZone)
        reportOn(name: "Los Angeles", location: LosAngelesLocation, timeZone: LosAngelesTimeZone)
    }
    
    func testFirstAdventSunday() throws {
        let startMD: Array<Int?> = [11, 27]
        let endMD: Array<Int?> = [12, 3]
        let componentsMD: Array<Int?> = [12, 3]
        
        XCTAssert(componentsMD.isWithin(start: startMD, end: endMD))
    }
    
//    func debugPrintJulianComponents(era: Int, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, timeZone: TimeZone) {
//        let date = GregorianDate(era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: second, secondsFromGMT: timeZone.secondsFromGMT())
//        let components = JulianComponents(date: date, timeZone: timeZone)
//        debugPrint(#file, #function, hour, components)
//    }
    
//    func testJulianCalendarAlgorithms() throws {
//        let timeZone: TimeZone = TimeZone(identifier: "Asia/Jerusalem")!
//
//        let June13NS_0 = GregorianDate(era: 1, year: 2022, month: 6, day: 13, hour: 0, minute: 0, second: 0, secondsFromGMT: timeZone.secondsFromGMT())
//        let June13NS_0Components = JulianComponents(date: June13NS_0, timeZone: timeZone)
////        debugPrint(#file, #function, June13NS_0Components)
//        assert(June13NS_0Components.year    == 2022)
//        assert(June13NS_0Components.month   ==    5)
//        assert(June13NS_0Components.day     ==   31)
//        assert(June13NS_0Components.weekday ==    2)
//
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 12, hour: 23, minute: 0, second: 0, timeZone: timeZone)
////
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 0, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 1, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 2, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 3, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 4, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 5, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 6, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 7, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 8, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 9, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 10, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 11, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 12, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 13, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 14, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 15, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 16, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 17, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 18, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 19, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 20, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 21, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 22, minute: 0, second: 0, timeZone: timeZone)
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 13, hour: 23, minute: 0, second: 0, timeZone: timeZone)
////
////        debugPrintJulianComponents(era: 1, year: 2022, month: 6, day: 14, hour: 0, minute: 0, second: 0, timeZone: timeZone)
//
//        let May31OS = dateFromJulianComponents(era: 1, year: 2022, month: 5, day: 31, timeZone: timeZone)
//        debugPrint(#file, #function, May31OS as Any)
//    }
    
    func testMarsSolDate() throws {
        let date = GregorianDate(era: 1, year: 2022, month: 7, day: 13, hour: 13, minute: 39, second: 0, secondsFromGMT: 0)
        let MSD: Double = date.MarsSolDate
        let reverseDate = Date.date(MarsSolDate: MSD)
        let error: TimeInterval = date.timeIntervalSince(reverseDate)
        debugPrint(#file, #function, date, MSD, reverseDate, error)
        assert(abs(error) < 1.0e-5)
    }
    
//    func testMidnightSun() throws {
//        let saintLouisSecondsFromGMT: Int = -6 * Int(Date.SECONDS_PER_HOUR)
//        let date = GregorianDate(era: 1, year: 2023, month: 1, day: 15, hour: 23, minute: 56, second: 0, secondsFromGMT: saintLouisSecondsFromGMT)
//
//        let saintLouisCLLocation = CLLocation(latitude: 38.627222, longitude: -90.197778)
//        let saintLouisTimeZone: TimeZone = TimeZone(secondsFromGMT: saintLouisSecondsFromGMT)!
//        let saintLouisLocation = ASALocation(id: UUID(), location: saintLouisCLLocation, name: "Saint Louis", locality: "Missouri", country: "United States", regionCode: "US", postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: saintLouisTimeZone, type: .EarthLocation)
//
//        let hebrewCalendar = ASACalendarFactory.calendar(code: .HebrewGRA)!
//        let localeIdentifier = "he_IL"
//        let dateFormat = ASADateFormat.full
//        let timeFormat = ASATimeFormat.decimalTwelveHour
//
//        let stringsAndComponents = hebrewCalendar.dateStringTimeStringDateComponents(now: date, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: saintLouisLocation)
//        debugPrint("🕛", #file, #function, stringsAndComponents as Any)
//
//
//    } // func testMidnightSun() throws
    
    func testMidnightSun2() throws {
        let pethaḥTiqwahSecondsFromGMT: Int = 3 * Int(Date.SECONDS_PER_HOUR)
        let date = GregorianDate(era: 1, year: 2023, month: 5, day: 9, hour: 0, minute: 0, second: 0, secondsFromGMT: pethaḥTiqwahSecondsFromGMT)
        
        let pethaḥTiqwahCLLocation = CLLocation(latitude: 32.088889, longitude: 34.886389)
        let pethaḥTiqwahTimeZone: TimeZone = TimeZone(secondsFromGMT: pethaḥTiqwahSecondsFromGMT)!
        let pethaḥTiqwahLocation = ASALocation(id: UUID(), location: pethaḥTiqwahCLLocation, name: "פתח תקווה", locality: "", country: "Israel", regionCode: "IL", postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: pethaḥTiqwahTimeZone, type: .EarthLocation)
        
        let hebrewCalendar = ASACalendarFactory.calendar(code: .HebrewGRA)!
        let localeIdentifier = "he_IL"
        let dateFormat = ASADateFormat.full
        let timeFormat = ASATimeFormat.decimalTwelveHour
        
        let stringsAndComponents = hebrewCalendar.dateStringTimeStringDateComponents(now: date, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: pethaḥTiqwahLocation)
        
        
        debugPrint("🕛", #file, #function, stringsAndComponents as Any)
        
        XCTAssert(stringsAndComponents.dateComponents.dayHalf == .night)
    } //
    
    func testMidnight() throws {
        let pethaḥTiqwahSecondsFromGMT: Int = 3 * Int(Date.SECONDS_PER_HOUR)
        let date = GregorianDate(era: 1, year: 2023, month: 5, day: 9, hour: 0, minute: 35, second: 40, secondsFromGMT: pethaḥTiqwahSecondsFromGMT)
        
        let pethaḥTiqwahCLLocation = CLLocation(latitude: 32.088889, longitude: 34.886389)
        let pethaḥTiqwahTimeZone: TimeZone = TimeZone(secondsFromGMT: pethaḥTiqwahSecondsFromGMT)!
        let pethaḥTiqwahLocation = ASALocation(id: UUID(), location: pethaḥTiqwahCLLocation, name: "פתח תקווה", locality: "", country: "Israel", regionCode: "IL", postalCode: nil, administrativeArea: nil, subAdministrativeArea: nil, subLocality: nil, thoroughfare: nil, subThoroughfare: nil, timeZone: pethaḥTiqwahTimeZone, type: .EarthLocation)
        
        let hebrewCalendar = ASACalendarFactory.calendar(code: .HebrewGRA)!
        let localeIdentifier = "he_IL"
        let dateFormat = ASADateFormat.full
        let timeFormat = ASATimeFormat.decimalTwelveHour
        
        let stringsAndComponents = hebrewCalendar.dateStringTimeStringDateComponents(now: date, localeIdentifier: localeIdentifier, dateFormat: dateFormat, timeFormat: timeFormat, locationData: pethaḥTiqwahLocation)
        
        
        debugPrint("🕛", #file, #function, stringsAndComponents as Any)
        
//        XCTAssert(stringsAndComponents.dateComponents.dayHalf == .night)
    } //
    
    func testNationalPlayOutsideDay() throws {
        let start: Array<Int?> = [1, 2024, 1, 6]
        let first: Array<Int?> = [1, 2011, 4, nil]
        XCTAssert(start.isAfterOrEqual(first: first))
    } // func testNationalPlayOutsideDay() throws
    
    func testDayOfWeekOf1stDayOMonth() throws {
        XCTAssert(weekdayOfFirstDayOfMonth(day: 1, weekday: 1, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 2, weekday: 2, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 3, weekday: 3, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 4, weekday: 4, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 5, weekday: 5, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 6, weekday: 6, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 7, weekday: 7, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 8, weekday: 1, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 9, weekday: 2, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 10, weekday: 3, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 11, weekday: 4, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 12, weekday: 5, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 13, weekday: 6, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 14, weekday: 7, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 15, weekday: 1, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 16, weekday: 2, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 17, weekday: 3, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 18, weekday: 4, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 19, weekday: 5, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 20, weekday: 6, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 21, weekday: 7, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 22, weekday: 1, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 23, weekday: 2, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 24, weekday: 3, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 25, weekday: 4, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 26, weekday: 5, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 27, weekday: 6, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 28, weekday: 7, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 29, weekday: 1, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 30, weekday: 2, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOfFirstDayOfMonth(day: 31, weekday: 3, daysPerWeek: 7) == 1)
    } // func testDayOfWeekOf1stDayOMonth() throws
    
    func testFullWeeks() throws {
        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (1, 7))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (8, 14))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (15, 21))
        XCTAssert(daysOf(fullWeek: 4, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (22, 28))
    
        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 2, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (7, 13))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 2, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (14, 20))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 2, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (21, 27))

        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 3, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (6, 12))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 3, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (13, 19))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 3, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (20, 26))

        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 4, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (5, 11))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 4, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (12, 18))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 4, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (19, 25))

        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 5, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (4, 10))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 5, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (11, 17))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 5, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (18, 24))
        XCTAssert(daysOf(fullWeek: 4, weekdayOfFirstDayOfMonth: 5, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (25, 31))

        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 6, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (3, 9))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 6, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (10, 16))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 6, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (17, 23))
        XCTAssert(daysOf(fullWeek: 4, weekdayOfFirstDayOfMonth: 6, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (24, 30))

        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 7, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (2, 8))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 7, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (9, 15))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 7, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (16, 22))
        XCTAssert(daysOf(fullWeek: 4, weekdayOfFirstDayOfMonth: 7, daysPerWeek: 7, monthLength: 31, firstDayOfWeek: 1)! == (23, 29))

        XCTAssert(daysOf(fullWeek: 1, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 10, monthLength: 30, firstDayOfWeek: 1)! == (1, 10))
        XCTAssert(daysOf(fullWeek: 2, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 10, monthLength: 30, firstDayOfWeek: 1)! == (11, 20))
        XCTAssert(daysOf(fullWeek: 3, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 10, monthLength: 30, firstDayOfWeek: 1)! == (21, 30))
        
        XCTAssert(dayGiven(weekdayOfFullWeek: 1, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 1)
        XCTAssert(dayGiven(weekdayOfFullWeek: 2, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 2)
        XCTAssert(dayGiven(weekdayOfFullWeek: 3, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 3)
        XCTAssert(dayGiven(weekdayOfFullWeek: 4, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 4)
        XCTAssert(dayGiven(weekdayOfFullWeek: 5, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 5)
        XCTAssert(dayGiven(weekdayOfFullWeek: 6, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 6)
        XCTAssert(dayGiven(weekdayOfFullWeek: 7, fullWeek: 1, day: 1, weekday: 1, daysPerWeek: 7, monthLength: 30, firstDayOfWeek: 1) == 7)
    } // func testFullWeeks() throws
    
    func testDayOfWeek() throws {
        XCTAssert(weekdayOf(day: 1, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 1)
        XCTAssert(weekdayOf(day: 2, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 2)
        XCTAssert(weekdayOf(day: 3, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 3)
        XCTAssert(weekdayOf(day: 4, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 4)
        XCTAssert(weekdayOf(day: 5, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 5)
        XCTAssert(weekdayOf(day: 6, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 6)
        XCTAssert(weekdayOf(day: 7, weekdayOfFirstDayOfMonth: 1, daysPerWeek: 7) == 7)
    } // func testDayOfWeek() throws
    
    func testNthWeekdayRecurrence() throws {
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 1, recurrence: 1, daysPerWeek: 10) == 1)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 2, recurrence: 1, daysPerWeek: 10) == 2)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 3, recurrence: 1, daysPerWeek: 10) == 3)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 4, recurrence: 1, daysPerWeek: 10) == 4)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 5, recurrence: 1, daysPerWeek: 10) == 5)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 6, recurrence: 1, daysPerWeek: 10) == 6)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 7, recurrence: 1, daysPerWeek: 10) == 7)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 8, recurrence: 1, daysPerWeek: 10) == 8)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 9, recurrence: 1, daysPerWeek: 10) == 9)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 10, recurrence: 1, daysPerWeek: 10) == 10)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 1, recurrence: 2, daysPerWeek: 10) == 11)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 2, recurrence: 2, daysPerWeek: 10) == 12)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 3, recurrence: 2, daysPerWeek: 10) == 13)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 4, recurrence: 2, daysPerWeek: 10) == 14)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 5, recurrence: 2, daysPerWeek: 10) == 15)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 6, recurrence: 2, daysPerWeek: 10) == 16)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 7, recurrence: 2, daysPerWeek: 10) == 17)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 8, recurrence: 2, daysPerWeek: 10) == 18)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 9, recurrence: 2, daysPerWeek: 10) == 19)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 10, recurrence: 2, daysPerWeek: 10) == 20)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 1, recurrence: 3, daysPerWeek: 10) == 21)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 2, recurrence: 3, daysPerWeek: 10) == 22)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 3, recurrence: 3, daysPerWeek: 10) == 23)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 4, recurrence: 3, daysPerWeek: 10) == 24)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 5, recurrence: 3, daysPerWeek: 10) == 25)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 6, recurrence: 3, daysPerWeek: 10) == 26)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 7, recurrence: 3, daysPerWeek: 10) == 27)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 8, recurrence: 3, daysPerWeek: 10) == 28)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 9, recurrence: 3, daysPerWeek: 10) == 29)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 10, recurrence: 3, daysPerWeek: 10) == 30)
        XCTAssert(nthWeekdayRecurrence(weekdayOfFirstDayOfMonth: 1, monthLength: 30, targetWeekday: 1, recurrence: 4, daysPerWeek: 10) == nil)
    } // func testNthWeekdayRecurrence() throws
} // class Date_O_RamaTests
