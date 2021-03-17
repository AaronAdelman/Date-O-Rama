//
//  Glow.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/03/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

// Based on https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
struct ASAGlow: ViewModifier {
    var color: Color    = .red
    var radius: CGFloat = 20.0
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}
