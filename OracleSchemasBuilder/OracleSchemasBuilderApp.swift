import SwiftUI

@main
struct OracleSchemasBuilderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SessionManager())
        }
        .commands {
            AppCommands()
        }
    }
}
