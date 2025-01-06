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
        let name: String
        let frame: CGRect
        let isActive: Bool
    }
    
    @objc func refresh() {
        let options = CGWindowListOption([.optionOnScreenOnly, .excludeDesktopElements])
        let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        
        activeWindows = windowList.compactMap { window -> WindowInfo? in
            guard let windowID = window[kCGWindowNumber as String] as? CGWindowID,
                  let name = window[kCGWindowName as String] as? String,
                  let bounds = window[kCGWindowBounds as String] as? [String: Any],
                  let isActive = window[kCGWindowIsOnscreen as String] as? Bool
            else {
                return nil
            }
            
            let frame = CGRect(
                x: bounds["X"] as? CGFloat ?? 0,
                y: bounds["Y"] as? CGFloat ?? 0,
                width: bounds["Width"] as? CGFloat ?? 0,
                height: bounds["Height"] as? CGFloat ?? 0
            )
            
            return WindowInfo(id: windowID, name: name, frame: frame, isActive: isActive)
        }
    }
    
    @objc func tile() {
        guard let screen = NSScreen.main?.visibleFrame
        else {
            return
        }
        
        let windowCount = activeWindows.count
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
            
            move(id: window.id, to_frame: newFrame)
        }
                
    }
    
    func move(id: CGWindowID, to_frame: CGRect) {
        print("Moving window \(id) to \(to_frame).")
    }
}
