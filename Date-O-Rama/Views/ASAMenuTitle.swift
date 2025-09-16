//
//  ASAMenuTitle.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 25/12/2024.
//  Copyright © 2024 Adelsoft. All rights reserved.
//

import SwiftUI
import UIKit


struct ASAMenuTitle: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var imageSystemName: String
    var title: String?

    var body: some View {
        ZStack {
            let cornerDimension = 6.0
            RoundedRectangle(cornerSize: CGSize(width: cornerDimension, height: cornerDimension))
                .foregroundStyle(Color(UIColor.tertiarySystemFill))
                .frame(height: 36.0)
            
            HStack {
                Image(systemName: imageSystemName)
                    .foregroundStyle(Color.primary)

                if horizontalSizeClass == .regular && title != nil {
                    Text(NSLocalizedString(title!, comment: ""))
                        .foregroundStyle(Color.primary)
                }
            } // HStack
        } // ZStack
        .frame(minWidth: 32.0)
    }
}
