//
//  ASAComplicationClocksView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-06-09.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAComplicationClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let INSET = 25.0 as CGFloat
    @State var isNavBarHidden:  Bool = false

    fileprivate func saveUserData() {
        self.userData.savePreferences(code: .complications)
    } // func saveUserData()

    func row(with key:  ASARowArrayKey) -> Array<ASARow> {
        switch key {
        case .threeLineLarge:
            return self.userData.threeLineLargeRows
        case .twoLineLarge:
            return self.userData.twoLineLargeRows
        case .app:
            return self.userData.mainRows
        case .twoLineSmall:
            return self.userData.twoLineSmallRows
        case .oneLineLarge:
            return self.userData.oneLineLargeRows
        case .oneLineSmall:
            return self.userData.oneLineSmallRows
        } // switch key
    } // func row(with key:  ASARowArrayKey) -> Array<ASARow>

    var body: some View {
        NavigationView {
            VStack {
                Rectangle().frame(height:  0.0) // Prevents content from showing through the status bar.
                List {
                    ForEach(ASARowArrayKey.complicationSections(), id:  \.self) {complicationKey in
                        Section(header:  Text(NSLocalizedString(complicationKey.rawValue, comment: ""))) {
                            ForEach(self.row(with: complicationKey), id:  \.uuid) { row in
                                NavigationLink(
                                    destination: ASAClockDetailView(selectedRow: row, now: self.now, shouldShowTime: false, deleteable: false)
                                        .onReceive(row.objectWillChange) { _ in
                                            // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                            self.userData.objectWillChange.send()
                                            self.saveUserData()
                                        }
                                ) {
                                    ASAClockCell(processedRow: ASAProcessedRow(row: row, now: now), now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, shouldShowTimeZone: true, shouldShowTime: false, shouldShowCalendarPizzazztron: false)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(self.isNavBarHidden)
        .onAppear {
            self.isNavBarHidden = true
        }
        .onDisappear {
            self.isNavBarHidden = false
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            self.now = Date()
        }
    }
}

struct ASAComplicationClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAComplicationClocksView()
    }
}
