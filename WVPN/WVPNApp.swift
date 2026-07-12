import SwiftUI

@main
struct WVPNApp: App {
    @StateObject private var model = VPNViewModel()

    var body: some Scene {
        WindowGroup { HomeView().environmentObject(model).preferredColorScheme(.dark) }
        #if os(macOS)
        Settings { SettingsView().environmentObject(model).frame(minWidth: 420, minHeight: 360) }
        #endif
    }
}

