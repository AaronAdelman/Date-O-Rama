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

    
    var body: some View {
        let currentIndex = min(max(userData.selectedTabIndex, 0), max(userData.mainClocks.count - 1, 0))
        let currentLocationWithClocks = userData.mainClocks.isEmpty ? nil : userData.mainClocks[currentIndex]
        let currentLocation = currentLocationWithClocks?.location
        let usesDeviceLocation = currentLocationWithClocks?.usesDeviceLocation ?? false
        let processedClocks: [ASAProcessedClock] = currentLocationWithClocks?.clocks.map {
            ASAProcessedClock(clock: $0, now: now, isForComplications: false, location: currentLocationWithClocks!.location, usesDeviceLocation: usesDeviceLocation)
        } ?? []
        let dayPart = processedClocks.dayPart
        let gradient = (currentLocation != nil) ? currentLocation!.backgroundGradient(dayPart: dayPart) : LinearGradient(colors: [.black, .brown], startPoint: .top, endPoint: .bottom)
        
        GeometryReader { geo in
            ZStack {
                gradient
                    .ignoresSafeArea()
                
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
                            
                            ASALocationTab(now: $now, usingRealTime: $usingRealTime, locationWithClocks: $userData.mainClocks[index])
                                .environmentObject(userData)
                                .tag(index)
                                .tabItem { symbol }
                        }
                    } // TabView
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .colorScheme(.dark)
                    .ignoresSafeArea(.container, edges: .bottom)
//                    .padding(.bottom, geo.safeAreaInsets.bottom)
                }
            } // ZStack
        } // GeometryReader
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(.clear, for: .tabBar)
        .toolbarBackgroundVisibility(.visible, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // Now/Calendar menu — always visible when the TabView is visible
                let NOW_NAME  = "arrow.trianglehead.clockwise"
                let DATE_NAME = "calendar"
                
                Menu {
                    Button {
                        usingRealTime = true
                    } label: {
                        Label("Now", systemImage: NOW_NAME)
                        if usingRealTime {
                            Image(systemName: "checkmark")
                        }
                    }
                    
                    Button {
                        usingRealTime = false
                        now = Date()
                    } label: {
                        Label("Date:", systemImage: DATE_NAME)
                        if !usingRealTime {
                            Image(systemName: "checkmark")
                        }
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
            ToolbarItem(placement: .navigation) {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   appDelegate.session.isPaired {
                    Button {
                        showComplicationsSheet = true
                    } label: {
                        Label("Complications", systemImage: "applewatch")
                    }
                }
            }
            ToolbarItem(placement: .navigation) {
                if !usingRealTime && !compact {
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
                        Label(calendar.localizedName, systemImage:
                                selectedCalendar.identifier == calendar.equivalentCalendarIdentifier ? "checkmark" : "")
                    }
                }
            } label: {
                Image(systemName: "calendar")
                    .symbolRenderingMode(.multicolor)
            }
            
            Spacer()
        }
        .colorScheme(.dark)    }
}

#Preview {
    ASAMainTabView(now: .constant(Date()), usingRealTime: .constant(true))
        .environmentObject(ASAModel.shared)
}
