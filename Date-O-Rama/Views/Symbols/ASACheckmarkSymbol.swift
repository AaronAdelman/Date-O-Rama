//
//  ASACheckmarkSymbol.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 07/01/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACheckmarkSymbol: View {
    var body: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.accentColor)
    }
}

struct ASACheckmarkSymbol_Previews: PreviewProvider {
    static var previews: some View {
        ASACheckmarkSymbol()
    }
}
