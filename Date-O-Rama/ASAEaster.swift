//
//  ASAEaster.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/09/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

// Based on:
/*
Module : AAEaster.cpp
Purpose: Implementation for the algorithms which calculate the date of Easter
Created: PJN / 29-12-2003
History: PJN / 07-07-2016 1. Fixed a compiler warning in CAAEaster::Calculate as reported at
                          http://stackoverflow.com/questions/2348415/objective-c-astronomy-library.

Copyright (c) 2003 - 2019 by PJ Naughter (Web: www.naughter.com, Email: pjna@naughter.com)

All rights reserved.

Copyright / Usage Details:

You are allowed to include the source code in any product (commercial, shareware, freeware or otherwise)
when your product is released in binary form. You are allowed to modify the source code in any way you want
except you cannot modify the copyright details at the top of each module. If you want to distribute source
code with your application, then you are only allowed to distribute versions released by the author. This is
to maintain a single distribution point for the source code.

*/
// It was easier to just translate the relevant function into Swift that to coerce Xcode to use the original C++ somehow.

import Foundation

func calculateEaster(nYear: Int, GregorianCalendar: Bool) -> (month: Int, day: Int) {
    if (GregorianCalendar) {
        let a: Int = nYear % 19
        let b: Int = nYear / 100
        let c: Int = nYear % 100
        let d: Int = b / 4
        let e: Int = b % 4
        let f: Int = (b + 8) / 25
        let g: Int = (b - f + 1) / 3
        let h: Int = (19 * a + b - d - g + 15) % 30
        let i: Int = c / 4
        let k: Int = c % 4
        let l: Int = (32 + 2 * e + 2 * i - h - k) % 7
        let m: Int = (a + 11 * h + 22 * l) / 451
        let n: Int = (h + l - 7 * m + 114) / 31
        let p: Int = (h + l - 7 * m + 114) % 31
        let day: Int = p + 1
        return (n, day)
    } else {
        let a: Int = nYear % 4
        let b: Int = nYear % 7
        let c: Int = nYear % 19
        let d: Int = ((19 * c) + 15) % 30
        let e: Int = ((2 * a) + (4 * b) - d + 34) % 7
        let f: Int = (d + e + 114) / 31
        let g: Int = (d + e + 114) % 31
        let day: Int = g + 1
        return (f, day)
    }
} // func calculateEaster(nYear: Int, GregorianCalendar: Bool) -> (month: Int, day: Int)
