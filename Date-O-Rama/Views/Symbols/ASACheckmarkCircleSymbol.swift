//
//  ASACheckmarkCircleSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 07/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACheckmarkCircleSymbol:  View {
    var on:  Bool

    var body:  some View {
        let SCALE: Image.Scale = .large
        if on {
            Image(systemName: "checkmark.circle.fill")
                .imageScale(SCALE)
        } else {
            Image(systemName: "circle")
                .imageScale(SCALE)
        }
    } // var body
} // struct ASACheckmarkCircleSymbol

struct ASACheckmarkCircleSymbol_Previews: PreviewProvider {
    static var previews: some View {
        ASACheckmarkCircleSymbol(on: true)
    }
}
