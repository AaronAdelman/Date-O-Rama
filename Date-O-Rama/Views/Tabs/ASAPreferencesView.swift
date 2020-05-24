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
            Divider()
            Toggle(isOn: $settings.useExternalEvents) {
                Text("Use external events")
            }
        }
    }
}

struct ASAPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ASAPreferencesView()
    }
}
