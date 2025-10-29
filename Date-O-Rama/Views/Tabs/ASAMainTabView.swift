import SwiftUI

struct ASAMainTabView: View {
    @EnvironmentObject var userData: ASAModel
    @Binding var now: Date
    @Binding var usingRealTime: Bool
    @State private var animatingToLocationsList = false
    @State private var showLocationsOverlay = false
    @State private var showAboutSheet = false
    @State private var showComplicationsSheet = false
    @State private var selectedCalendar = Calendar(identifier: .gregorian)
    let availableCalendars: [ASACalendarCode] = [
     .Gregorian,
     .Buddhist,
     .Chinese,
     .Coptic,
     .EthiopicAmeteAlem,
     .EthiopicAmeteMihret,
     .Hebrew,
     .Indian,
     .Islamic,
     .IslamicCivil,
     .IslamicTabular,
     .IslamicUmmAlQura,
     .Japanese,
     .Persian,
     .RepublicOfChina,
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Date picker and calendar picker — show only when not using real time
                if !usingRealTime {
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
                            ForEach(availableCalendars, id: \.self) { calendar in
                                Button {
                                    selectedCalendar = Calendar(identifier: calendar.equivalentCalendarIdentifier)
                                } label: {
                                    Label(calendar.localizedName, systemImage:
                                            selectedCalendar.identifier == calendar.equivalentCalendarIdentifier ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Image(systemName: "calendar")
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                TabView(selection: $userData.selectedTabIndex) {
                    ForEach(userData.mainClocks.indices, id: \.self) { index in
                        
                        let locationWithClocks: ASALocationWithClocks = userData.mainClocks[index]
                        let usesDeviceLocation: Bool = locationWithClocks.usesDeviceLocation
                        let symbol = usesDeviceLocation ? Image(systemName: "location.fill") : Image(systemName: "circle.fill")
                        
                        ASALocationTab(
                            now: $now,
                            usingRealTime: $usingRealTime,
                            locationWithClocks: $userData.mainClocks[index],
                            isAnimatingToList: animatingToLocationsList && userData.selectedTabIndex == index
                        )
                        .environmentObject(userData)
                        .tag(index)
                        .tabItem { symbol }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
            
            if showLocationsOverlay {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showLocationsOverlay = false
                        }
                    }
                
                ASALocationsTab(
                    now: $now,
                    usingRealTime: $usingRealTime,
                    selectedTabIndex: $userData.selectedTabIndex,
                    showLocationsSheet: $showLocationsOverlay,
                    currentlySelectedLocationIndex: userData.selectedTabIndex,
                    onDismiss: { withAnimation { showLocationsOverlay = false } }
                )
                .environmentObject(userData)
                .frame(maxWidth: 600, maxHeight: 700)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
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
                    showLocationsOverlay = true
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
        }
        .sheet(isPresented: $showAboutSheet) {
            ASAAboutTab()
        }
        .fullScreenCover(isPresented: $showComplicationsSheet) {
            ASAComplicationClocksTab(now: $now)
        }
    }
}

#Preview {
    ASAMainTabView(now: .constant(Date()), usingRealTime: .constant(true))
        .environmentObject(ASAModel.shared)
}
