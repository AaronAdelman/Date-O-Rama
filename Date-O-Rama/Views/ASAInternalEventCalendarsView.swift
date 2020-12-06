//
//  ASAInternalEventCalendarsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-24.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAInternalEventCalendarsView: View {
    @EnvironmentObject var userData:  ASAUserData

    @State private var showingNewInternalEventCalendarDetailView = false

    @State var now = Date()

    var body:  some View {
        List {
            ForEach(userData.internalEventCalendars, id:  \.uuid) {
                eventCalendar
                in
                NavigationLink(destination: ASAInternalEventCalendarDetailView(selectedEventCalendar:  eventCalendar)
                                .onReceive(eventCalendar.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .events)
                                }
                ) {
                    ASAInternalEventCalendarCell(eventCalendar:  eventCalendar, now: $now)
                }
            } // ForEach(userData.internalEventCalendars)
            .onMove { (source: IndexSet, destination: Int) -> Void in
                self.userData.internalEventCalendars.move(fromOffsets: source, toOffset: destination)
                self.userData.savePreferences(code: .events)
            }
            .onDelete { indices in
                indices.forEach {
                    //                        debugPrint("\(#file) \(#function)")
                    self.userData.internalEventCalendars.remove(at: $0)
                }
                self.userData.savePreferences(code: .events)
            }
        } // List
        .navigationBarTitle(Text("Internal event calendars"))
        .navigationBarItems(
            leading:
                EditButton(),
            trailing:
                Button(
                    action: {
                        self.showingNewInternalEventCalendarDetailView = true
                    }
                ) {
                    Text("Add internal event calendar")
                }
                .popover(isPresented: self.$showingNewInternalEventCalendarDetailView, arrowEdge: .top) {
                    ASANewInternalEventCalendarDetailView()
                }
        )
    } // var body
} // struct ASAInternalEventsView


// MARK:  -

struct ASAInternalEventCalendarCell:  View {
    @ObservedObject var eventCalendar:  ASAInternalEventCalendar
    @Binding var now:  Date

    var body:  some View {
        HStack {
            if eventCalendar.usesDeviceLocation {
                ASASmallLocationSymbol()
            }
            Text(eventCalendar.emoji(date: now))
            Text(eventCalendar.eventCalendarName()).font(.headline)
        } // HStack
    } // var body
} // struct ASAInternalEventCalendarCell


struct ASAInternalEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAInternalEventCalendarsView().environmentObject(ASAUserData.shared())
    }
} // struct ASAPreferencesView_Previews
