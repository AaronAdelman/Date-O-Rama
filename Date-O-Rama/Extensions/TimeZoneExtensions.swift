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
} // extension TimeZone
