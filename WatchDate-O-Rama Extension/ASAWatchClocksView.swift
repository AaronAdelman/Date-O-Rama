//
//  ASAWatchClocksView.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchClocksView: View {
    @EnvironmentObject var userData:  ASAModel
    @State var now = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            Form {
                ASAMainClocksView(
//                    mainClocks: $userData.mainClocks,
                    now: $now).environmentObject(userData)
            }
        }
        .onReceive(timer) { input in
            DispatchQueue.main.async {
                //                debugPrint(#file, #function, "Timer signal received:", input)
                self.now = input
            }
        }
    }
}

struct ASAWatchClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAWatchClocksView()
    }
}
