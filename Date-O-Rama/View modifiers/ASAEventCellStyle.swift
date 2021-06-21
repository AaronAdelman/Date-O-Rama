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
        let category = event.category
        if category == .generic {
            content
        } else {
            content
                .colorScheme(category.isDarkMode ? .dark : .light)
                .foregroundColor(category.foregroundColor)
                .background(category.backgroundColor.ignoresSafeArea())
        }
    } // func body(content: Content) -> some View
} // struct ASAEventCellStyle
