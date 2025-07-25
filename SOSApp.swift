import SwiftUI

@main
struct SOSApp: App {
    @StateObject private var authManager = AuthManager()
    @AppStorage("isDarkMode") private var isDarkMode = false
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
//-- Make bucket public (when working on project)
//SELECT toggle_bucket_public_status('audioverse', true);


//-- Make bucket private (when away from project)
//SELECT toggle_bucket_public_status('audioverse', false);
