//
//  ASACloseButton.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 18/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACloseButton: View {
    var action: @MainActor () -> Void
    
    var body: some View {
        if #available(iOS 26.0, watchOS 26.0, *) {
            Button(role: .close, action: action)
        } else {
            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ASACloseButton(action: {
        debugPrint("Foo")
    })
}
