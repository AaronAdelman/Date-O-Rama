//
//  ArrayExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 08/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import Foundation


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


// MARK:  -

fileprivate enum ASAMatchingResult {
    case propogateLeading
    case propogateDown
    case propogateTrailing
    case allEqualOneLevelUp
    case startAndEndEqualOneLevelUp
} // enum ASAMatchingResult


extension Array where Element == Int? {
    func isWithin(start: Array<Int?>, end: Array<Int?>) -> Bool {
        assert(start.count == end.count)
        
//        debugPrint("🍐 ----------")

//        debugPrint("🍎 start:", start, "end:", end, "self:", self)
        
        var state: ASAMatchingResult = .propogateDown
        
        for i in 0..<start.count {
            let start_i = start[i]
            let end_i = end[i]
            assert(start_i == nil && end_i == nil || start_i != nil && end_i != nil)
            
            if self[i] == nil {
                continue
            }
            let self_i = self[i]!
//            debugPrint("🍏 start:", start_i ?? "nil", "end:", end_i ?? "nil", "self:", self_i, "state:", state)
            
            switch state {
            case .propogateLeading:
                if start_i != nil {
                    if self_i < start_i! {
//                        debugPrint("🍌 \(self_i) < \(start_i!), return false")
                        return false
                    } else if start_i! < self_i {
//                        debugPrint("🍋 \(start_i!) < \(self_i), return true")
                        return true
                    }
                }
                
            case .propogateDown:
                if start_i != nil {
                    if start_i! == end_i! {
//                        debugPrint("🥒 \(start_i!) = \(end_i!)")
                        if self_i == start_i! {
                            state = .allEqualOneLevelUp
                        } else {
                            state = .startAndEndEqualOneLevelUp
                        }
                    } else
                    if start_i! <= end_i! {
//                        debugPrint("🍊 \(start_i!) <= \(end_i!)")
                        if self_i < start_i! {
//                            debugPrint("🍓 \(self_i) <= \(start_i!), return false")
                            return false
                        } else if start_i! == self_i {
//                            debugPrint("🍇 \(start_i!) == \(self_i)")
                            state = .propogateLeading
                        } else if start_i! < self_i && self_i < end_i! {
//                            debugPrint("🍉 \(start_i!) < \(self_i) && \(self_i) < \(end_i!), return true")
                            return true
                        } else if self_i == end_i! {
//                            debugPrint("🍒 \(self_i) == \(end_i!)")
                            state = .propogateTrailing
                        } else if end_i! < self_i {
//                            debugPrint("🍈 \(end_i!) < \(self_i), return false")
                            return false
                        } else {
//                            debugPrint("🫐 Huh?")
                        }
                    } else {
                        // end_i! < start_i!
//                        debugPrint("🍍 \(end_i!) < \(start_i!)")
                        if self_i <= (start_i! + end_i!) / 2 {
//                            debugPrint("🥭 \(self_i) <= \((start_i! + end_i!) / 2)*")
                            // end is relevant
                            if self_i < end_i! {
//                                debugPrint("🍑 \(self_i) < \(end_i!), return true")
                                return true
                            } else if end_i! < self_i {
//                                debugPrint("🍅 \(end_i!) < \(self_i), return false")
                                return false
                            }
                        } else {
                            // start is relevant
//                            debugPrint("🥝 \(self_i) > \((start_i! + end_i!) / 2)*")
                            if start_i! < self_i {
//                                debugPrint("🥥 \(start_i!) < \(self_i), return true")
                                return true
                            } else if self_i < start_i! {
//                                debugPrint("🥦 \(self_i) < \(start_i!), return false")
                                return false
                            }
                        }
                        
                    }
                }
            case .propogateTrailing:
                if end_i != nil {
                    if end_i! < self_i {
//                        debugPrint("🥑 \(end_i!) < \(self_i), return false")
                        return false
                    } else if self_i < end_i! {
//                        debugPrint("🍆 \(self_i) < \(end_i!), return true")
                        return true
                    }
                }
                
            case .allEqualOneLevelUp:
                if start_i! <= self_i && self_i <= end_i! {
//                    debugPrint("🌽 \(start_i!) <= \(self_i) && \(self_i) <= \(end_i!), return true")
                    return true
                } else if end_i! < start_i! {
//                    debugPrint("🥬 \(end_i!) < \(start_i!), return true")
                    return true
                } else {
//                    debugPrint("🥕 \(end_i!) >= \(start_i!), return false")
                    return false
                }
                
            case .startAndEndEqualOneLevelUp:
                if end_i! < start_i! {
                    return true
                } else {
                    return false
                }
            } // switch state
        } // for i
        
//        debugPrint("🌶 return true")
        return true
    } // func isWithin(start: Array<Int?>, end: Array<Int?>) -> Bool
    
    func fillInFor(start: Array<Int?>, end: Array<Int?>) -> (start: Array<Int?>, end: Array<Int?>) {
        assert(start.count == end.count)
        
        let length = start.count
        var newStart: Array<Int?> = Array(repeating: -1, count: length)
        var newEnd = newStart
        
        var lastTimeEndWasLessThanStart = false
        var timeFromSelfToStart: Double = 0.0
        var timeFromSelfToEnd: Double = 0.0
        
        for i in stride(from: (length - 1), through: 0, by: -1) {
            let start_i = start[i]
            let end_i = end[i]
            if self[i] == nil {
                continue
            }
            let self_i = self[i]!

            if start_i != nil && end_i != nil {
                newStart[i] = start_i!
                newEnd[i]   = end_i!
                lastTimeEndWasLessThanStart = start_i! >= end_i!
                timeFromSelfToStart = abs(Double(self_i) - Double(start_i!))
                timeFromSelfToEnd = abs(Double(self_i) - Double(end_i!))
            } else {
                if lastTimeEndWasLessThanStart {
                    if timeFromSelfToStart <= timeFromSelfToEnd {
                        newStart[i] = self_i
                        newEnd[i]   = self_i + 1
                    } else {
                        newStart[i] = self_i - 1
                        newEnd[i]   = self_i
                    }
                } else {
                    newStart[i] = self_i
                    newEnd[i]   = self_i
                }
                lastTimeEndWasLessThanStart = false
            }
            
        } // for i
        return (start: newStart, end: newEnd)
    } // func fillInFor(start: Array<Int?>, end: Array<Int?>) -> (start: Array<Int>, end: Array<Int>)
} // extension Array where Element == Int
