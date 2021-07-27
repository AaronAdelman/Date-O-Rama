//
//  ColorExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import CoreLocation
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


// MARK:  -

// From http://brunowernimont.me/howtos/make-swiftui-color-codable
// Creative Commons
// TODO:  Should mention under “About”.

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

fileprivate extension Color {
    #if os(macOS)
    typealias SystemColor = NSColor
    #else
    typealias SystemColor = UIColor
    #endif
    
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        #if os(macOS)
        SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
        #else
        guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }
        #endif
        
        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}
