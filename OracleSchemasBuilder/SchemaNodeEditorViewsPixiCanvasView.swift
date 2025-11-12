import SwiftUI
import WebKit

/// A SwiftUI wrapper that embeds a WKWebView running a PixiJS scene.
/// The view listens for changes in the current session and pushes a JSON
/// representation of the session to the web page.  The JavaScript side
/// is expected to call `window.receiveSession(json)` to consume the data.
///
/// The web page should reside in the app bundle under the name
/// `pixiCanvas.html` (see the accompanying HTML file).
struct PixiCanvasView: NSViewRepresentable {
    @Environment(SessionManager.self) private var sessionManager
    
    // The name of the local HTML file that contains the PixiJS app.
    private let htmlFileName = "pixiCanvas"
    
    func makeNSView(context: Context) -> WKWebView {
        // Configure the web view to allow communication from JS.
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "schemaHandler")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = false
        
        // Load the local HTML file from the app bundle.
        if let url = Bundle.main.url(forResource: htmlFileName, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("⚠️ PixiCanvasView: Failed to locate \(htmlFileName).html in bundle.")
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Push the current session to the web view only when the session
        // has changed (isDirty flag).  This keeps the bridge efficient.
        guard sessionManager.isDirty else { return }
        do {
            let data = try JSONEncoder().encode(sessionManager.currentSession)
            guard let jsonString = String(data: data, encoding: .utf8) else { return }
            // Escape quotes for inline JS.
            let escaped = jsonString.replacingOccurrences(of: "\"", with: "\\\"")
            let js = "window.receiveSession(\"\(escaped)\");"
            nsView.evaluateJavaScript(js, completionHandler: { result, error in
                if let error = error {
                    print("⚠️ PixiCanvasView: JS eval error – \(error)")
                }
            })
        } catch {
            print("⚠️ PixiCanvasView: Failed to encode session – \(error)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        let parent: PixiCanvasView
        
        init(_ parent: PixiCanvasView) {
            self.parent = parent
        }
        
        /// Handle messages sent from the JavaScript side via
        /// `window.webkit.messageHandlers.schemaHandler.postMessage(...)`.
        func userContentController(_ userContentController: WKUserContentController,
                                  didReceive message: WKScriptMessage) {
            guard message.name == "schemaHandler" else { return }
            
            if let body = message.body as? [String: Any] {
                // Example: The JS side can send a node selection event:
                // { type: "nodeSelected", nodeId: "..." }
                if let type = body["type"] as? String {
                    switch type {
                    case "nodeSelected":
                        if let idString = body["nodeId"] as? String,
                           let uuid = UUID(uuidString: idString) {
                            parent.sessionManager.selectNode(uuid)
                        }
                    default:
                        break
                    }
                }
            } else {
                print("⚠️ PixiCanvasView: Received non‑dictionary message from JS.")
            }
        }
    }
}
