//
//  ASALocationMenuSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationMenuSymbol: View {
    var body: some View {
        ASAGlassSymbol(systemName: "arrow.down.square.fill")
            .font(.title)
    }
}

struct ASALocationMenuSymbol_Previews: PreviewProvider {
    static var previews: some View {
        ASALocationMenuSymbol()
    }
}
