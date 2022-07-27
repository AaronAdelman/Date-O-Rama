//
//  ASALocationTypeCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 27/07/2022.
//  Copyright © 2022 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationTypeCell: View {
    var locationWithClocks: ASALocationWithClocks
    
    var body: some View {
        HStack {
            Text("Location Type")
                .bold()
            Spacer()
            Text(locationWithClocks.location.type.localizedName)
        } // HStack
    }
}

struct ASALocationTypeCell_Previews: PreviewProvider {
    static var previews: some View {
        ASALocationTypeCell(locationWithClocks: ASALocationWithClocks.generic(location: .NullIsland, usesDeviceLocation: true))
    }
}
