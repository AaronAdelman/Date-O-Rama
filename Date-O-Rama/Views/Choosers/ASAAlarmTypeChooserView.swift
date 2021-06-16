//
//  ASAAlarmTypeChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 16/06/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAAlarmTypeChooserView: View {
    @Binding var selectedAlarmType:  ASAAlarmType
    
    var body: some View {
        List {
            ForEach(ASAAlarmType.allCases, id: \.self) {
                alarmType
                in
                ASAAlarmTypeCell(alarmType: alarmType, selectedAlarmType: $selectedAlarmType)
            } // ForEach
        } // List
        .navigationBarTitle("Event Recurrence", displayMode: .inline)
    }
}

struct ASAAlarmTypeCell: View {
    let alarmType: ASAAlarmType
    
    @Binding var selectedAlarmType:  ASAAlarmType
    
    var body: some View {
        HStack {
            Text(alarmType.text)

            Spacer()
            if alarmType == self.selectedAlarmType {
                ASACheckmarkSymbol()
            }
        }
        .onTapGesture {
            self.selectedAlarmType = self.alarmType
        }
    }
} // struct ASAAlarmTypeCell

struct ASAAlarmTypeChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ASAAlarmTypeChooserView(selectedAlarmType: .constant(.absoluteDate))
    }
}
