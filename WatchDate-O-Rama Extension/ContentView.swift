//
//  ContentView.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        Text("Hello, World!")
        ASAWatchClocksView().environmentObject(ASAUserData.shared())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
