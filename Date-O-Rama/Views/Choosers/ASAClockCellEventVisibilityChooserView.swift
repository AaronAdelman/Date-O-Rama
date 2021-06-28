//
//  ASAClockCellEventVisibilityChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClockCellEventVisibilityChooserView: View {
    @Binding var selectedVisibility:  ASAClockCellEventVisibility
    
    var body: some View {
        List {
            ForEach(ASAClockCellEventVisibility.allCases, id: \.self) {
                visibility
                in
                ASAClockCellEventVisibilityCell(visibility: visibility, selectedVisibility: $selectedVisibility)
            } // ForEach
        } // List
        .navigationBarTitle("", displayMode: .inline)
    }
}


struct ASAClockCellEventVisibilityCell: View {
    let visibility: ASAClockCellEventVisibility
    
    @Binding var selectedVisibility:  ASAClockCellEventVisibility
    
    var body: some View {
        HStack {
            Text(verbatim: visibility.text)

            Spacer()
            if visibility == selectedVisibility {
                ASACheckmarkSymbol()
            }
        }
        .onTapGesture {
            self.selectedVisibility = visibility
        }
    }
} //


struct ASAClockCellEventVisibilityChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClockCellEventVisibilityChooserView(selectedVisibility: .constant(.all))
    }
}
