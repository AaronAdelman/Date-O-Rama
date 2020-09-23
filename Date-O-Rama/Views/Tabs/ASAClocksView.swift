//
//  ASAClocksView.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

struct ASAProcessedRow {
    var row:  ASARow
    var calendarString:  String
    var dateString:  String
    var timeString:  String?
    var emojiString:  String
    var locationString:  String
} // struct ASAProcessedRow

struct ASAClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingNewClockDetailView = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 25.0 as CGFloat

    func processedRows() -> Array<ASAProcessedRow> {
        var result:  Array<ASAProcessedRow> = []

        for row in self.userData.mainRows {
            var locationString = ""
            if row.locationData.name == nil && row.locationData.locality == nil && row.locationData.country == nil {
                if row.location != nil {
                    locationString = row.location!.humanInterfaceRepresentation
                }
            } else {
                locationString = row.locationData.formattedOneLineAddress
            }
            let processedRow = ASAProcessedRow(row: row, calendarString: row.calendar.calendarCode.localizedName(), dateString: row.dateString(now: now), timeString: row.timeString(now: now), emojiString: row.emoji(date:  self.now), locationString: locationString)
            result.append(processedRow)
        }

        return result
    }
    
    fileprivate func saveUserData() {
        self.userData.savePreferences(code: .clocks)
    } // func saveUserData()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.processedRows(), id:  \.row.uuid) {
                    processedRow
                    in
                    NavigationLink(
                        destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true)
                            .onReceive(processedRow.row.objectWillChange) { _ in
                                // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                self.userData.objectWillChange.send()
                                self.saveUserData()
                            }
                    ) {
                        ASAPlainMainRowsViewCell(processedRow: processedRow, now: now, INSET: INSET, shouldShowTime: true)
                    }
                }
                .onMove { (source: IndexSet, destination: Int) -> Void in
                    self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
                    self.saveUserData()
                }
                .onDelete { indices in
                    indices.forEach {
                        debugPrint("\(#file) \(#function)")
                        self.userData.mainRows.remove(at: $0) }
                    self.saveUserData()
                }
            }
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView()
            }
            .navigationBarTitle(Text("CLOCKS_TAB"))
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(
                    action: {
                        self.showingNewClockDetailView = true
                    }
                ) {
                    Text("Add clock")
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            self.now = Date()
        }
    }
} // struct ASAClocksView

struct ASAPlainMainRowsViewCell:  View {
    var processedRow:  ASAProcessedRow
    var now:  Date

    var INSET:  CGFloat
    var shouldShowTime:  Bool

    let ROW_HEIGHT = 30.0 as CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(verbatim: "🗓")
                Text(verbatim:  processedRow.calendarString).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
            }.frame(height: ROW_HEIGHT)

            HStack {
                Spacer().frame(width: self.INSET)
                VStack(alignment: .leading) {
                    if processedRow.row.calendar.canSplitTimeFromDate {
                        Text(verbatim:  processedRow.dateString)
                            .font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)
                        if shouldShowTime {
                            Text(verbatim:  processedRow.timeString ?? "")
                                .font(Font.headline.monospacedDigit())
                                .multilineTextAlignment(.leading).lineLimit(2)
                        }
                    } else {
                        Text(verbatim:  processedRow.dateString)
                            .font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)
                    }
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    if processedRow.row.calendar.supportsTimeZones || processedRow.row.calendar.supportsLocations {
                        HStack {
                            Spacer().frame(width: self.INSET)
                            Text(verbatim:  processedRow.emojiString)

                            Text(processedRow.locationString).font(.subheadline)
                        } // HStack
                    }
                }
            }
        } // VStack
    } // var body
}

struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
