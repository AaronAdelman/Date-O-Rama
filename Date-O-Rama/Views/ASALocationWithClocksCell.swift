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
    
//    let animatingSelection: Bool
//    let isHighlighted: Bool
    
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
                        VStack {
                            HStack {
                                Button(action: {
                                    showingGetInfoView = false
                                }) {
                                    ASACloseBoxImage()
                                }
                                Spacer()
                            }
                            ASALocationDetailView(locationWithClocks: locationWithClocks, now: now)
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
                .lineLimit(3)
        }
        .foregroundStyle(Color.white)
        .padding()
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
//        .scaleEffect(animatingSelection ? 1.1 : (isHighlighted ? 1.03 : 1.0))
//        .opacity(animatingSelection ? 0.8 : 1.0)
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: animatingSelection)
//        .animation(.easeInOut(duration: 0.6), value: isHighlighted)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
} // struct ASALocationWithClocksCell

//#Preview {
//    ASALocationWithClocksCell()
//}
