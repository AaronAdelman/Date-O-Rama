import SwiftUI

struct ASAMainTabView: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @State private var showAboutSheet = false
    @State private var showComplicationsSheet = false
    @State var selectedCalendar = Calendar(identifier: .gregorian)
    
    @Environment(\.horizontalSizeClass) var sizeClass
    var compact:  Bool {
        return self.sizeClass == .compact
    } // var compact
    
    // Background gradient for the currently selected tab
    private var selectedBackgroundGradient: LinearGradient {
        // Safely resolve the selected index
        let idx = min(max(userData.selectedTabIndex, 0), max(userData.mainClocks.count - 1, 0))
        guard userData.mainClocks.indices.contains(idx) else {
            // Fallback neutral gradient
            return LinearGradient(colors: [.black, .black], startPoint: .top, endPoint: .bottom)
        }
        let locationWithClocks = userData.mainClocks[idx]
        let location = locationWithClocks.location
        let usesDeviceLocation = locationWithClocks.usesDeviceLocation
        // Recreate processed clocks for gradient parity with ASALocationTab
        let processedClocks: [ASAProcessedClock] = locationWithClocks.clocks.map {
            ASAProcessedClock(clock: $0, now: now, isForComplications: false, location: location, usesDeviceLocation: usesDeviceLocation)
        }
        let dayPart: ASADayPart = processedClocks.dayPart
        // ASALocationTab uses: location.backgroundGradient(dayPart: dayPart)
        return location.backgroundGradient(dayPart: dayPart)
    }
    
    var body: some View {
        ZStack {
            // Background gradient visible under toolbar and safe areas
            selectedBackgroundGradient
                .ignoresSafeArea(.all)

            GeometryReader { geo in
                let frameHeight: CGFloat? = geo.safeAreaInsets.top

                Spacer()
                    .frame(height: frameHeight)

                VStack(spacing: 0) {
                    // Date picker and calendar picker — show only when not using real time
                    if !usingRealTime && compact {
                        ASADatePickerEnsemble(now: $now, selectedCalendar: $selectedCalendar)
                    }

                    TabView(selection: $userData.selectedTabIndex) {
                        ForEach(userData.mainClocks.indices, id: \.self) { index in

                            let locationWithClocks: ASALocationWithClocks = userData.mainClocks[index]
                            let usesDeviceLocation: Bool = locationWithClocks.usesDeviceLocation
                            let symbol = usesDeviceLocation ? Image(systemName: "location.fill") : Image(systemName: "circle.fill")
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
                }
            } // GeometryReader
        } // ZStack
        .ignoresSafeArea(.container, edges: .bottom)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarBackground(.clear, for: .tabBar)
        .toolbarBackgroundVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    userData.shouldShowLocationTab = false
                } label: {
                    Label("Locations", systemImage: "list.bullet")
                }
            }
            ToolbarItem(placement: .navigation) {
                Button {
                    showAboutSheet = true
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            }
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               appDelegate.session.isPaired {
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
                let NOW_NAME  = "clock"
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
                    Image(systemName: usingRealTime ? NOW_NAME : DATE_NAME)
                }
            }
            
            if !compact && !usingRealTime {
                ToolbarItem(placement: .navigation) {
                    // Date picker ensemble (only when not using real time)
                    ASADatePickerEnsemble(now: $now, selectedCalendar: $selectedCalendar)
                }
            }
        }
        .sheet(isPresented: $showAboutSheet) {
            ASAAboutTab()
        }
        .fullScreenCover(isPresented: $showComplicationsSheet) {
            ASAComplicationClocksTab(now: $now)
        }
    }
}

struct ASADatePickerEnsemble: View {
    @Binding var now: Date
    @Binding var selectedCalendar: Calendar
    
    var body: some View {
        HStack {
            Spacer()
            
            DatePicker(
                selection: $now,
                in: Date.distantPast...Date.distantFuture,
                displayedComponents: [.date, .hourAndMinute]
            ) {
                Text("")
            }
            .environment(\.calendar, selectedCalendar)
            .datePickerStyle(.compact)
            
            Menu {
                ForEach(ASACalendarCode.datePickerSafeCalendars, id: \.self) { calendar in
                    Button {
                        selectedCalendar = Calendar(identifier: calendar.equivalentCalendarIdentifier!)
                    } label: {
                        Label(calendar.localizedName, systemImage: selectedCalendar.identifier == calendar.equivalentCalendarIdentifier ? "checkmark" : "")
                    }
                }
            } label: {
                Image(systemName: "calendar")
                    .symbolRenderingMode(.multicolor)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ASAMainTabView(now: .constant(Date()), usingRealTime: .constant(true))
        .environmentObject(ASAModel.shared)
}

