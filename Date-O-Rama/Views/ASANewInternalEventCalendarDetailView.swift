//
//  ASANewInternalEventCalendarDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/09/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASANewInternalEventCalendarDetailView: View {
    @ObservedObject var selectedEventCalendar:  ASAInternalEventCalendar = ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode:  "Solar events")!

    @Environment(\.presentationMode) var presentationMode

    @State private var showingActionSheet = false

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    let PADDING:  CGFloat = 20.0

    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height:  PADDING)

                HStack {
                    Spacer().frame(width:  PADDING)

                    Button("Cancel") {
                        self.showingActionSheet = true
                    }

                    Spacer()

                    Text("New Internal Event Calendar").bold()

                    Spacer()

                    Button("Add") {
                        let userData = ASAUserData.shared()
                        userData.internalEventCalendars.insert(self.selectedEventCalendar, at: 0)
                        userData.savePreferences(code: .events)

                        self.dismiss()
                    }

                    Spacer().frame(width:  PADDING)
                } // HStack
                List {
                    ASAInternalEventCalendarDetailSection(selectedEventCalendar: self.selectedEventCalendar)
                } // List
            } // VStack
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: self.$showingActionSheet) {
            ActionSheet(title: Text("Are you sure you want to delete this new internal event calendar?"), buttons: [
                .destructive(Text("Cancel Changes")) { self.dismiss() },
                .default(Text("Continue Editing")) {  }
            ])
        }
    } // var body
} // struct ASANewInternalEventCalendarDetailView


// MARK:  -

struct ASANewInternalEventCalendarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASANewInternalEventCalendarDetailView()
    }
} // struct ASANewInternalEventCalendarDetailView_Previews
