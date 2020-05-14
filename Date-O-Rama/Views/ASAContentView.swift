//
//  ASAContentView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-11.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAContentView: View {
    var body: some View {
        UITabBarWrapper([
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("CLOCKS_TAB", comment: ""), systemImageName: "clock")) {
                ASAMainRowsView().environmentObject(ASAUserData.shared())
            },
            TabBarElement(tabBarElementItem: .init(title: NSLocalizedString("EVENTS_TAB", comment: ""), systemImageName: "list.dash")) {
                ASAEventsView(primaryRow: ASARow.generic(), secondaryRow: ASARow.generic(), shouldShowSecondaryDates: true).environmentObject(ASAUserData.shared())
            }
        ])
    } // var body
} // struct ASAContentView

struct ASAContentView_Previews: PreviewProvider {
    static var previews: some View {
        ASAContentView()
    }
}
