//
//  ASALocationWithClocks.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 26/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation

struct ASALocationWithClocks {
    var location: ASALocation
    var clocks: Array<ASAClock>
    
    func processed(now: Date) -> ASALocationWithProcessedClocks {
        let location = self.location
        let processedClocks = self.clocks.processed(now: now)
        let locationWithProcessedClocks = ASALocationWithProcessedClocks(location: location, processedClocks: processedClocks)
        return locationWithProcessedClocks
    } // func processed(now: Date) -> ASALocationWithProcessedClocks
} // struct ASALocationWithClocks


// MARK:  -

extension Array where Element == ASALocationWithClocks {
    var clocks: Array<ASAClock> {
        var result: Array<ASAClock> = []
        for entry in self {
            result.append(contentsOf: entry.clocks)
        } // for entry in self
        return result
    } // var clocks: Array<ASAClock>
} // extension Array where Element == ASALocationWithClocks

