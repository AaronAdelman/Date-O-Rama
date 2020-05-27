//
//  ASAInternalEventSourceCode.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-25.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

enum ASAInternalEventSourceCode:  String {
    case none         = ""
    case dailyJewish  = "dailyJewish"
    case allDayJewish = "allDayJewish"
    case solar        = "solar"
    case lunar        = "lunar"
} // enum ASAInternalEventSourceCode

extension ASAInternalEventSourceCode {
    func localizedName() -> String {
        var rawName = ""
        switch self {
        case .dailyJewish:  rawName = "Daily Jewish events"
            
        case .solar:  rawName = "Daily solar events"
            
        default:  rawName = ""
        } // switch self
        
        return NSLocalizedString(rawName, comment: "")
    } // func localizedName() -> String
} // extension ASAInternalEventSourceCode
