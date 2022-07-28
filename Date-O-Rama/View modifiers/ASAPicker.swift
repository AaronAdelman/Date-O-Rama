//
//  ASAPicker.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI

struct ASAPicker: ViewModifier {
    var compact: Bool
    
    func body(content: Content) -> some View {
        if compact {
            content
                .pickerStyle(WheelPickerStyle())
        } else {
            #if os(watchOS)
            content
                .pickerStyle(WheelPickerStyle())
            #else
            content
                .pickerStyle(SegmentedPickerStyle())
            #endif

        }
    }
}
