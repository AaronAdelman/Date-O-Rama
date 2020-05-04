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
    var systemIconName:  String?
    
    var body:  some View {
        HStack {
            if systemIconName != nil {
                Image(systemName: systemIconName!)
            }
            Text(verbatim:  title).bold().frame(width:  150.0)
            Spacer()
            Text(verbatim:  detail).multilineTextAlignment(.leading)
            if detail2 != nil {
                Spacer()
                Text(verbatim:  detail2!).multilineTextAlignment(.leading)
            }
        } // HStack
    } // var body
} // struct ASACalendarDetailCell

struct ASACalendarDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        ASACalendarDetailCell(title: "Blah", detail: "Blah")
    }
}
