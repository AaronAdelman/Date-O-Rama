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


enum ASAClocksViewGroupingOption {
    case plain
    case byFormattedDate
    case byCalendar
    case byPlaceName

    func text() -> String {
        var raw:  String

        switch self {
        case .plain:
            raw = "Plain"

        case .byFormattedDate:
            raw = "By Formatted Date"

        case .byCalendar:
            raw = "By Calendar"

        case .byPlaceName:
            raw = "By Place Name"
        } // switch self

        return NSLocalizedString(raw, comment: "")
    } // func text() -> String
} // enum ASAClocksViewGroupingOption


struct ASAClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingNewClockDetailView = false

    @State private var groupingOptionIndex = 0
    let groupingOptions:  Array<ASAClocksViewGroupingOption> = [
        .plain,
        .byFormattedDate,
        .byCalendar,
        .byPlaceName
    ]

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
    } // func processedRows() -> Array<ASAProcessedRow>

    func processedRowsByFormattedDate() -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processedRows()

        for processedRow in processedRows {
            let key = processedRow.dateString
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByFormattedDate() -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByCalendar() -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processedRows()

        for processedRow in processedRows {
            let key = processedRow.calendarString
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByCalendar() -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByPlaceName() -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processedRows()

        for processedRow in processedRows {
            let key = processedRow.locationString
            var value = result[key]
            if value == nil {
                result[key] = [processedRow]
            } else {
                value!.append(processedRow)
                result[key] = value
            }
        } // for processedRow in processedRows

        return result
    } // func processedRowsByPlaceName() -> Dictionary<String, Array<ASAProcessedRow>>

    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $groupingOptionIndex, label: Text("Arrangement")) {
                    ForEach(0 ..< self.groupingOptions.count) {
                        Text(self.groupingOptions[$0].text())
                    }
                }

                switch self.groupingOptions[self.groupingOptionIndex] {
                case .plain:
                    ASAPlainMainRowsList(processedRows: self.processedRows(), now: $now, INSET: INSET)

                case .byFormattedDate:
                    ASAMainRowsByFormattedDateList(processedRowsByFormattedDate: self.processedRowsByFormattedDate(), now: $now, INSET: INSET)

                case .byCalendar:
                    ASAMainRowsByCalendarList(processedRowsByCalendar: self.processedRowsByCalendar(), now: $now, INSET: INSET)

                case .byPlaceName:
                    ASAMainRowsByPlaceName(processedRowsByPlaceName: self.processedRowsByPlaceName(), now: $now, INSET: INSET)
                } // switch self.groupingOptions[self.groupingOptionIndex]

            } // VStack
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


struct ASAPlainMainRowsList:  View {
    @EnvironmentObject var userData:  ASAUserData

    var processedRows:  Array<ASAProcessedRow>
    @Binding var now:  Date
    var INSET:  CGFloat

    var body: some View {
        List {
            ForEach(self.processedRows, id:  \.row.uuid) {
                processedRow
                in
                NavigationLink(
                    destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true)
                        .onReceive(processedRow.row.objectWillChange) { _ in
                            // Clause based on https://troz.net/post/2019/swiftui-data-flow/
                            self.userData.objectWillChange.send()
                            self.userData.savePreferences(code: .clocks)
                        }
                ) {
                    ASAClockCell(processedRow: processedRow, now: $now, shouldShowFormattedDate: true, shouldShowCalendar: true, shouldShowPlaceName: true, INSET: INSET, shouldShowTime: true)
                }
            }
            .onMove { (source: IndexSet, destination: Int) -> Void in
                self.userData.mainRows.move(fromOffsets: source, toOffset: destination)
                self.userData.savePreferences(code: .clocks)
            }
            .onDelete { indices in
                indices.forEach {
                    debugPrint("\(#file) \(#function)")
                    self.userData.mainRows.remove(at: $0) }
                self.userData.savePreferences(code: .clocks)
            }
        } // List
    }
} // struct ASAPlainMainRowsList:  View

struct ASAMainRowsByFormattedDateList:  View {
    @EnvironmentObject var userData:  ASAUserData

    var processedRowsByFormattedDate: Dictionary<String, Array<ASAProcessedRow>>
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
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true)
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
            }
        } // List
    } // var body
} // struct ASAMainRowsByFormattedDateList:  View

struct ASAMainRowsByCalendarList:  View {
    @EnvironmentObject var userData:  ASAUserData

    var processedRowsByCalendar: Dictionary<String, Array<ASAProcessedRow>>
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
                Section(header:  Text("\(key)").font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)) {
                    ForEach(self.processedRowsByCalendar[key]!, id:  \.row.uuid) {
                        processedRow
                        in

                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true)
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


struct ASAMainRowsByPlaceName:  View {
    @EnvironmentObject var userData:  ASAUserData

    var processedRowsByPlaceName: Dictionary<String, Array<ASAProcessedRow>>
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
                Section(header:  Text("\(key)").font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)) {
                    ForEach(self.processedRowsByPlaceName[key]!, id:  \.row.uuid) {
                        processedRow
                        in

                        NavigationLink(
                            destination: ASAClockDetailView(selectedRow: processedRow.row, now: self.now, shouldShowTime: true)
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
}

struct ASAClockCell:  View {
    var processedRow:  ASAProcessedRow
    @Binding var now:  Date
    var shouldShowFormattedDate:  Bool
    var shouldShowCalendar:  Bool
    var shouldShowPlaceName:  Bool

    var INSET:  CGFloat
    var shouldShowTime:  Bool

    let ROW_HEIGHT = 30.0 as CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            if shouldShowCalendar {
                HStack {
                    Text(verbatim: "🗓")
                    Text(verbatim:  processedRow.calendarString).font(.subheadline).multilineTextAlignment(.leading).lineLimit(1)
                }.frame(height: ROW_HEIGHT)
            }

            HStack {
                Spacer().frame(width: self.INSET)
                VStack(alignment: .leading) {
                    if processedRow.row.calendar.canSplitTimeFromDate {
                        if shouldShowFormattedDate {
                        Text(verbatim:  processedRow.dateString)
                            .font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)
                        }
                        if shouldShowTime {
                            Text(verbatim:  processedRow.timeString ?? "")
                                .font(Font.headline.monospacedDigit())
                                .multilineTextAlignment(.leading).lineLimit(2)
                        }
                    } else if shouldShowFormattedDate {
                        Text(verbatim:  processedRow.dateString)
                            .font(Font.headline.monospacedDigit())
                            .multilineTextAlignment(.leading).lineLimit(2)
                    }
                }
            }

            if shouldShowPlaceName {
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
            }
        } // VStack
    } // var body
}

struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
