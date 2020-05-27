//
//  ASAPreferencesView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-24.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAPreferencesView: View {
    @EnvironmentObject var userData:  ASAUserData
    @ObservedObject var settings = ASAUserSettings()
    
    var body: some View {
        NavigationView {
            List {
                Section(header:  HStack {
                    Text("External events")
                }) {
                    Toggle(isOn: $settings.useExternalEvents) {
                        Text("Use external events")
                    }
                } // Section
                
                Section(header:  HStack {
                    Text("Internal events")
                }) {
                    ForEach(userData.internalEventCalendars, id:  \.uuid) {
                        eventCalendar
                        in
                        NavigationLink(destination: ASAInternalEventCalendarDetailView(selectedEventCalendar:  eventCalendar)
                            .onReceive(eventCalendar.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.userData.savePreferences()
                        }) {
                            ASAInternalEventCalendarCell(eventCalendar:  eventCalendar)
                        }
                    } // ForEach(userData.internalEventCalendars)
                        .onMove { (source: IndexSet, destination: Int) -> Void in
                            self.userData.internalEventCalendars.move(fromOffsets: source, toOffset: destination)
                            self.userData.savePreferences()
                    }
                    .onDelete { indices in
                        indices.forEach {
                            debugPrint("\(#file) \(#function)")
                            self.userData.internalEventCalendars.remove(at: $0) }
                        self.userData.savePreferences()
                    }
                } // Section
            } // List
                .navigationBarTitle(Text("PREFERENCES_TAB"))
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            withAnimation {
                                self.userData.internalEventCalendars.insert(ASAInternalEventCalendarFactory.eventCalendar(eventSourceCode:  .dailyJewish)!, at: 0)
                                self.userData.savePreferences()
                            }
                    }
                    ) {
                        Text(verbatim:  "➕")
                    }
            )
        }// NavigationView
            .navigationViewStyle(StackNavigationViewStyle())
        
    } // var body
} // struct ASAPreferencesView

struct ASAInternalEventCalendarCell:  View {
    @ObservedObject var eventCalendar:  ASAInternalEventCalendar
    var body:  some View {
        HStack {
            Text(eventCalendar.emoji(date: Date()))
            Text(eventCalendar.eventCalendarName()).font(.headline)
        } // HStack
    } // var body
} // struct ASAInternalEventCalendarCell

struct ASAPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ASAPreferencesView().environmentObject(ASAUserData.shared())
    }
} // struct ASAPreferencesView_Previews
