//
//  ASAEventColorRectangle.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/12/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAEventColorRectangle: View {
    var color:  Color

    var body: some View {
        Rectangle().frame(width:  2.0).foregroundColor(color)
    }
}

struct ASAEventColorRectangle_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventColorRectangle(color: .green)
    }
}
