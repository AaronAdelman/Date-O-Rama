//
//  ASANewClockDetailView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 10/09/2020.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASANewClockDetailView: View {
    @State var selectedRow:  ASARow = ASARow.generic

    @Environment(\.presentationMode) var presentationMode

    @State private var showingActionSheet = false

    var now:  Date

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

                    Spacer()

                    Text("New Clock")
                        .bold()

                    Spacer()

                    Button("Add") {
                        let userData = ASAUserData.shared
                        userData.mainRows.insert(self.selectedRow, at: 0)
                        userData.savePreferences(code: .clocks)

                        self.dismiss()
                    }

                    Spacer().frame(width:  HORIZONTAL_PADDING)
                } // HStack

                List {
                    ASAClockDetailEditingSection(selectedRow: selectedRow, now: now, shouldShowTime: true, forAppleWatch: false)
                } // List
            } // VStack
//                .navigationBarTitle(Text(selectedRow.dateString(now: Date())))
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
        ASANewClockDetailView(selectedRow: ASARow.generic, now: Date())
    }
}
