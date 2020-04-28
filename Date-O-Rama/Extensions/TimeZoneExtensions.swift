//
//  TimeZoneExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-28.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension TimeZone {
    func emoji(date:  Date) -> String {
        let HOURS = 60 * 60
        let HALF_HOUR = 30 * 60
        
        switch self.secondsFromGMT(for: date) {
        case 0, 12 * HOURS, -(12 * HOURS):
            return "🕛"
            
        case HALF_HOUR, 12 * HOURS + HALF_HOUR, -(11 * HOURS + HALF_HOUR):
            return "🕧"
            
        case 1 * HOURS, 13 * HOURS, -(11 * HOURS):
            return "🕐"
            
        case 1 * HOURS + HALF_HOUR, 13 * HOURS + HALF_HOUR, -(10 * HOURS + HALF_HOUR):
            return "🕜"
            
        case 2 * HOURS, 14 * HOURS, -(10 * HOURS):
            return "🕑"
            
        case 2 * HOURS + HALF_HOUR, -(9 * HOURS + HALF_HOUR):
            return "🕝"
            
        case 3 * HOURS, -(9 * HOURS):
            return "🕒"
            
        case 3 * HOURS + HALF_HOUR, -(8 * HOURS + HALF_HOUR):
            return "🕞"
            
        case 4 * HOURS, -(8 * HOURS):
            return "🕓"
            
        case 4 * HOURS + HALF_HOUR, -(7 * HOURS + HALF_HOUR):
            return "🕟"
            
        case 5 * HOURS, -(7 * HOURS):
            return "🕔"
            
        case 5 * HOURS + HALF_HOUR, -(6 * HOURS + HALF_HOUR):
            return "🕠"
            
        case 6 * HOURS, -(6 * HOURS):
            return "🕕"
            
        case 6 * HOURS + HALF_HOUR, -(5 * HOURS + HALF_HOUR):
            return "🕡"
            
        case 7 * HOURS, -(5 * HOURS):
            return "🕖"
            
        case 7 * HOURS + HALF_HOUR, -(4 * HOURS + HALF_HOUR):
            return "🕢"
            
        case 8 * HOURS, -(4 * HOURS):
            return "🕗"
            
        case 8 * HOURS + HALF_HOUR, -(3 * HOURS + HALF_HOUR):
            return "🕣"
            
        case 9 * HOURS, -(3 * HOURS):
            return "🕘"
            
        case 9 * HOURS + HALF_HOUR, -(2 * HOURS + HALF_HOUR):
            return "🕤"
            
        case 10 * HOURS, -(2 * HOURS):
            return "🕙"
            
        case 10 * HOURS + HALF_HOUR, -(1 * HOURS + HALF_HOUR):
            return "🕥"
            
        case 11 * HOURS, -(1 * HOURS):
            return "🕦"
            
        case 11 * HOURS + HALF_HOUR, -(HALF_HOUR):
            return "🕜"
            
        default:
            return "⚪️"
        }
    }
} // extension TimeZone
