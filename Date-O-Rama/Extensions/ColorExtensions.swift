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

fileprivate func nightTime(hour:  Int, transitionType:  ASATransitionType) -> Bool {
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

let SKY_BLUE_RED: Double   = 20.0 / 255.0
let SKY_BLUE_GREEN: Double = 117.0 / 255.0
let SKY_BLUE_BLUE: Double  = 157.0 / 255.0

let MIDNIGHT_BLUE_RED: Double   = 12.0 / 255.0
let MIDNIGHT_BLUE_GREEN: Double = 15.0 / 255.0
let MIDNIGHT_BLUE_BLUE: Double  = 38.0 / 255.0

let SUNSET_RED_RED: Double   = 99.0 / 255.0
let SUNSET_RED_GREEN: Double = 29.0 / 255.0
let SUNSET_RED_BLUE: Double  = 35.0 / 255.0


extension Color {
    static var skyBlue:  Color {
        get {
            return Color(red: SKY_BLUE_RED, green: SKY_BLUE_GREEN, blue: SKY_BLUE_BLUE)
        } // get
    } // static var skyBlue

    static var midnightBlue:  Color {
        get {
            return Color(red: MIDNIGHT_BLUE_RED, green: MIDNIGHT_BLUE_GREEN, blue: MIDNIGHT_BLUE_BLUE)
        } // get
    } // static var midnightBlue

    static var sunsetRed:  Color {
        get {
            return Color(red: SUNSET_RED_RED, green: SUNSET_RED_GREEN, blue: SUNSET_RED_BLUE)
        } // get
    } // static var sunsetRed

    static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color {
        let DAY_COLOR: Color = .white
        let NIGHT_COLOR: Color = .white

        let result = nightTime(hour:  hour, transitionType:  transitionType) ? NIGHT_COLOR : DAY_COLOR

        return result
    } // static func foregroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

    static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color {
        let DAY_COLOR: Color = .skyBlue
        let NIGHT_COLOR: Color = .midnightBlue

        let result = nightTime(hour:  hour, transitionType:  transitionType) ? NIGHT_COLOR : DAY_COLOR

        return result
    } // static func backgroundColor(transitionType:  ASATransitionType, hour:  Int) -> Color

    var components:  (CGFloat, CGFloat, CGFloat) {
        get {
            let cg = self.cgColor
            if cg == nil {
                return (0.5, 0.5, 0.5)
            }
            let components = cg!.components
            if components == nil {
                return (0.5, 0.5, 0.5)
            }
            let result = (components![0], components![1], components![2])
            return result
        } // get
    } // var components

    static func blend(startColor:  Color, endColor:  Color, progress:  CGFloat) -> Color {
        let oneOverProgress:  CGFloat = 1.0 - progress

        let startComponents = startColor.components
        let endComponents = endColor.components
        let red   = startComponents.0 * oneOverProgress + endComponents.0 * progress
        let green = startComponents.1 * oneOverProgress + endComponents.1 * progress
        let blue  = startComponents.2 * oneOverProgress + endComponents.2 * progress
        let result = Color(red: Double(red), green: Double(green), blue: Double(blue))
        return result
    } // func blend(startColor:  Color, endColor:  Color, progress:  CGFloat)
} // extension Color
