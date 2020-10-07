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


struct ASAClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingNewClockDetailView = false

    let groupingOptions:  Array<ASAClocksViewGroupingOption> = [
        .plain,
        .byFormattedDate,
        .byCalendar,
        .byPlaceName,
        .eastToWest,
        .westToEast,
        .northToSouth,
        .southToNorth
    ]

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 25.0 as CGFloat

    @State var isNavBarHidden:  Bool = false

    var body: some View {
        NavigationView {
            Form {
                    Picker(selection: self.$userData.mainRowsGroupingOption, label: Text("Arrangement")) {
                        ForEach(self.groupingOptions, id:  \.self) {
                            Text($0.text())
                        }
                    }

                switch self.userData.mainRowsGroupingOption {
                case .plain:
                    ASAPlainMainRowsList(groupingOption: .plain, rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byFormattedDate:
                    ASAMainRowsByFormattedDateList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byCalendar:
                    ASAMainRowsByCalendarList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byPlaceName:
                    ASAMainRowsByPlaceName(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .westToEast, .eastToWest, .southToNorth, .northToSouth:
                    ASAPlainMainRowsList(groupingOption: self.userData.mainRowsGroupingOption, rows: $userData.mainRows, now: $now, INSET: INSET)
                } // switch self.groupingOptions[self.groupingOptionIndex]
            }
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView()
            }
            .navigationBarTitle(Text("CLOCKS_TAB"))
            .navigationBarHidden(self.isNavBarHidden)
            .onAppear {
                self.isNavBarHidden = true
            }
            .onDisappear {
                self.isNavBarHidden = false
            }
            .navigationBarItems(
                leading: ASAConditionalEditButton(shouldShow: self.userData.mainRowsGroupingOption == .plain),
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


// MARK:  -

struct ASAConditionalEditButton:  View {
    var shouldShow:  Bool
    
    var body: some View {
        Group {
            
            if #available(macOS 11, iOS 14.0, tvOS 14.0, *) {
                if shouldShow {
                    EditButton()
                } else {
                    EmptyView()
                }
            } else {
                EditButton()
            }
        } // Group
    } //var body
} // struct ASAConditionalEditButton



// MARK:  -

struct ASAPlainMainRowsList:  View {
    @EnvironmentObject var userData:  ASAUserData

    var groupingOption:  ASAClocksViewGroupingOption

    @Binding var rows:  Array<ASARow>
    var processedRows:  Array<ASAProcessedRow> {
        get {
            switch groupingOption {
            case .plain:
                return rows.processed(now: now)

            case .westToEast:
                return rows.processedWestToEast(now: now)

            case .eastToWest:
                return rows.processedEastToWest(now: now)

            case .northToSouth:
                return rows.processedNorthToSouth(now: now)

            case .southToNorth:
                return rows.processedSouthToNorth(now: now)

            default:
                return rows.processed(now: now)
            }

        } // get
    } // var processedRows
    @Binding var now:  Date
    var INSET:  CGFloat

    var body: some View {
        List {
            ForEach(self.processedRows, id:  \.row.uuid) {
                processedRow
                in
                NavigationLink(destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                ) {
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                }
            } // ForEach
            .onMove { (source: IndexSet, destination: Int) -> Void in
                self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
                self.userData.savePreferences(code: .clocks)
            }
            .onDelete { indices in
                indices.forEach {
                    // debugPrint("\(#file) \(#function)")
                    self.userData.mainRows.remove(at: $0)
                }
                self.userData.savePreferences(code: .clocks)
            }
        } // List
    }
} // struct ASAPlainMainRowsList:  View



// MARK:  -

struct ASAMainRowsByFormattedDateList:  View {
    @EnvironmentObject var userData:  ASAUserData

    @Binding var rows:  Array<ASARow>
    var processedRowsByFormattedDate: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedByFormattedDate(now: now)
        }
    }
    @Binding var now:  Date
    var INSET:  CGFloat

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByFormattedDate.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        List {
            ForEach(self.keys, id: \.self) {
                key
                in
                Section(header:  Text("\(key)").font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)) {
                    ForEach(self.processedRowsByFormattedDate[key]!, id:  \.row.uuid) {
                        processedRow
                        in

                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                        ) {
                            ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: false, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                        }
                    }
                }
            } // ForEach
        } // List
    } // var body

    func deleteItem(at offsets: IndexSet, in: ASAProcessedRow) {
        debugPrint(#file, #function )
    }
} // struct ASAMainRowsByFormattedDateList:  View


// MARK:  -

struct ASAMainRowsByCalendarList:  View {
    @EnvironmentObject var userData:  ASAUserData

    @Binding var rows:  Array<ASARow>
    var processedRowsByCalendar: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedRowsByCalendar(now: now)
        } // get
    }
    @Binding var now:  Date
    var INSET:  CGFloat

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByCalendar.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        List {
            ForEach(self.keys, id: \.self) {
                key
                in
                Section(header:  HStack {
                    ASACalendarSymbol()
                    Text(verbatim: "\(key)").font(Font.headline.monospacedDigit())
                        .multilineTextAlignment(.leading).lineLimit(2)
                }) {
                    ForEach(self.processedRowsByCalendar[key]!, id:  \.row.uuid) {
                        processedRow
                        in

                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                        ) {
                            ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: false, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                        }

                    }
                }
            }
        } // List
    } // var body
} // struct ASAMainRowsByCalendarList



// MARK:  -

struct ASAMainRowsByPlaceName:  View {
    @EnvironmentObject var userData:  ASAUserData

    @Binding var rows:  Array<ASARow>
    var processedRowsByPlaceName: Dictionary<String, Array<ASAProcessedRow>> {
        get {
            return self.rows.processedRowsByPlaceName(now: now)
        } // get
    }
    @Binding var now:  Date
    var INSET:  CGFloat

    var keys:  Array<String> {
        get {
            return Array(self.processedRowsByPlaceName.keys).sorted()
        } // get
    } // var keys:  Array<String>

    var body: some View {
        List {
            ForEach(self.keys, id: \.self) {
                key
                in
                Section(header: HStack {
                    Text(self.processedRowsByPlaceName[key]![0].emojiString)
                    Text("\(key)").font(Font.headline.monospacedDigit())
                        .multilineTextAlignment(.leading).lineLimit(2)

                }) {
                    ForEach(self.processedRowsByPlaceName[key]!, id:  \.row.uuid) {
                        processedRow
                        in

                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true, deleteable: true)
                                .onReceive(processedRow.row.objectWillChange) { _ in
                                    // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                                    self.userData.objectWillChange.send()
                                    self.userData.savePreferences(code: .clocks)
                                }
                        ) {
                            ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: false, INSET: INSET, shouldShowTime: true)
                        }

                    }
                }
            }
        } // List
    } // var body
} // struct ASAMainRowsByPlaceName


// MARK: -

struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
