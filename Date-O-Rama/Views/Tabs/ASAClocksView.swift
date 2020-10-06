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
    var usesDeviceLocation:  Bool
    var locationString:  String
    var canSplitTimeFromDate:  Bool
    var supportsTimeZones:  Bool
    var supportsLocations:  Bool
} // struct ASAProcessedRow


// MARK:  -

struct ASAProcessedRowsDictionaryKey {
    var text:  String
    var emoji:  String?
} // struct ASAProcessedRowsDictionaryKey



// MARK:  -

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
            let processedRow = ASAProcessedRow(row: row, calendarString: row.calendar.calendarCode.localizedName(), dateString: row.dateString(now: now), timeString: row.timeString(now: now), emojiString: row.emoji(date:  now), usesDeviceLocation: row.usesDeviceLocation, locationString: locationString, canSplitTimeFromDate: row.calendar.canSplitTimeFromDate, supportsTimeZones: row.calendar.supportsTimeZones, supportsLocations: row.calendar.supportsLocations)
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
    } // func processedRowsByPlaceName(now:  Date) -> Dictionary<String, Array<ASAProcessedRow>>

    func processedWestToEast(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.longitude ?? 0.0 < $1.row.locationData.location?.coordinate.longitude ?? 0.0}

        return processedRows
    } // func processedWestToEast(now:  Date) -> Array<ASAProcessedRow>

    func processedEastToWest(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.longitude ?? 0.0 > $1.row.locationData.location?.coordinate.longitude ?? 0.0}

        return processedRows
    } // func processedEastToWest(now:  Date) -> Array<ASAProcessedRow>

    func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.latitude ?? 0.0 > $1.row.locationData.location?.coordinate.latitude ?? 0.0}

        return processedRows
    } // func processedNorthToSouth(now:  Date) -> Array<ASAProcessedRow>

    func processedSouthToNorth(now:  Date) -> Array<ASAProcessedRow> {
        let processedRows = self.processed(now: now).sorted {$0.row.locationData.location?.coordinate.latitude ?? 0.0 < $1.row.locationData.location?.coordinate.latitude ?? 0.0}

        return processedRows
    } // func processedSouthToNorth(now:  Date) -> Array<ASAProcessedRow>
} // extension Array where Element == ASARow



// MARK:  -

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
}


// MARK: -

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
                    ASACalendarSymbol()
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
                                if processedRow.usesDeviceLocation {
                                    ASASmallLocationSymbol()
                                }
                                Text(verbatim:  processedRow.emojiString)

                                Text(processedRow.locationString).font(.subheadline)
                            } // HStack
                        }
                    }
                }
            } else if processedRow.usesDeviceLocation {
                HStack {
                    Spacer().frame(width: self.INSET)
                    ASASmallLocationSymbol()
                }
            }
        } // VStack
    } // var body
}


// MARK: -

struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksView().environmentObject(ASAUserData.shared())
    }
}
