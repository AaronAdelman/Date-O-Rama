//
//  ASARecurrenceTypeChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 15/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASARecurrenceTypeChooserView: View {
    @Binding var selectedRecurrenceType:  ASARecurrenceType
    
    let cases: Array<ASARecurrenceType> = [.never,
                                           .daily,
                                           .weekly,
                                           .biweekly,
                                           .monthly,
                                           .yearly,
                                           .custom
    ]

    var body: some View {
        List {
            ForEach(cases, id: \.self) {
                recurrenceType
                in
                ASARecurrenceTypeCell(recurrenceType: recurrenceType, selectedRecurrenceType: $selectedRecurrenceType)
            } // ForEach
        } // List
        .navigationBarTitle("Event Recurrence", displayMode: .inline)
    } // var body
} // struct ASARecurrenceTypeChooserView


struct ASARecurrenceTypeCell: View {
    let recurrenceType: ASARecurrenceType
    
    @Binding var selectedRecurrenceType:  ASARecurrenceType
    
    var body: some View {
        HStack {
            Text(recurrenceType.localizedName)

            Spacer()
            if recurrenceType == self.selectedRecurrenceType {
                ASACheckmarkSymbol()
            }
        }
        .onTapGesture {
            self.selectedRecurrenceType = self.recurrenceType
        }
    }
} // struct ASARecurrenceTypeCell


struct ASARecurrenceTypeChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASARecurrenceTypeChooserView(selectedRecurrenceType: .constant(.biweekly))
    }
}
