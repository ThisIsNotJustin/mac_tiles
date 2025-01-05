import Cocoa

class WindowManager : NSObject {
    private let workspace = NSWorkspace.shared

    func getVisibleWindows() -> [NSRunningApplication] {
        return workspace.runningApplications.filter {
            app in app.isHidden == false && app.activationPolicy == .regular
        }
    }

    func tileWindows() {
        let screen = NSScreen.main!
        let screen_frame = screen.visibleFrame
        let visible_windows = getVisibleWindows()
        let window_count = visible_windows.count

        let cols = Int(ceil(sqrt(Double(window_count))))
        let rows = Int(ceil(Double(window_count) / Double(cols)))
        let window_width = screen_frame.width / CGFloat(cols)
        let window_height = screen_frame.height / CGFloat(rows)

        for (index, app) in visible_windows.enumerated() {
            let row = index / cols
            let col = index % cols

            let frame = NSRect(
                x: screen_frame.minX + (CGFloat(col) * window_width),
                y: screen_frame.minY + (CGFloat(row) * window_height),
                width: window_width,
                height: window_height
            )
        }
    }
}