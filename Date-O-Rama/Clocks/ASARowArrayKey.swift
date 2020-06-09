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
    case threeLineLarge     = "modularLarge"
    case modularSmall     = "modularSmall"
    case circularSmall    = "circularSmall"
    case extraLarge       = "extraLarge"
    case utilitarianLarge = "utilitarianLarge"
    case utilitarianSmall      = "utilitarian"
} // enum ASARowArrayKeys:  String

extension ASARowArrayKey {
    func minimumNumberOfRows() -> Int {
        switch self {
        case .app:
            return 1
            
        case .threeLineLarge:
            return 3
            
        case .modularSmall:
            return 2
            
        case .circularSmall:
            return 2
            
        case .extraLarge:
            return 2

        case .utilitarianLarge:
            return 1
            
        case .utilitarianSmall:
            return 1
        } // switch self
    } // func minimumNumberOfRows() -> Int
} // extension ASARowArrayKey
