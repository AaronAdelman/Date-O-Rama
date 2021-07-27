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
        #if targetEnvironment(macCatalyst)
        Button(action:
                {
                    self.showingEventEditView = true
                }, label:  {
                    ASANewExternalEventButtonLabel()            .foregroundColor(.accentColor)
                })
            .sheet(isPresented:  $showingEventEditView) {
                ASANewEKEventView(startDate: now, endDate: now)
                    .frame(minWidth:  400.0, minHeight:  600.0)
            }
        #else
        NavigationLink(destination: ASANewEKEventView(startDate: now, endDate: now)) {
            ASANewExternalEventButtonLabel()
                .foregroundColor(.accentColor)
        }
        #endif
    }
}


struct ASANewExternalEventButtonLabel: View {
    var body: some View {
        HStack {
            Image(systemName: "rectangle.badge.plus")
            Text(NSLocalizedString("Add external event", comment: ""))
        } // HStack
    }
}

struct ASANewExternalEventButton_Previews: PreviewProvider {
    static var previews: some View {
        ASANewExternalEventButton(now: Date())
    }
}
