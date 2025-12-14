//
//  TimeZoneExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 29/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension TimeZone {
    static var gmt:  TimeZone {
        return TimeZone(secondsFromGMT: 0)!
    } // static var GMT
    
    func localizedName(for now: Date) -> String {
        let nameStyle: NSTimeZone.NameStyle = self.isDaylightSavingTime(for: now) ? .daylightSaving : .standard
        return self.localizedName(for: nameStyle, locale: Locale.current) ?? ""
    } // func localizedName(for now: Date) -> String
    
    var isCurrent: Bool {
        return self.identifier == TimeZone.current.identifier
    } // var isCurrent
} // extension TimeZone
