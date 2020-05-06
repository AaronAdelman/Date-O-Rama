//
//  UIColorExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-06.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import UIKit

// From https://stackoverflow.com/questions/38435308/get-lighter-and-darker-color-variations-for-a-given-uicolor
public extension UIColor {

    /**
     Create a lighter color
     */
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage))
    }

    /**
     Create a darker color
     */
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: -abs(percentage))
    }

    /**
     Changing R, G, B values
     */

    func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {

        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {

            let pFactor = (100.0 + percentage) / 100.0

            let newRed = (red*pFactor).clamped(to: 0.0 ... 1.0)
            let newGreen = (green*pFactor).clamped(to: 0.0 ... 1.0)
            let newBlue = (blue*pFactor).clamped(to: 0.0 ... 1.0)

            return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
        }

        return self
    }
}

extension Comparable {

    func clamped(to range: ClosedRange<Self>) -> Self {

        if self > range.upperBound {
            return range.upperBound
        } else if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }
}
