//
//  ASAStringExtensions.swift
//  DoubleDate
//
//  Created by אהרן שלמה אדלמן on 2018-08-05.
//  Copyright © 2018 Adelsoft. All rights reserved.
//

import Foundation

extension String {
    func chop() -> Array<String> {
        let selfAsArray = Array(self)
        
        var i = 0
        var resultsArray:  Array<String> = []
        while i < selfAsArray.count {
            let runElement = selfAsArray[i]
            //    print(runElement)
            var j = i
            
            while (j < selfAsArray.count) && (runElement == selfAsArray[j]) {
                j += 1
            }
            let runString = String.init(repeatElement(runElement, count: j - i))
            resultsArray.append(runString)
            i = j
        }
        return resultsArray
    } // func chop() -> Array<String>
} // extension String
