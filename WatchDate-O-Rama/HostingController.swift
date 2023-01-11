//
//  HostingController.swift
//  WatchDate-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2023-01-11.
//  Copyright © 2023 Adelsoft. All rights reserved.
//  Based on https://stackoverflow.com/questions/73657443/how-to-migrate-watch-app-to-swiftui-lifecycle

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        return AnyView(ContentView())
    }
}
