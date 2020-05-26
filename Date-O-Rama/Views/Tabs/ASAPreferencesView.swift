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
                Section(header:  Text("External events")) {
                    Toggle(isOn: $settings.useExternalEvents) {
                        Text("Use external events")
                    }
                } // Section
                Section(header:  Text("Internal events")) {
                    ForEach(userData.internalEventCalendars) {
                        eventCalendar
                        in
                        ASAInternalEventCalendarCell(eventCalendar:  eventCalendar)
                    }
                } // Section
            } // List
                .navigationBarTitle(Text("PREFERENCES_TAB"))
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
