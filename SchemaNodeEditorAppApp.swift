import SwiftUI

@main
struct SchemaNodeEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var canvasState = CanvasState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .environmentObject(canvasState)
        }
        // ... (rest of your CommandGroup logic)
    }
}
