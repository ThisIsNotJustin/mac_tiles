//
//  WindowManager.swift
//  mac-tiles
//
//  Created by Justin on 1/6/25.
//
import SwiftUI
import Cocoa

class WindowManager: ObservableObject {
    @Published var activeWindows: [WindowInfo] = []
    private let workspace = NSWorkspace.shared
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name("RefreshWindows"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tile), name: NSNotification.Name("TileWindows"), object: nil)
    }
    
    struct WindowInfo: Identifiable {
        let id: CGWindowID
        let pid: pid_t
        let name: String
        let frame: CGRect
        let isActive: Bool
    }
    
    @objc func refresh() {
        let options = CGWindowListOption([.optionOnScreenOnly, .excludeDesktopElements])
        let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        
        print("Window List: \(windowList)")
        
        activeWindows = windowList.compactMap { window -> WindowInfo? in
            guard let windowID = window[kCGWindowNumber as String] as? CGWindowID,
                  let isActive = window[kCGWindowIsOnscreen as String] as? Bool,
                  isActive == true
            else {
                return nil
            }
            
            let pid = window[kCGWindowOwnerPID as String] as? pid_t
            let name = window[kCGWindowName as String] as? String
            let ownerName = window[kCGWindowOwnerName as String] as? String
            let bounds = window[kCGWindowBounds as String] as? [String: Any]
            
            if name == "Menubar" {
                print("Skipping menubar window")
                return nil
            }
            
            if name == "mac-tiles" || name == "Item-0" {
                print("Skipping tiling manager")
                return nil
            }
            
            guard let realPID = pid, (name != nil || ownerName != nil) else {
                return nil
            }
            let windowName = name ?? ownerName ?? "Unknown"
            
            print("Detected Windows: \(windowName), \(realPID)")
            
            let frame = CGRect(
                x: bounds?["X"] as? CGFloat ?? 0,
                y: bounds?["Y"] as? CGFloat ?? 0,
                width: bounds?["Width"] as? CGFloat ?? 0,
                height: bounds?["Height"] as? CGFloat ?? 0
            )
            
            return WindowInfo(id: windowID, pid: realPID, name: windowName, frame: frame, isActive: isActive)
        }
        
        print("activeWindows found: \(activeWindows.count)")
        activeWindows.forEach { window in
            print("\(window.name) - \(window.pid)")
        }
        
    }
    
    @objc func tile() {
        guard let screen = NSScreen.main?.visibleFrame else {
            return
        }
        
        let windowCount = activeWindows.count
        print("Window Count: \(windowCount)")
        
        let cols = Int(ceil(sqrt(Double(windowCount))))
        let rows = Int(ceil(Double(windowCount) / Double(cols)))
        
        let width = screen.width / CGFloat(cols)
        let height = screen.height / CGFloat(rows)
        
        for (index, window) in activeWindows.enumerated() {
            let row = index / cols
            let col = index % cols
            
            let newFrame = CGRect(
                x: screen.minX + CGFloat(col) * width,
                y: screen.minY + CGFloat(row) * height,
                width: width,
                height: height
            )
            
            move(window: window, to_frame: newFrame)
        }
                
    }
    
    func move(window: WindowInfo, to_frame: CGRect) {
        let app = AXUIElementCreateApplication(window.pid)
        var windows: CFTypeRef?
        
        let err = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &windows)
        if err != .success {
            print("Error retrieving windows for pid \(window.name)")
            return
        }
        
        guard let windowsArray = windows as? [AXUIElement] else {
            print("Error casting window as an array")
            return
        }
        
        for axWindow in windowsArray {
            var axTitle: CFTypeRef?
            let titleErr = AXUIElementCopyAttributeValue(axWindow, kAXTitleAttribute as CFString, &axTitle)
            let windowTitle = (axTitle as? String) ?? ""
                
            if titleErr == .success && (windowTitle == window.name || windowTitle.contains(window.name)) {
                var origin = to_frame.origin
                var size = to_frame.size
                    
                let position = AXValueCreate(.cgPoint, &origin)!
                let newSize = AXValueCreate(.cgSize, &size)!
                                
                let positionError = AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, position)
                let sizeError = AXUIElementSetAttributeValue(axWindow, kAXSizeAttribute as CFString, newSize)
                                
                if positionError != .success {
                    print("Error setting position for window \(window.name): \(positionError)")
                }
                    
                if sizeError != .success {
                    print("Error setting size for window \(window.name): \(sizeError)")
                }
                                
                if positionError == .success && sizeError == .success {
                    print("Moving window \(window.name) to \(to_frame).")
                }
                    
                return
            }
        
        }
    }
}
