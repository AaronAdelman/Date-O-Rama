//
//  ASAContentView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-11.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASATabBarView: View {
    let tabBarElements: [TabBarElement] = {
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate

        var temp = [
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("CLOCKS_TAB", comment: ""), systemImageName: "clock")) {
                ASAClocksView().environmentObject(ASAUserData.shared())
            },
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("EVENTS_TAB", comment: ""), systemImageName: "rectangle")) {
                ASAEventsView().environmentObject(ASAUserData.shared())
            },
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("PREFERENCES_TAB", comment: ""), systemImageName: "gear")) {
                ASAPreferencesView().environmentObject(ASAUserData.shared())
            }
        ]
        if appDelegate.session.isWatchAppInstalled || false {
            temp.append(TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("COMPLICATION_CLOCKS_TAB", comment: ""), systemImageName: "gear")) {
                ASAComplicationClocksView().environmentObject(ASAUserData.shared())
            })
        }
        
        return temp
    }()

    var body: some View {
        UITabBarWrapper(tabBarElements)
    } // var body
} // struct ASATabBarView

struct ASATabBarView_Previews: PreviewProvider {
    static var previews: some View {
        ASATabBarView()
    }
}
