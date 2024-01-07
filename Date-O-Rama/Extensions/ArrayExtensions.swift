//
//  ArrayExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 08/02/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKit
import Foundation

// From https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

// MARK:  - Array where Element == EKRecurrenceDayOfWeek
extension Array where Element == EKRecurrenceDayOfWeek {
    mutating func remove(_ element:  Element) {
        let index = self.firstIndex(of: element)
        self.remove(at: index!)
    }
}


// MARK:  - Array where Element == NSNumber
extension Array where Element == NSNumber {
    mutating func remove(_ element:  Element) {
        let index = self.firstIndex(of: element)
        self.remove(at: index!)
    }
}


// MARK:  - Array where Element == Int?

fileprivate enum ASAMatchingResult {
    case propagateLeading
    case propagateDown
    case propagateTrailing
    case allEqualOneLevelUp
    case startAndEndEqualOneLevelUp
} // enum ASAMatchingResult


extension Array where Element == Int? {
    func isWithin(start: Array<Int?>, end: Array<Int?>) -> Bool {
        assert(start.count == end.count)
        
//        debugPrint("🍐 ----------")

//        debugPrint("🍎 start:", start, "end:", end, "self:", self)
        
        var state: ASAMatchingResult = .propagateDown
        
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
            case .propagateLeading:
                if start_i != nil {
                    if self_i < start_i! {
//                        debugPrint("🍌 \(self_i) < \(start_i!), return false")
                        return false
                    } else if start_i! < self_i {
//                        debugPrint("🍋 \(start_i!) < \(self_i), return true")
                        return true
                    }
                }
                
            case .propagateDown:
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
                            state = .propagateLeading
                        } else if start_i! < self_i && self_i < end_i! {
//                            debugPrint("🍉 \(start_i!) < \(self_i) && \(self_i) < \(end_i!), return true")
                            return true
                        } else if self_i == end_i! {
//                            debugPrint("🍒 \(self_i) == \(end_i!)")
                            state = .propagateTrailing
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
            case .propagateTrailing:
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
    
    // A pair of EYMDs is considered “boring” if we can simply fill in missing values from anohter EYMD without having to worry about, say, having to figure out which year either EYMD occurs in.
    static func areBoring(start: Array<Int?>, end: Array<Int?>) -> Bool {
        assert(start.count == end.count)

        for i in 0..<start.count {
            let start_i = start[i]
            let end_i   = end[i]
            
            if start_i != nil && end_i != nil {
                if start_i! < end_i! {
                    return true
                }
                
                if start_i! > end_i! {
                    return false
                }
            }
        } // for i
        
        return true
    } // func areBoring(start: Array<Int?>, end: Array<Int?>) -> Bool
    
    func fillInFor(start: Array<Int?>, end: Array<Int?>) -> (start: Array<Int?>, end: Array<Int?>) {
        assert(start.count == end.count)
        
        let length = start.count
        
        if Array.areBoring(start: start, end: end) {
            // We can safely fill in missing values from self without having, say, to worry about start and end falling in different years.
            var startTemp = start
            var endTemp   = end
            
            for i in 0..<length {
                let self_i = self[i]
                if startTemp[i] == nil {
                    startTemp[i] = self_i
                }
                if endTemp[i] == nil {
                    endTemp[i] = self_i
                }
            } // for i
            return (startTemp, endTemp)
        }
        
        // TODO:  Probably ought to go think about how to do this better, perhaps merged with isWithin.  The “areBoring” business is meant to get around a bug.
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
    
    func isAfterOrEqual(first: Array<Int?>) -> Bool {
        for i in 0..<self.count {
            let start_i = self[i]
            let first_i = first[i]
            
            if start_i != nil && first_i != nil {
                if start_i! > first_i! {
                    return true
                }
            }
            
            if start_i ?? Int.max < first_i ?? 0 {
                return false
            }
        } // for i

        return true
    } // func isAfterOrEqual(first: Array<Int?>) -> Bool
    
} // extension Array where Element == Int


// MARK:  - Array where Element == String

extension Array where Element == String {
    mutating func appendIfDifferentAndNotNil(string: String?) {
        if string != nil {
            let nonoptionalString = string!
            if nonoptionalString != self.last {
                self.append(nonoptionalString)
            }
        }
    } // mutating func appendIfDifferentAndNotNil(string: String?)
    
    func asFormattedListOfISOCountryCodes() -> String {
        // Avoidance of politics
        if self.count == 2 && self.contains(REGION_CODE_Israel) && self.contains(REGION_CODE_Palestine) {
            return NSLocalizedString("Land of Israel", comment: "")
        }
        
        let formattedStrings = self.map {
            Locale.current.localizedString(forRegionCode: $0)
        }
        let formatter = ListFormatter()
        let result = formatter.string(from: formattedStrings as [Any])
        return result ?? "???"
    } // func asFormattedListOfISOCountryCodes() -> String
    
    var asFormattedList: String? {
        let formatter = ListFormatter()
        let result = formatter.string(from: self as [Any])
        return result
    }
    
    var firstCharacterOfEachElement: Array<String> {
        return self.map {String($0.first ?? "?")}

    }
} // extension Array where Element == String
