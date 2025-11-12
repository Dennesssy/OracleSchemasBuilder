//
//  SchemaNodeEditorApp.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import SwiftUI

@main
struct SchemaNodeEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionManager)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Table Node") {
                    sessionManager.addTableNode()
                }
                .keyboardShortcut("t", modifiers: [.command])
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Save Session") {
                    sessionManager.saveSession()
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            
            CommandGroup(after: .importExport) {
                Button("Export as Markdown...") {
                    sessionManager.exportAsMarkdown()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
