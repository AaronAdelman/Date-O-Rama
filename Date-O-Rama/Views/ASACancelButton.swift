//
//  ASACancelButton.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 23/02/2026.
//  Copyright © 2026 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACancelButton: View {
    var action: @MainActor () -> Void
    
    var body: some View {
        if #available(iOS 26.0, watchOS 26.0, *) {
            Button(role: .cancel, action: action)
        } else {
            Button("Cancel", action: action)
        }
    }}

#Preview {
    ASACancelButton(action: {debugPrint("Foo")})
}
