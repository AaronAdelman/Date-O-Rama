//
//  TabBarElement.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-05-11.
//  Copyright © 2020 Adelsoft. All rights reserved.
//  From https://medium.com/better-programming/working-around-the-shortfalls-of-swiftuis-tabview-ac9aa2a9d894
//

import SwiftUI

struct TabBarElementItem {
    var title: String
    var systemImageName: String
}

protocol TabBarElementView: View {
    associatedtype Content
    
    var content: Content { get set }
    var tabBarElementItem: TabBarElementItem { get set }
}

struct TabBarElement: TabBarElementView { // 1
    internal var content: AnyView // 2
    
    var tabBarElementItem: TabBarElementItem
    
    init<Content: View>(tabBarElementItem: TabBarElementItem, // 3
         @ViewBuilder _ content: () -> Content) { // 4
        self.tabBarElementItem = tabBarElementItem
        self.content = AnyView(content()) // 5
    }
    
    var body: some View { self.content } // 6
}

struct TabBarElement_Previews: PreviewProvider {
    static var previews: some View {
        TabBarElement(tabBarElementItem: .init(title: "Test",
                                               systemImageName: "house.fill")) {
            Text("Hello, world!")
        }
    }
}
