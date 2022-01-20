//
//  ASAColorRectangle.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAColorRectangle: View {
    var colors:  Array<Color>

    var body: some View {
        Rectangle()
            .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            .frame(width:  2.0)
            
    }
}

struct ASAEventColorRectangle_Previews: PreviewProvider {
    static var previews: some View {
        ASAColorRectangle(colors: [.green])
    }
}
