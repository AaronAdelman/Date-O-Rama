//
//  ASARowArrayKey.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2018-08-17.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

enum ASARowArrayKey:  String {
    case app            = "app"
    case threeLineLarge = "modularLarge"
    case twoLineSmall   = "modularSmall"
    case twoLineLarge   = "extraLarge"
    case oneLineLarge   = "utilitarianLarge"
    case oneLineSmall   = "utilitarian"
} // enum ASARowArrayKeys:  String

extension ASARowArrayKey {
    var minimumNumberOfRows:  Int {
        switch self {
        case .app:
            return 1
            
        case .threeLineLarge:
            return 3
            
        case .twoLineSmall:
            return 2
                        
        case .twoLineLarge:
            return 2

        case .oneLineLarge:
            return 1
            
        case .oneLineSmall:
            return 1
        } // switch self
    } // var minimumNumberOfRows
    
    static var complicationSections:  Array<ASARowArrayKey> {
        return [
            .threeLineLarge,
            .twoLineSmall,
            .twoLineLarge,
            .oneLineLarge,
            .oneLineSmall
        ]
    } // static var complicationSections
} // extension ASARowArrayKey
