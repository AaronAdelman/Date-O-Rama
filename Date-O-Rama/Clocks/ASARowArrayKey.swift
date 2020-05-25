//
//  ASARowArrayKey.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-08-17.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

enum ASARowArrayKey:  String {
    case app              = "app"
    case modularLarge     = "modularLarge"
    case modularSmall     = "modularSmall"
    case circularSmall    = "circularSmall"
    case utilitarianLarge = "utilitarianLarge"
    case utilitarian      = "utilitarian"
} // enum ASARowArrayKeys:  String

extension ASARowArrayKey {
    func minimumNumberOfRows() -> Int {
        switch self {
        case .app:
            return 1
            
        case .modularLarge:
            return 3
            
        case .modularSmall:
            return 2
            
        case .circularSmall:
            return 2
            
        case .utilitarianLarge:
            return 1
            
        case .utilitarian:
            return 1
        } // switch self
    } // func minimumNumberOfRows() -> Int
} // extension ASARowArrayKey
