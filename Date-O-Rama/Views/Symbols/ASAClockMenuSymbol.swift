//
//  ASAClockMenuSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 31/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockMenuSymbol: View {
    var body: some View {
        ASAGlassSymbol(systemName: "arrow.down.circle.fill")
            .font(.title)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.black, .white)
    }
}

struct ASAClockMenuSymbol_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockMenuSymbol()
    }
}
