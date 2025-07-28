//
//  ASALocationMenu.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 28/07/2025.
//  Copyright © 2025 Adelsoft. All rights reserved.
//

import SwiftUI

struct ASALocationMenu: View {
    @EnvironmentObject var userData: ASAModel
    
    @ObservedObject var locationWithClocks: ASALocationWithClocks
    @Binding var now: Date
    let includeClockOptions: Bool
    let deleteAction: () -> Void
    let infoAction: () -> Void
    let newClockAction: (() -> Void)? // optional
    
    var body: some View {
        Menu {
            Button(
                action: {
                    infoAction()
                }
            ) {
                ASAGetInfoLabel()
            }
            
            Button(
                action: {
                    deleteAction()
                }
            ) {
                Label {
                    Text("Delete location")
                } icon: {
                    Image(systemName: "minus.circle.fill")
                        .symbolRenderingMode(.multicolor)
                }
            }
            
            if includeClockOptions && locationWithClocks.clocks.count > 1 {
            Divider()
            
            Button(
                action: {
                    if newClockAction != nil {
                        newClockAction!()
                    }
                }
            ) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.multicolor)
                    Text("Add clock")
                } // HStack
            }
            
                Divider()
                
                Button(action: {
                    locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName < $1.calendar.calendarCode.localizedName})
                    userData.savePreferences(code: .clocks)
                }, label: {
                    Image(systemName: "arrow.down")
                    Text("Sort by calendar name ascending")
                })
                
                Button(action: {
                    locationWithClocks.clocks.sort(by: {$0.calendar.calendarCode.localizedName > $1.calendar.calendarCode.localizedName})
                    userData.savePreferences(code: .clocks)
                }, label: {
                    Image(systemName: "arrow.up")
                    Text("Sort by calendar name descending")
                })
            }
        } label: {
            ASALocationMenuSymbol()
        }    }
}

//#Preview {
//    ASALocationMenu()
//}
