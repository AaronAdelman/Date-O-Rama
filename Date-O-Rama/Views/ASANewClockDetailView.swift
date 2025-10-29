//
//  ASANewClockDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/09/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASANewClockDetailView: View {
    @EnvironmentObject var userData:  ASAModel
    @State var selectedClock:  ASAClock = ASAClock.generic(calendarCode: .gregorian, dateFormat: .full)
    var location: ASALocation
    var usesDeviceLocation: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingActionSheet = false
    
    var now:  Date
    
    var tempLocation: ASALocation
        
    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    let calendarCode = selectedClock.calendar.calendarCode
                    
                    let builtInEventCalendarFileData: ASABuiltInEventCalendarFileData = ASAEventCalendar.builtInEventCalendarFileRecords(calendarCode: calendarCode)
                    ASAClockDetailEditingSection(selectedClock: selectedClock, location: location, usesDeviceLocation: usesDeviceLocation, now: now, shouldShowTime: true, forAppleWatch: false, tempLocation: tempLocation, builtInEventCalendarFileData: builtInEventCalendarFileData)
                } // List
                .onAppear() {
                    self.selectedClock = ASAClock.generic(calendarCode: .gregorian, dateFormat: .full, regionCode: location.regionCode ?? "")
                }
                .navigationTitle("New Clock Details")
                .toolbar(content: {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button("Cancel") {
                            self.showingActionSheet = true
                        }
                        .actionSheet(isPresented: self.$showingActionSheet) {
                            ActionSheet(title: Text("Are you sure you want to delete this new clock?"), buttons: [
                                .destructive(Text("Cancel Changes")) { self.dismiss() },
                                .default(Text("Continue Editing")) {  }
                            ])
                        }
                    }
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button("Add") {
                            userData.addMainClock(clock: self.selectedClock, location: location)
                            self.dismiss()
                        }
                    }
                })
            } // NavigationView
            .navigationViewStyle(StackNavigationViewStyle())
        } // VStack
        .font(Font.body)
        .foregroundColor(.primary)
    } // var body
} // struct ASANewClockDetailView

struct ASANewClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASANewClockDetailView(selectedClock: ASAClock.generic, location: .NullIsland, usesDeviceLocation: false, now: Date(), tempLocation: ASALocation.NullIsland)
    }
}
