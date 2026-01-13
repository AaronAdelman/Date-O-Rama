//
//  ColorExtensions.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 05/11/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI


// From http://brunowernimont.me/howtos/make-swiftui-color-codable
// Creative Commons
// Augmented by ChatGPT to allow passing names
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
        case red, green, blue, name
    }

    // Known named colors map (add more as needed)
    private static func color(forName name: String) -> Color? {
        switch name {
        case "black":
            return .black

        case "white":
            return .white

        case "red":
            return .red

        case "green":
            return .green

        case "blue":
            return .blue

        case "gray":
            return .gray

        case "orange":
            return .orange

        case "yellow":
            return .yellow

        case "pink":
            return .pink

        case "purple":
            return .purple

        case "brown":
            return .brown

        case "cyan":
            return Color.cyan

        case "mint":
            return Color.mint

        case "teal":
            return Color.teal
            
        case "indigo":
            return Color.indigo
            
        case "magenta":
            return Color(uiColor: .magenta)

        default:
            return nil
        }
    }

    private static func name(forColor color: Color) -> String? {
        // Try to match against our known set by comparing RGB components when possible
        func approxEqual(_ a: CGFloat, _ b: CGFloat, eps: CGFloat = 0.001) -> Bool { abs(a - b) <= eps }

        if let comps = color.colorComponents {
            let r = comps.red, g = comps.green, b = comps.blue
            // Common exact sRGB values for standard colors
            if approxEqual(r, 0), approxEqual(g, 0), approxEqual(b, 0) { return "black" }
            if approxEqual(r, 1), approxEqual(g, 1), approxEqual(b, 1) { return "white" }
            if approxEqual(r, 1), approxEqual(g, 0), approxEqual(b, 0) { return "red" }
            if approxEqual(r, 0), approxEqual(g, 1), approxEqual(b, 0) { return "green" }
            if approxEqual(r, 0), approxEqual(g, 0), approxEqual(b, 1) { return "blue" }
            if approxEqual(r, 0.5), approxEqual(g, 0.5), approxEqual(b, 0.5) { return "gray" }
            if approxEqual(r, 1), approxEqual(g, 0.647), approxEqual(b, 0) { return "orange" }
            if approxEqual(r, 1), approxEqual(g, 1), approxEqual(b, 0) { return "yellow" }
            if approxEqual(r, 1), approxEqual(g, 0.753), approxEqual(b, 0.796) { return "pink" }
            if approxEqual(r, 0.5), approxEqual(g, 0), approxEqual(b, 0.5) { return "purple" }
            if approxEqual(r, 0.6), approxEqual(g, 0.4), approxEqual(b, 0.2) { return "brown" }
            if approxEqual(r, 0), approxEqual(g, 1), approxEqual(b, 1) { return "cyan" }
            // teal/mint are not fixed here; leave as RGB
        }
        // Dynamic colors like .primary/.secondary can't be matched reliably via RGB; skip naming.
        return nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Prefer named color if present
        if let name = try container.decodeIfPresent(String.self, forKey: .name), let named = Color.color(forName: name) {
            self = named
            return
        }
        // Fallback to RGB components
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Try to encode a known name first
        if let knownName = Color.name(forColor: self) {
            try container.encode(knownName, forKey: .name)
            return
        }
        // Fallback to RGB components
        guard let comps = self.colorComponents else { return }
        try container.encode(comps.red, forKey: .red)
        try container.encode(comps.green, forKey: .green)
        try container.encode(comps.blue, forKey: .blue)
    }
}
