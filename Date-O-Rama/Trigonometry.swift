//
//  Trigonometry.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/07/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation

// MARK: - Trigonometric functions that take degrees as inputs
// Based on https://stackoverflow.com/questions/28598307/make-swift-assume-degrees-for-trigonometry-calculations

func sin(degrees: Double) -> Double {
    return sin(degrees * Double.pi / 180.0)
}

func cos(degrees: Double) -> Double {
    return cos(degrees * Double.pi / 180.0)
}

func tan(degrees: Double) -> Double {
    return tan(degrees * Double.pi / 180.0)
}

//func atan(degrees: Double) -> Double {
//    return atan(degrees) * 180.0 / Double.pi
//}

func asin(degrees: Double) -> Double {
    return asin(degrees) * 180.0 / Double.pi
}

func acos(degrees: Double) -> Double {
    return acos(degrees) * 180.0 / Double.pi
}
