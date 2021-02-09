//
//  ArrayExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 08/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import Foundation

//extension Array where Element == Int {
//    var EKWeekdays:  Array<EKWeekday> {
//        var result: Array<EKWeekday> = []
//        for weekday in self {
//            assert(weekday >= 1)
//            assert(weekday <= 7)
//
//            switch weekday {
//            case 1:
//                result.append(.sunday)
//
//            case 2:
//                result.append(.monday)
//
//            case 3:
//                result.append(.tuesday)
//
//            case 4:
//                result.append(.wednesday)
//
//            case 5:
//                result.append(.thursday)
//
//            case 6:
//                result.append(.friday)
//
//            case 7:
//                result.append(.saturday)
//
//            default:
//                result = result + []
//            }
//        } // for weekday in self
//        return result
//    } // var EKWeekdays:  Array<EKWeekday>
//} // extension Array where Element == Int


// MARK:  -

extension Array where Element == EKRecurrenceDayOfWeek {
    mutating func remove(_ element:  Element) {
        let index = self.firstIndex(of: element)
        self.remove(at: index!)
    }
}

extension Array where Element == NSNumber {
    mutating func remove(_ element:  Element) {
        let index = self.firstIndex(of: element)
        self.remove(at: index!)
    }
}

