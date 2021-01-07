//
//  ASACircleSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 07/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACircleSymbol:  View {
    var body:  some View {
        Image(systemName: "circle")
            .imageScale(.large)
    } // var body
} // struct ASACircleSymbol

struct ASACircleSymbol_Previews: PreviewProvider {
    static var previews: some View {
        ASACircleSymbol()
    }
}
