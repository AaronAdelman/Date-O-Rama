//
//  ASAWatchDateORamaApp.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 13/04/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import SwiftUI

@main
struct ASAWatchDateORamaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
@WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
// code
}
