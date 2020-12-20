//
//  ColorExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Utility functions

public func nightTime(hour:  Int, transitionType:  ASATransitionType) -> Bool {
    switch transitionType {
    case .sunset, .dusk:
        if transitionType == .dusk {
            if hour == 23 || hour == 12 {
                return false
            }
        }

        if hour >= 0 && hour <= 11 {
            return true
        } else {
            return false
        }

    case .midnight:
        if hour <= 5 || hour >= 18 {
            return true
        } else {
            return false
        }

    case .noon:
        if 6 <= hour && hour <= 17 {
            return true
        } else {
            return false
        }
    } // switch transitionType
} // func nightTime(hour:  Int, transitionType:  ASATransitionType) -> Bool


// MARK: -

let SKY_BLUE_TOP_RED: Double   =  48.0 / 255.0
let SKY_BLUE_TOP_GREEN: Double = 133.0 / 255.0
let SKY_BLUE_TOP_BLUE: Double  = 182.0 / 255.0

let SKY_BLUE_BOTTOM_RED: Double   =  83.0 / 255.0
let SKY_BLUE_BOTTOM_GREEN: Double = 144.0 / 255.0
let SKY_BLUE_BOTTOM_BLUE: Double  = 187.0 / 255.0

let MIDNIGHT_BLUE_TOP_RED: Double   =  1.0 / 255.0
let MIDNIGHT_BLUE_TOP_GREEN: Double =  6.0 / 255.0
let MIDNIGHT_BLUE_TOP_BLUE: Double  = 31.0 / 255.0

let MIDNIGHT_BLUE_BOTTOM_RED: Double   = 36.0 / 255.0
let MIDNIGHT_BLUE_BOTTOM_GREEN: Double = 41.0 / 255.0
let MIDNIGHT_BLUE_BOTTOM_BLUE: Double  = 62.0 / 255.0

let SUNSET_RED_RED: Double   = 193.0 / 255.0
let SUNSET_RED_GREEN: Double =  92.0 / 255.0
let SUNSET_RED_BLUE: Double  =  42.0 / 255.0


extension Color {
    static var skyBlueTop:  Color = Color(red: SKY_BLUE_TOP_RED, green: SKY_BLUE_TOP_GREEN, blue: SKY_BLUE_TOP_BLUE)

    static var skyBlueBottom:  Color = Color(red: SKY_BLUE_BOTTOM_RED, green: SKY_BLUE_BOTTOM_GREEN, blue: SKY_BLUE_BOTTOM_BLUE)

    static var midnightBlueTop:  Color =  Color(red: MIDNIGHT_BLUE_TOP_RED, green: MIDNIGHT_BLUE_TOP_GREEN, blue: MIDNIGHT_BLUE_TOP_BLUE)

    static var midnightBlueBottom:  Color =  Color(red: MIDNIGHT_BLUE_BOTTOM_RED, green: MIDNIGHT_BLUE_BOTTOM_GREEN, blue: MIDNIGHT_BLUE_BOTTOM_BLUE)

    static var sunsetRed:  Color = Color(red: SUNSET_RED_RED, green: SUNSET_RED_GREEN, blue: SUNSET_RED_BLUE)

    static func foregroundColor(transitionType:  ASATransitionType, hour:  Int, calendarType:  ASACalendarType) -> Color {
        if calendarType == .JulianDay {
            return Color("julianDayForeground")
        }

        let DAY_COLOR: Color   = Color("dayForeground")
        let NIGHT_COLOR: Color = Color("nightForeground")

        let result = nightTime(hour:  hour, transitionType:  transitionType) ? NIGHT_COLOR : DAY_COLOR

        return result
    } // static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

//    static func backgroundColor(transitionType:  ASATransitionType, hour:  Int, calendarType:  ASACalendarType) -> Color {
//        if calendarType == .JulianDay {
//            return Color("julianDayBackground")
//        }
//
//        let DAY_COLOR: Color = .skyBlueTop
//        let NIGHT_COLOR: Color = .midnightBlueTop
//
//        let result = nightTime(hour:  hour, transitionType:  transitionType) ? NIGHT_COLOR : DAY_COLOR
//
//        return result
//    } // static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

//    var components:  (CGFloat, CGFloat, CGFloat) {
//        get {
//            let cg = self.cgColor
//            if cg == nil {
//                return (0.5, 0.5, 0.5)
//            }
//            let components = cg!.components
//            if components == nil {
//                return (0.5, 0.5, 0.5)
//            }
//            let result = (components![0], components![1], components![2])
//            return result
//        } // get
//    } // var components

//    static func blend(startColor:  Color, endColor:  Color, progress:  CGFloat) -> Color {
//        let oneOverProgress:  CGFloat = 1.0 - progress
//
//        let startComponents = startColor.components
//        let endComponents = endColor.components
//        let red   = startComponents.0 * oneOverProgress + endComponents.0 * progress
//        let green = startComponents.1 * oneOverProgress + endComponents.1 * progress
//        let blue  = startComponents.2 * oneOverProgress + endComponents.2 * progress
//        let result = Color(red: Double(red), green: Double(green), blue: Double(blue))
//        return result
//    } // func blend(startColor:  Color, endColor:  Color, progress:  CGFloat)

    static func blend(startRed:  Double, startGreen:  Double, startBlue:  Double, endRed:  Double, endGreen:  Double, endBlue:  Double, progress:  Double) -> Color {
        let oneOverProgress = 1.0 - progress

        let red   = startRed * oneOverProgress + endRed * progress
        let green = startGreen * oneOverProgress + endGreen * progress
        let blue  = startBlue * oneOverProgress + endBlue * progress
        let result = Color(red: red, green: green, blue: blue)
        return result
    } // static func blend(startRed:  Double, startGreen:  Double, startBlue:  Double, endRed:  Double, endGreen:  Double, endBlue:  Double, progress:  Double) -> Color
} // extension Color
