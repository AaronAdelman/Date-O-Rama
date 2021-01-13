//
//  ASAScalable.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

struct ASAScalable: ViewModifier {
    var lineLimit:  Int
    
    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(0.5)
            .allowsTightening(true)
            .lineLimit(lineLimit)
    }
}

