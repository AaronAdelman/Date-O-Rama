//
//  ASARecurrenceEndTypeChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 30/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASARecurrenceEndTypeChooserView: View {
    @Binding var selectedRecurrenceEndType:  ASARecurrenceEndType
    
    let cases: Array<ASARecurrenceEndType> = [.none,
                                              .endDate,
                                              .occurrenceCount
    ]
    
    @Environment(\.presentationMode) var presentationMode

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    var body: some View {
        List {
            ForEach(cases, id: \.self) {
                recurrenceEndType
                in
                ASARecurrenceEndTypeCell(recurrenceEndType: recurrenceEndType, selectedRecurrenceEndType: $selectedRecurrenceEndType)
                    .onTapGesture {
                        self.selectedRecurrenceEndType = recurrenceEndType
                        self.dismiss()
                    }
            } // ForEach
        } // List
        .navigationBarTitle("Event Recurrence end", displayMode: .inline)
    } // var body
} // struct ASARecurrenceEndTypeChooserView


struct ASARecurrenceEndTypeCell: View {
    let recurrenceEndType: ASARecurrenceEndType
    
    @Binding var selectedRecurrenceEndType:  ASARecurrenceEndType
    
    var body: some View {
        HStack {
            Text(recurrenceEndType.text)

            Spacer()
            if recurrenceEndType == self.selectedRecurrenceEndType {
                ASACheckmarkSymbol()
            }
        }
    }
} // struct ASARecurrenceEndTypeCell


struct ASARecurrenceEndTypeChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASARecurrenceEndTypeChooserView(selectedRecurrenceEndType: .constant(.endDate))
    }
}
