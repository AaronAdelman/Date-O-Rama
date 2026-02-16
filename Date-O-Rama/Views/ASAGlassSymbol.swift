//
//  ASAGlassSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 19/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAGlassSymbol: View {
    var systemName: String
    var primaryColor, secondaryColor: Color
    
    
    var body: some View {
        if #available(iOS 26.0, watchOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, *) {
            Image(systemName: systemName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(primaryColor, secondaryColor)
                .font(.title)
                .glassEffect()
        } else {
            Image(systemName: systemName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(primaryColor, secondaryColor)
                .font(.title)
        }
    }
}

#Preview {
    ASAGlassSymbol(systemName: "arrow.down", primaryColor: .black, secondaryColor: .white)
}
