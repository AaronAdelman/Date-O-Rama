//
//  ASAClocksChooser.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-13.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAClocksChooser: View {
    @Binding var selectedUUIDString:  String
    let clocks = ASAUserData.shared.mainClocks.clocks
    
    @Environment(\.presentationMode) var presentationMode

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var body: some View {
        List {
            ForEach(clocks) {
                row
                in
                ASAClocksChooserClockCell(selectedUUIDString: self.$selectedUUIDString, clock: row)
                    .onTapGesture {
                        self.selectedUUIDString = row.uuid.uuidString
                        self.dismiss()
                    }
            }
        }
    }
}

struct ASAClocksChooserClockCell: View {
    @Binding var selectedUUIDString:  String

    var clock:  ASAClock
    
    var body: some View {
        HStack {
            VStack(alignment:  .leading) {
                Text(verbatim:  clock.calendar.calendarCode.localizedName).font(.headline)
                HStack {
                    if clock.usesDeviceLocation {
                        ASALocationSymbol()
                    }
                    Text(verbatim:  clock.countryCodeEmoji(date:  Date()))
                    Text(verbatim: clock.locationData.formattedOneLineAddress).font(.subheadlineMonospacedDigit)
                }
            }
            Spacer()
            if selectedUUIDString == self.clock.uuid.uuidString {
                ASACheckmarkSymbol()
            }
        }
    }
}


struct ASARowChooser_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksChooser(selectedUUIDString: .constant(UUID().uuidString))
    }
}
