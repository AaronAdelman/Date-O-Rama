//
//  ASALocaleChooserView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ASALocaleChooserView: View {
    let localeData = ASALocaleData()
    
    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    @State var tempLocaleIdentifier:  String
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var didCancel = false
    
    @State var providedLocaleIdentifiers:  Array<String>?

    @State var searchText = ""

    func filteredLocales() -> Array<ASALocaleRecord> {
        let allLocales = self.localeData.allRecords
        
        if searchText.isEmpty {
            return allLocales
        } else {
            return allLocales.filter {
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.nativeName.localizedCaseInsensitiveContains(searchText) ||
                $0.localName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            if providedLocaleIdentifiers == nil {
                TextField("Search locales", text: $searchText)
//                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            ForEach(self.filteredLocales()) { item in
                ASALocaleCell(localeString: item.id, localizedLocaleString: item.nativeName, tempLocaleIdentifier: self.$tempLocaleIdentifier, clock: clock, location: location)
            }
        }
        .navigationBarItems(trailing:
                                Button("Cancel", role: .cancel, action: {
                                    self.didCancel = true
                                    self.presentationMode.wrappedValue.dismiss()
                                })
        )
        .onAppear() {
            self.tempLocaleIdentifier = self.clock.localeIdentifier
        }
        .onDisappear() {
            if !self.didCancel {
                self.clock.localeIdentifier = self.tempLocaleIdentifier
            }
        }
    }
}

struct ASALocaleCell: View {
    let localeString: String
    let localizedLocaleString:  String
    
    @Binding var tempLocaleIdentifier:  String

    @ObservedObject var clock:  ASAClock
    var location: ASALocation
    
    var body: some View {
        HStack {
            Text(verbatim: localeString.localeCountryCodeFlag)
            Text(verbatim:  localizedLocaleString)
            if clock.calendar.canSplitTimeFromDate {
                VStack(alignment: .leading) {
                    Text(verbatim: clock.calendar.dateTimeString(now: Date(), localeIdentifier: localeString, dateFormat: clock.dateFormat, timeFormat: .none, locationData: location))
                        .foregroundColor(Color.secondary)
                        .modifier(ASAScalable(lineLimit: 1))
                    Text(verbatim: clock.calendar.dateTimeString(now: Date(), localeIdentifier: localeString, dateFormat: .none, timeFormat: clock.timeFormat, locationData: location))
                        .foregroundColor(Color.secondary)
                        .modifier(ASAScalable(lineLimit: 1))
                }
            } else {
                Text(verbatim: clock.calendar.dateTimeString(now: Date(), localeIdentifier: localeString, dateFormat: clock.dateFormat, timeFormat: clock.timeFormat, locationData: location))
                    .foregroundColor(Color.secondary)
                    .modifier(ASAScalable(lineLimit: 1))
            }
            Spacer()
            if localeString == self.tempLocaleIdentifier {
                ASACheckmarkSymbol()
            }
        }
        .onTapGesture {
            self.tempLocaleIdentifier = self.localeString
        }
    }
}

struct ASALocalePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ASALocaleChooserView(clock: ASAClock.generic, location: .nullIsland, tempLocaleIdentifier: "en_US")
    }
}

