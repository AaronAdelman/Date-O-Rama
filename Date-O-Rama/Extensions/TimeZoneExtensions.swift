//
//  TimeZoneExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 29/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension TimeZone {
    static var GMT:  TimeZone {
        return TimeZone(secondsFromGMT: 0)!
    } // static var GMT

//    func extremeAbbreviation(for date: Date) -> String {
//        let secondsFromGMT = self.secondsFromGMT(for: date)
//        let hoursFromGMT: Double = Double(secondsFromGMT) / (60.0 * 60.0)
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 2
//        formatter.minimumFractionDigits = 0
//        if hoursFromGMT > 0 {
//            formatter.positivePrefix = formatter.plusSign
//        }
//        
//        let number = NSNumber(value: hoursFromGMT)
//        let formattedValue = formatter.string(from: number)!
//        return formattedValue
//    } // func extremeAbbreviation(for date: Date) -> String
    
    func localizedName(for now: Date) -> String {
        let nameStyle: NSTimeZone.NameStyle = self.isDaylightSavingTime(for: now) ? .daylightSaving : .standard
        return self.localizedName(for: nameStyle, locale: Locale.current) ?? ""
    } // func localizedName(for now: Date) -> String
    
    var isCurrent: Bool {
        return self.identifier == TimeZone.current.identifier
    } // var isCurrent
} // extension TimeZone
