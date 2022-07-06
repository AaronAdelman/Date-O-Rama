//
//  ASANewClockDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/09/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASANewClockDetailView: View {
    @State var selectedClock:  ASAClock = ASAClock.generic

    @Environment(\.presentationMode) var presentationMode

    @State private var showingActionSheet = false

    var now:  Date
    
    var tempLocation: ASALocation

    fileprivate func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    } // func dismiss()

    let HORIZONTAL_PADDING:  CGFloat = 20.0

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer().frame(width:  HORIZONTAL_PADDING)

                    Button("Cancel") {
                        self.showingActionSheet = true
                    }

                    Spacer().frame(minWidth: 0.0)

                    Text("New Clock")
                        .bold()

                    Spacer().frame(minWidth: 0.0)

                    Button("Add") {
                        let userData = ASAUserData.shared
                        userData.addMainClock(clock: self.selectedClock)
                        self.dismiss()
                    }

                    Spacer().frame(width:  HORIZONTAL_PADDING)
                } // HStack

                List {
                    ASAClockDetailEditingSection(selectedClock: selectedClock, now: now, shouldShowTime: true, forAppleWatch: false, tempLocation: tempLocation)
                } // List
                Spacer()
                    .frame(minHeight: 0.0)
            } // VStack
            .font(Font.body)
            .foregroundColor(.primary)
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: self.$showingActionSheet) {
            ActionSheet(title: Text("Are you sure you want to delete this new clock?"), buttons: [
                .destructive(Text("Cancel Changes")) { self.dismiss() },
                .default(Text("Continue Editing")) {  }
            ])
        }
    } // var body
} // struct ASANewClockDetailView

struct ASANewClockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ASANewClockDetailView(selectedClock: ASAClock.generic, now: Date(), tempLocation: ASALocation.NullIsland)
    }
}
