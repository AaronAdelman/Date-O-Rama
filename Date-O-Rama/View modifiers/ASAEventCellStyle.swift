//
//  ASAEventCellStyle.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 18/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import SwiftUI


struct ASAEventCellStyle: ViewModifier {
    var event: ASAEventCompatible
    
    func body(content: Content) -> some View {
        if event.category.isDarkMode {
            content
                .colorScheme(.dark)
                .background(Color(.black))
        } else {
            content
                .colorScheme(.light)
                .background(Color(.white))
        }
    } // func body(content: Content) -> some View
} // struct ASAEventCellStyle
