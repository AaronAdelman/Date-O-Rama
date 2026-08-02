//
//  ASAEditExternalEventButton.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 20/05/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import Foundation
import EventKitUI
import SwiftUI

struct ASAEditExternalEventButton: View {
    var event: EKEvent
    
    @ObservedObject var eventManager = ASAEKEventManager.shared

    @Binding var action:  EKEventEditViewAction?
    @State private var showingEventEditView = false

    var body: some View {
        Button(action:
                {
                    self.showingEventEditView = true
                }, label:  {
                    Text("Event edit")
                })
            .sheet(isPresented:  $showingEventEditView) {
                ASAEKEventEditView(action: self.$action, event: event, eventStore: self.eventManager.eventStore)
            }
            .foregroundStyle(Color.accentColor)
    } // var body
} // struct ASAEditExternalEventButton
