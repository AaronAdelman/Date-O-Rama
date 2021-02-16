//
//  IntExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 02/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation

extension Int {
    func matches(value:  Int?) -> Bool {
        if value == nil {
            return true
        }
        
        return self == value!
    } // func matches(_ value:  Int?) -> Bool
    
    func matches(values:  Array<Int>?) -> Bool {
        if values == nil {
            return true
        }
        
        return values!.contains(self)
    } // func matches(_ values:  Array<Int>?) -> Bool
    
    func matches(weekdays values:  Array<ASAWeekday>?) -> Bool {
        if values == nil {
            return true
        }
        
        return values!.contains(ASAWeekday(rawValue: self)!)
    } // func matches(_ values:  Array<ASAWeekday>?) -> Bool
    
    func matches(startValue: Int?, endValue: Int?) -> Bool {
        assert(startValue != nil && endValue != nil || startValue == nil && endValue == nil)
        
        if startValue == nil || endValue == nil {
            return true
        }
        
        return startValue! <= self && self <= endValue!
    } // func matches(startValue: Int?, endValue: Int?) -> Bool
} // extension Int


// MARK:  -

extension Int {
    var HebrewNumeral:  String {
        get {
            if self <= 0 || self >= 999 {
                return "\(self)"
            }
            var result:  String = ""
            var temp = self
            let t = 400
            while temp >= t {
                result += "ת"
                temp -= t
            } // while temp >= 400

            let ʃ = 300
            if temp >= ʃ {
                result += "ש"
                temp -= ʃ
            }

            let r = 200
            if temp >= r {
                result += "ר"
                temp -= r
            }

            let q = 100
            if temp >= q {
                result += "ק"
                temp -= q
            }

            let t͡s = 90
            if temp >= t͡s {
                result += "צ"
                temp -= t͡s
            }

            let p = 80
            if temp >= p {
                result += "פ"
                temp -= p
            }

            let ʕ = 70
            if temp >= ʕ {
                result += "ע"
                temp -= ʕ
            }

            let s = 60
            if temp >= s {
                result += "ס"
                temp -= s
            }

            let n = 50
            if temp >= n {
                result += "נ"
                temp -= n
            }

            let m = 40
            if temp >= m {
                result += "מ"
                temp -= m
            }

            let l = 30
            if temp >= l {
                result += "ל"
                temp -= l
            }

            let k = 20
            if temp >= k {
                result += "כ"
                temp -= k
            }

            let tʲz = 16
            let tʲw = 15

            if temp == tʲz {
                result += "טז"
                temp -= tʲz
            } else if temp == tʲw {
                result += "טו"
                temp -= tʲw
            } else {
                let j = 10
                if temp >= j {
                    result += "י"
                    temp -= j
                }

                let tʲ = 9
                if temp >= tʲ {
                    result += "ט"
                    temp -= tʲ
                }

                let ħ = 8
                if temp >= ħ {
                    result += "ח"
                    temp -= ħ
                }

                let z = 7
                if temp >= z {
                    result += "ז"
                    temp -= z
                }

                let w = 6
                if temp >= w {
                    result += "ו"
                    temp -= w
                }

                let h = 5
                if temp >= h {
                    result += "ה"
                    temp -= h
                }

                let d = 4
                if temp >= d {
                    result += "ד"
                    temp -= d
                }

                let g = 3
                if temp >= g {
                    result += "ג"
                    temp -= g
                }

                let b = 2
                if temp >= b {
                    result += "ב"
                    temp -= b
                }

                let ʔ = 1
                if temp >= ʔ {
                    result += "א"
                    temp -= ʔ
                }
            }

            if result.count == 1 {
                result += "׳"
            } else {
                result.insert("״", at: result.index(result.endIndex, offsetBy: -1))
            }

            return result
        } // get
    } // var HebrewNumeral

//    var RomanNumeral:  String {
//        get {
//            if self < 1 {
//                return "\(self)"
//            }
//
//            var result = ""
//            var temp = self
//
//            let m = 1000
//            while temp >= m {
//                result += "M"
//                temp -= m
//            }
//
//            let cm = 900
//            if temp >= cm {
//                result += "CM"
//                temp -= cm
//            }
//
//            let d = 500
//            if temp >= d {
//                result += "D"
//                temp -= d
//            }
//
//            let cd = 400
//            if temp >= cd {
//                result += "CD"
//                temp -= cd
//            }
//
//            let c = 100
//            while temp >= c {
//                result += "C"
//                temp -= c
//            }
//
//            let xc = 90
//            if temp >= xc {
//                result += "XC"
//                temp -= xc
//            }
//
//            let l = 50
//            if temp >= l {
//                result += "L"
//                temp -= l
//            }
//
//            let xl = 40
//            if temp >= xl {
//                result += "XL"
//                temp -= xl
//            }
//
//            let x = 10
//            while temp >= x {
//                result += "X"
//                temp -= x
//            }
//
//            let ix = 9
//            if temp >= ix {
//                result += "IX"
//                temp -= ix
//            }
//
//            let v = 5
//            if temp >= v {
//                result += "V"
//                temp -= v
//            }
//
//            let iv = 4
//            if temp >= iv {
//                result += "IV"
//                temp -= iv
//            }
//
//            let i = 1
//            while temp >= i {
//                result += "I"
//                temp -= i
//            }
//
//            return result
//        } // get
//    }
} // extension Int
