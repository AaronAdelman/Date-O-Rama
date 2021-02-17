//
//  String+ASARow+ASAUserDataExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

extension String {
    func row(backupIndex:  Int) -> ASARow {
        let tempUUID = UUID(uuidString: self)
        if tempUUID == nil {
            return ASARow.generic
        }
        
        let temp = ASAUserData.shared.mainRows.first(where: {$0.uuid == tempUUID!})
        if temp != nil {
            return temp!
        }
        
        if ASAUserData.shared.mainRows.count >= backupIndex + 1 {
            return ASAUserData.shared.mainRows[backupIndex]
        }
        
        return ASARow.generic
    } // func row(backupIndex:  Int) -> ASARow
} // extension String
