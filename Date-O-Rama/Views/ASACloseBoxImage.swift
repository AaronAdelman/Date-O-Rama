//
//  ASACloseBoxImage.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 08/06/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACloseBoxImage: View {
    var body: some View {
        Image(systemName: "xmark.square")
            .font(.title)
    }
}

struct ASACloseBoxImage_Previews: PreviewProvider {
    static var previews: some View {
        ASACloseBoxImage()
    }
}
