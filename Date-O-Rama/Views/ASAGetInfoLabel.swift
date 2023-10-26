//
//  ASAGetInfoLabel.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAGetInfoLabel: View {
    var body: some View {
        Label {
           Text("Details…")
        } icon: {
            Image(systemName: "info.circle.fill")
                .renderingMode(.original)
                .symbolRenderingMode(.multicolor)
        }
    } // var body
} // struct ASAGetInfoLabel

struct ASAGetInfoLabel_Previews: PreviewProvider {
    static var previews: some View {
        ASAGetInfoLabel()
    }
}
