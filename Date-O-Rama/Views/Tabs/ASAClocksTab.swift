//
//  ASAClocksTab.swift
//  Date-O-Rama
//
//  Created by אהרן שלמה אדלמן on 2020-03-31.
//  Copyright © 2020 Adelsoft. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation


struct ASAClocksTab: View {
    @EnvironmentObject var userData:  ASAUserData
    @State var now = Date()
    @State var usingRealTime = true
    
//    @State private var showingNewClockDetailView = false
        
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var isNavigationBarHidden:  Bool = true
    
    @State private var showingPreferences:  Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0.0) {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.usingRealTime = true
                    }, label: {
                        ASARadioButtonLabel(on: self.usingRealTime, onColor: .green, text: "Now")
                    })
                    
                    Spacer()
                        .frame(minWidth: 0.0)
                    
                    HStack {
                        Button(action: {
                            self.usingRealTime = false
                        }, label: {
                            let VERTICAL_PADDING: CGFloat = 7.0
                            ASARadioButtonLabel(on: !self.usingRealTime, onColor: .yellow, text: self.usingRealTime ? "Date:" : "")
                                .padding(EdgeInsets(top: VERTICAL_PADDING, leading: 0.0, bottom: VERTICAL_PADDING, trailing: 0.0))
                        })
                        if !self.usingRealTime {
                            DatePicker(selection:  self.$now, in:  Date.distantPast...Date.distantFuture, displayedComponents: [.date, .hourAndMinute]) {
                                Text("")
                            }
                        }
                    } // HStack
                    
                    Spacer()
                } // HStack
                .border(Color.gray)
                .zIndex(1.0) // This line from https://stackoverflow.com/questions/63934037/swiftui-navigationlink-cell-in-a-form-stays-highlighted-after-detail-pop to get rid of unwanted highlighting.
                
                List {
                    DisclosureGroup("Show clock preferences", isExpanded: $showingPreferences) {
//                        Button(
//                            action: {
//                                self.showingNewClockDetailView = true
//                            }
//                        ) {
//                            HStack {
//                                Image(systemName: "plus.circle.fill")
//                                Text("Add clock")
//                            } // HStack
//                        }
//                        .foregroundColor(.accentColor)
                    } // DisclosureGroup
                    
                    ASAMainClocksByLocationView(mainClocks: $userData.mainClocks, now: $now)
                }
                .listStyle(GroupedListStyle())
//                .sheet(isPresented: self.$showingNewClockDetailView) {
//                    ASANewClockDetailView(now:  now)
//                }
                .navigationBarHidden(self.isNavigationBarHidden)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    self.isNavigationBarHidden = true
                }
            } // VStack
        }.navigationViewStyle(StackNavigationViewStyle())
        .onReceive(timer) { input in
            if usingRealTime {
                self.now = Date()
            }
        }
    } // var body
} // struct ASAClocksTab


struct ASARadioButtonLabel: View {
    var on: Bool
    var onColor: Color
    var text: String?
    
    var body: some View {
        HStack {            
            if on {
                Image(systemName: "largecircle.fill.circle")
                    .imageScale(.large)
                    .foregroundColor(onColor)
            } else {
                Image(systemName: "circle")
                    .imageScale(.large)
            }
            
            if text != nil {
                Text(NSLocalizedString(text!, comment: ""))
                    .modifier(ASAScalable(lineLimit: 1))
            }
        } // HStack
    } // var body
} // struct ASARadioButtonLabel


struct ASAClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ASAClocksTab().environmentObject(ASAUserData.shared)
    }
}
