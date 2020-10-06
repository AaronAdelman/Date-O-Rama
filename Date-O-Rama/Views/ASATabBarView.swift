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
        let userData = ASAUserData.shared()

        var temp = [
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("CLOCKS_TAB", comment: ""), systemImageName: "clock")) {
                ASAClocksView().environmentObject(userData)
            },
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("EVENTS_TAB", comment: ""), systemImageName: "rectangle")) {
                ASAEventsView().environmentObject(userData)
            }
        ]
        if appDelegate.session.isPaired {
            temp.append(TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("COMPLICATION_CLOCKS_TAB", comment: ""), systemImageName: "gear")) {
                ASAComplicationClocksView().environmentObject(userData)
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
