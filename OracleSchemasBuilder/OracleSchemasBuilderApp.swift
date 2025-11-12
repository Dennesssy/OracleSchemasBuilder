import SwiftUI

@main
struct OracleSchemasBuilderApp: App {
    var body: some Scene {
        let manager = SessionManager()
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
        .commands {
            AppCommands()
        }
    }
}
