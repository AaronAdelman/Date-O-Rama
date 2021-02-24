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
        XCTAssert(testDate.JulianDate() == 2459199.95625)

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
        
//        XCTAssert(0.matches(startValue: nil, endValue: nil) == .success)
//        XCTAssert(0.matches(startValue: 1, endValue: 3) == .failure)
//        XCTAssert(1.matches(startValue: 1, endValue: 3) == .propogateDown)
//        XCTAssert(2.matches(startValue: 1, endValue: 3) == .success)
//        XCTAssert(3.matches(startValue: 1, endValue: 3) == .propogateDown)
//        XCTAssert(4.matches(startValue: 1, endValue: 3) == .failure)
    } // func testMatching() throws
    
    func testMatchingStartAndEnd() throws {
//        let BCE = 0
//        let CE = 1
//        
//        let components0 = ASADateComponents(calendar: ASACalendarFactory.calendar(code: .Gregorian)!, locationData: ASALocation.NullIsland, era: CE, year: 2021, yearForWeekOfYear: nil, quarter: nil, month: 2, isLeapMonth: false, weekOfMonth: nil, weekOfYear: nil, weekday: 4, weekdayOrdinal: nil, day: 17, hour: 14, minute: 32, second: 15, nanosecond: 123)
//        let startDateSpecification0 = ASADateSpecification(era: CE, year: 2021, month: 01, day: 01, weekdays: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday], lengthsOfMonth: nil, lengthsOfYear: nil, dayOfYear: nil, yearDivisor: nil, yearRemainder: nil, type: .allDay, degreesBelowHorizon: nil, rising: nil, offset: nil, solarHours: nil, dayHalf: nil)
//        let endDateSpecification0 = ASADateSpecification(era: CE, year: 2021, month: 12, day: 31, weekdays: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday], lengthsOfMonth: nil, lengthsOfYear: nil, dayOfYear: nil, yearDivisor: nil, yearRemainder: nil, type: .allDay, degreesBelowHorizon: nil, rising: nil, offset: nil, solarHours: nil, dayHalf: nil)
//        XCTAssert(components0.matchEra(startDateSpecification: startDateSpecification0, endDateSpecification: endDateSpecification0) == .propogateDown)

    } // func testMatchingStartAndEnd() throws
} // class Date_O_RamaTests
