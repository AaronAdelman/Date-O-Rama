//
//  ASALocationWithClocksCell.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 13/08/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationWithClocksCell: View {
    @EnvironmentObject var userData: ASAModel
    @ObservedObject var locationWithClocks: ASALocationWithClocks
    @Binding var now: Date
    @State private var showingGetInfoView = false
    @State private var showingActionSheet = false
    
    var body: some View {
        let processed = locationWithClocks.clocks.map {ASAMiniProcessedClock(clock: $0, now: now, location: locationWithClocks.location, usesDeviceLocation: locationWithClocks.usesDeviceLocation)}
        let times: Array<String> = processed.compactMap { $0.timeString }.uniqueElements.map { $0! }
        let timeString = times.joined(separator: " • ")
        
        let cellBackground = processed.dayPart.locationColor
        
        VStack {
            HStack {
                ASALocationWithClocksSectionHeader(locationWithClocks: locationWithClocks, now: now, shouldCapitalize: false)
                
                Spacer()
                ASALocationMenu(locationWithClocks: locationWithClocks, now: $now, includeClockOptions: false) {
                    self.showingActionSheet = true
                } infoAction: {
                    self.showingGetInfoView = true
                } newClockAction: {debugPrint("Foo!")}
                    .environmentObject(userData)
                    .sheet(isPresented: self.$showingGetInfoView) {
                        NavigationStack {
                            ASALocationDetailView(locationWithClocks: locationWithClocks, now: now)
                                .toolbar {
                                    ASACloseButton(action: {
                                        showingGetInfoView = false
                                    })
                                }
                        }
                        .font(.body)
                    }
                    .actionSheet(isPresented: self.$showingActionSheet) {
                        ActionSheet(title: Text("Are you sure you want to delete this location?"), buttons: [
                            .destructive(Text("Delete this location")) {
                                userData.removeLocationWithClocks(locationWithClocks)
                            },
                            .default(Text("Cancel")) {  }
                        ])
                    }
            }
            
            Text(timeString)
                .font(.largeTitle)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .foregroundStyle(Color.white)
        .padding(.all, 4.0)
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .frame(minHeight: 40.0)
    }
} // struct ASALocationWithClocksCell

//#Preview {
//    ASALocationWithClocksCell()
//}
