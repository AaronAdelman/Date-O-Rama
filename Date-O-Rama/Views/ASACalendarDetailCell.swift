//
//  ASACalendarDetailCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-04-30.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASACalendarDetailCell:  View {
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
} // struct ASACalendarDetailCell

struct ASACalendarDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarDetailCell(title: "Blah", detail: "Blah")
    }
}
