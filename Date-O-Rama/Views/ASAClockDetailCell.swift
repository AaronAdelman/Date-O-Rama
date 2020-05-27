//
//  ASAClockDetailCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockDetailCell:  View {
    var title:  String
    var detail:  String
    var detail2:  String?
    
    var body:  some View {
        HStack {
            Text(verbatim:  title).bold().multilineTextAlignment(.leading)
            Spacer()
            Text(verbatim:  detail).multilineTextAlignment(.leading)
            if detail2 != nil {
                Spacer()
                Text(verbatim:  detail2!).multilineTextAlignment(.leading).frame(width:  100.0)
            }
        } // HStack
    } // var body
} // struct ASAClockDetailCell

struct ASAClockDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockDetailCell(title: "Blah", detail: "Blah")
    }
}
