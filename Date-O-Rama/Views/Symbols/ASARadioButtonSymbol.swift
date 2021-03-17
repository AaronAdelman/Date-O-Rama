//
//  ASARadioButtonSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 17/03/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASARadioButtonSymbol: View {
    var on:  Bool

    var body:  some View {
        let systemName = on ? "largecircle.fill.circle" : "circle"
        Image(systemName: systemName)
            .imageScale(.large)
    } // var body
}

struct ASARadioButtonSymbol_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ASARadioButtonSymbol(on: true)
            ASARadioButtonSymbol(on: false)
        }
    }
}
