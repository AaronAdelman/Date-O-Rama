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
    var canSplitTimeFromDate:  Bool
    var supportsTimeZones:  Bool
    var supportsLocations:  Bool
} // struct ASAProcessedRow


extension Array where Element == ASARow {
    func processed(now:  Date) -> Array<ASAProcessedRow> {
        var result:  Array<ASAProcessedRow> = []

        for row in self {
            var locationString = ""
            if row.locationData.name == nil && row.locationData.locality == nil && row.locationData.country == nil {
                if row.location != nil {
                    locationString = row.location!.humanInterfaceRepresentation
                }
            } else {
                locationString = row.locationData.formattedOneLineAddress
            }
            let processedRow = ASAProcessedRow(row: row, calendarString: row.calendar.calendarCode.localizedName(), dateString: row.dateString(now: now), timeString: row.timeString(now: now), emojiString: row.emoji(date:  now), locationString: locationString, canSplitTimeFromDate: row.calendar.canSplitTimeFromDate, supportsTimeZones: row.calendar.supportsTimeZones, supportsLocations: row.calendar.supportsLocations)
            result.append(processedRow)
        }

        return result
    } // func processed(now:  Date) -> Array<ASAProcessedRow>

    func processedByFormattedDate(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processed(now: now)

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

        //        debugPrint(#file, #function, result)
        //        debugPrint("-----------")

        return result
    } // func processedByFormattedDate(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByCalendar(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processed(now: now)

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
    } // func processedRowsByCalendar(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    func processedRowsByPlaceName(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>> {
        var result:  Dictionary<String, Array<ASAProcessedRow>> = [:]
        let processedRows = self.processed(now: now)

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
    } //
} // extension Array where Element == ASARow


struct ASAClocksView: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingNewClockDetailView = false

    let groupingOptions:  Array<ASAClocksViewGroupingOption> = [
        .plain,
        .byFormattedDate,
        .byCalendar,
        .byPlaceName
    ]

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let INSET = 25.0 as CGFloat

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
                    ASAPlainMainRowsList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byFormattedDate:
                    ASAMainRowsByFormattedDateList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byCalendar:
                    ASAMainRowsByCalendarList(rows: $userData.mainRows, now: $now, INSET: INSET)

                case .byPlaceName:
                    ASAMainRowsByPlaceName(rows: $userData.mainRows, now: $now, INSET: INSET)
                } // switch self.groupingOptions[self.groupingOptionIndex]
            }
            .sheet(isPresented: self.$showingNewClockDetailView) {
                ASANewClockDetailView()
            }
            .navigationBarTitle(Text("CLOCKS_TAB"))
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
        }
    }
}


struct ASAPlainMainRowsList:  View {
    @EnvironmentObject var userData:  ASAUserData

    @Binding var rows:  Array<ASARow>
    var processedRows:  Array<ASAProcessedRow> {
        get {
            return rows.processed(now: now)
        } // get
    } // var processedRows
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
//                    debugPrint("\(#file) \(#function)")
                    self.userData.mainRows.remove(at: $0) }
                self.userData.savePreferences(code: .clocks)
            }
        } // List
    }
} // struct ASAPlainMainRowsList:  View


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
            } // ForEach
        } // List
    } // var body

    func deleteItem(at offsets: IndexSet, in: ASAProcessedRow) {
        debugPrint(#file, #function )
    }
} // struct ASAMainRowsByFormattedDateList:  View

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
                    if processedRow.canSplitTimeFromDate {
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
                        if processedRow.supportsTimeZones || processedRow.supportsLocations {
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
