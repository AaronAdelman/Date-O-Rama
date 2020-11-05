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

extension Color {
    static var skyBlue:  Color {
        get {
            return Color(red: 20.0 / 255.0, green: 117.0 / 255.0, blue: 157.0 / 255.0)
        } // get
    } // static var skyBlue

    static var midnightBlue:  Color {
        get {
            return Color(red: 12.0 / 255.0, green: 15.0 / 255.0, blue: 38.0 / 255.0)
        } // get
    } // static var midnightBlue

    static var sunsetRed:  Color {
        get {
            return Color(red: 99.0 / 255.0, green: 29.0 / 255.0, blue: 35.0 / 255.0)
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
