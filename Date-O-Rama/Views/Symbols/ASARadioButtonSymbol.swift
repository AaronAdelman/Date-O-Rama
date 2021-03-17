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
    var color: Color

    var body:  some View {
        if on {
            Image(systemName: "largecircle.fill.circle")
                .imageScale(.large)
                .foregroundColor(color)
        } else {
            Image(systemName: "circle")
                .imageScale(.large)
        }
    } // var body
}

struct ASARadioButtonSymbol_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ASARadioButtonSymbol(on: true, color: .green)
            ASARadioButtonSymbol(on: false, color: .yellow)
        }
    }
}
