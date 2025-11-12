import SwiftUI

struct AppCommands: Commands {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.undoManager) var undoManager
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Session") {
                sessionManager.newSession()
            }
            .keyboardShortcut("N", modifiers: [.command])
        }
        
        CommandGroup(replacing: .toolbar, placement: .automatic) {
            Button("Add Table") {
                sessionManager.addNode()
            }
            .keyboardShortcut("N", modifiers: [.command, .shift])
        }
        
        CommandGroup(replacing: .undoRedo) {
            Button("Undo") {
                undoManager?.undo()
            }
            .keyboardShortcut("Z", modifiers: [.command])
            
            Button("Redo") {
                undoManager?.redo()
            }
            .keyboardShortcut("Z", modifiers: [.command, .shift])
        }
    }
}
