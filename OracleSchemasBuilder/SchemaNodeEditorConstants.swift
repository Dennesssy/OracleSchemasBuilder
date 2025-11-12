import SwiftUI

/// Project‑wide constants used for layout and values.
struct Constants {
    struct Node {
        static let width: CGFloat = 300
        static let headerHeight: CGFloat = 30
        static let fieldHeight: CGFloat = 16
        static let padding: CGFloat = 12
    }
    
    struct Canvas {
        static let minZoom: CGFloat = 0.5
        static let maxZoom: CGFloat = 2.0
        static let gridSpacing: CGFloat = 20.0
    }
    
    struct File {
        static let defaultPositionRange: ClosedRange<Double> = 100...500
    }
}
