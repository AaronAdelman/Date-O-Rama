//
//  ASAOKButton.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 19/11/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAOKButton: View {
    var action: @MainActor () -> Void
    
    var body: some View {
        if #available(iOS 26.0, watchOS 26.0, *) {
            Button(role: .confirm, action: action)
        } else {
            Button("OK", action: action)
        }
    }
}

#Preview {
    ASAOKButton(action: {debugPrint("foo")})
}
