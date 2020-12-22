//
//  ASAEventCalendarsView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-24.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAEventCalendarsView: View {
    @EnvironmentObject var userData:  ASAUserData

    @State private var showingNewInternalEventCalendarDetailView = false

    @State var now = Date()

    var body:  some View {
        List {
            ForEach(userData.ASAEventCalendars, id:  \.uuid) {
                eventCalendar
                in
                NavigationLink(destination: ASAEventCalendarDetailView(selectedEventCalendar:  eventCalendar)
                                .onReceive(eventCalendar.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .events)
                                }
                ) {
                    ASAEventCalendarCell(eventCalendar:  eventCalendar, now: $now)
                }
            } // ForEach(userData.internalEventCalendars)
            .onMove { (source: IndexSet, destination: Int) -> Void in
                self.userData.ASAEventCalendars.move(fromOffsets: source, toOffset: destination)
                self.userData.savePreferences(code: .events)
            }
            .onDelete { indices in
                indices.forEach {
                    //                        debugPrint("\(#file) \(#function)")
                    self.userData.ASAEventCalendars.remove(at: $0)
                }
                self.userData.savePreferences(code: .events)
            }
        } // List
        .navigationBarTitle(Text("Internal event calendars"))
        .navigationBarItems(
            trailing:
                HStack {
                    EditButton()

                    Text("•")

                    Button(
                    action: {
                    self.showingNewInternalEventCalendarDetailView = true
                    }
                    ) {
                        Text("Add internal event calendar")
                    }
                    .popover(isPresented: self.$showingNewInternalEventCalendarDetailView, arrowEdge: .top) {
                        ASANewEventCalendarDetailView()
                    }
                }
        )
    } // var body
} // struct ASAEventsView


// MARK:  -

struct ASAEventCalendarCell:  View {
    @ObservedObject var eventCalendar:  ASAEventCalendar
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


struct ASAEventCalendarsView_Previews: PreviewProvider {
    static var previews: some View {
        ASAEventCalendarsView().environmentObject(ASAUserData.shared)
    }
} // struct ASAEventCalendarsView
