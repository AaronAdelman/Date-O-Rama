import SwiftUI

struct ASAMainTabView: View {
    @EnvironmentObject var userData: ASAModel
    @EnvironmentObject var watchModel: WatchConnectivityModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @State private var showAboutSheet = false
    @State private var showComplicationsSheet = false
    @State var selectedCalendar = Calendar(identifier: .gregorian)
    
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        return self.sizeClass == .compact
    } // var compact
    
    var body: some View {
        GeometryReader { geo in
            let frameHeight: CGFloat? = geo.safeAreaInsets.top
            
            Spacer()
                .frame(height: frameHeight)
            
            VStack(spacing: 0.0) {
                if compact && !usingRealTime {
                        // Date picker ensemble (only when not using real time)
                        ASADatePickerEnsemble(now: $now, selectedCalendar: $selectedCalendar)
                }
                
                TabView(selection: $userData.selectedTabIndex) {
                    ForEach(userData.mainClocks.indices, id: \.self) { index in
                        
                        let locationWithClocks: ASALocationWithClocks = userData.mainClocks[index]
                        let usesDeviceLocation: Bool = locationWithClocks.usesDeviceLocation
                        let symbol: Image? = usesDeviceLocation ? Image(systemName: "location.fill") : nil
                        let location = locationWithClocks.location
                        let processedClocks: Array<ASAProcessedClock> = locationWithClocks.clocks.map {
                            ASAProcessedClock(clock: $0, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
                        }
                        
                        ASALocationTab(now: $now, usingRealTime: $usingRealTime, locationWithClocks: $userData.mainClocks[index], processedClocks: processedClocks)
                            .environmentObject(userData)
                            .tag(index)
                            .tabItem { symbol }
                    }
                } // TabView
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .background { LinearGradient(colors: [.black, .blue], startPoint: .top, endPoint: .bottom) }
                .ignoresSafeArea(.all, edges: .bottom)
            } // VStack
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        showAboutSheet = true
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                if watchModel.isPaired {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            showComplicationsSheet = true
                        } label: {
                            Label("Complications", systemImage: "applewatch")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigation) {
                    // Now/Calendar menu
                    let NOW_NAME  = "progress.indicator"
                    let DATE_NAME = "ellipsis.calendar"
                    Menu {
                        Button {
                            usingRealTime = true
                        } label: {
                            Label("Now", systemImage: NOW_NAME)
                            if usingRealTime { Image(systemName: "checkmark") }
                        }
                        Button {
                            usingRealTime = false
                            now = Date()
                        } label: {
                            Label("Date:", systemImage: DATE_NAME)
                            if !usingRealTime { Image(systemName: "checkmark") }
                        }
                        Divider()
                        Button(action: {
                            usingRealTime = false
                            now = now.oneDayBefore
                        }) {
                            Label("Previous day", systemImage: "chevron.backward")
                        }
                        Button(action: {
                            usingRealTime = false
                            now = now.oneDayAfter
                        }) {
                            Label("Next day", systemImage: "chevron.forward")
                        }
                    } label: {
                        if usingRealTime {
                            ProgressView()
                                .tint(.green)
                        } else {
                            Image(systemName: DATE_NAME)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                
                if !compact && !usingRealTime {
                    ToolbarItem(placement: .navigation) {
                        // Date picker ensemble (only when not using real time)
                        ASADatePickerEnsemble(now: $now, selectedCalendar: $selectedCalendar)
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Button {
                        userData.shouldShowLocationTab = false
                    } label: {
                        Label("Locations", systemImage: "list.bullet")
                    }
                }
            } // toolbar
            .sheet(isPresented: $showAboutSheet) {
                ASAAboutTab()
            }
            .sheet(isPresented: $showComplicationsSheet) {
                ASAComplicationClocksTab(now: $now)
            }
        } // GeometryReader
    } // body
}



#Preview {
    ASAMainTabView(now: .constant(Date()), usingRealTime: .constant(true))
        .environmentObject(ASAModel.shared)
        .environmentObject(WatchConnectivityModel())
}

