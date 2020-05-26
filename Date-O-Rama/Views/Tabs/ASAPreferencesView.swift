//
//  ASAPreferencesView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-24.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAPreferencesView: View {
    @ObservedObject var settings = ASAUserSettings()
    
    var body: some View {
        List {
            Text("PREFERENCES_TAB").font(.largeTitle).bold()
            Section(header:  Text("External events")) {
                Toggle(isOn: $settings.useExternalEvents) {
                    Text("Use external events")
                }
            } // Section
            Section(header:  Text("Internal events")) {
                Text("")
            } // Section
        } // List
    } // var body
} // struct ASAPreferencesView

struct ASAPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ASAPreferencesView()
    }
}
