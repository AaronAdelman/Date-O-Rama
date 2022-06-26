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
} // struct ASALocationWithClocks


// MARK:  -

extension Array where Element == ASALocationWithClocks {
    func processed(now:  Date) -> Array<ASALocationWithProcessedClocks> {
        var result: Array<ASALocationWithProcessedClocks> = []
        
        for locationWithClocks in self {
            let location = locationWithClocks.location
            let processedClocks = locationWithClocks.clocks.processed(now: now)
            let locationWithProcessedClocks = ASALocationWithProcessedClocks(location: location, processedClocks: processedClocks)
            result.append(locationWithProcessedClocks)
        } // for locationWithClocks in self
        return result
    } // func processed(now:  Date) -> Array<ASALocationWithProcessedClocks>
} // extension Array where Element == ASALocationWithClocks

