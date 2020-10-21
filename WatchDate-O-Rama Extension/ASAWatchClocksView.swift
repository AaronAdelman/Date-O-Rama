//
//  ASAWatchClocksView.swift
//  WatchDate-O-Rama Extension
//
//  Created by אהרן שלמה אדלמן on 2020-05-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASAWatchClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()

    var body: some View {
        List {
            ForEach(userData.mainRows, id:  \.uuid) { row in
                //                NavigationLink(
                //                    destination: ASAWatchClockDetailView(selectedRow: row, now: self.now)
                //                ) {
                ASAClockCell(processedRow: ASAProcessedRow(row: row, now: now), now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: 0.0, shouldShowTime: true)
                //                }
            }
        }
        .navigationBarTitle(Text("CLOCKS_TAB"))
        .onReceive(timer) { input in
            DispatchQueue.main.async {
                self.now = Date()
            }
        }
    }
}

struct ASAWatchClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAWatchClocksView()
    }
}
