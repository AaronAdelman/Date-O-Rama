//
//  DateExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-16.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension Date {
    func nextMidnight() -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let midnightToday = gregorianCalendar.startOfDay(for:self)
//        print("\(String(describing: type(of: self))) \(#function) Midnight today:  \(midnightToday)")

        let dateComponents:DateComponents = {
            var dateComp = DateComponents()
            dateComp.day = 1
            return dateComp
        }()
        let midnightTomorrow = gregorianCalendar.date(byAdding: dateComponents, to: midnightToday)
//        print("\(String(describing: type(of: self))) \(#function) Midnight tomorrow:  \(String(describing: midnightTomorrow))")
        return midnightTomorrow!
    } // func nextMidnight() -> Date
} // extension Date
