//
//  ASANewExternalEventButton.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 24/03/2021.
//  Copyright © 2021 Adelsoft. All rights reserved.
//

import EventKitUI
import SwiftUI

struct ASANewExternalEventButton: View {
    @ObservedObject var eventManager = ASAEKEventManager.shared
    var now: Date

    @State private var action:  EKEventEditViewAction?
    @State private var showingEventEditView = false

    var body: some View {
        Button(action:
                {
                    self.showingEventEditView = true
                }, label:  {
                    Text(NSLocalizedString("Add external event", comment: ""))
                })
            .popover(isPresented:  $showingEventEditView, arrowEdge: .top) {
                #if targetEnvironment(macCatalyst)
                ASAEKEventEditView(action: self.$action, event: nil, eventStore: self.eventManager.eventStore)
                #else
                ASANewEKEventView(startDate: now, endDate: now)
                    .frame(minWidth:  400.0, minHeight:  600.0)
                #endif
            }
            .foregroundColor(.accentColor)
    }
}

struct ASANewExternalEventButton_Previews: PreviewProvider {
    static var previews: some View {
        ASANewExternalEventButton(now: Date())
    }
}
