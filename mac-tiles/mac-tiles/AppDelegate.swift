//
//  AppDelegate.swift
//  mac-tiles
//
//  Created by Justin on 1/6/25.
//
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var status: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        requestAccessibilityPermissions()
    }
    
    func setupMenuBar() {
        status = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = status?.button {
            button.image = NSImage(systemSymbolName: "rectangle.split.3x3", accessibilityDescription: "Tile Windows")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh Windows", action: #selector(refreshWindows), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Tile Windows", action: #selector(tileWindows), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
        status?.menu = menu
    }

    @objc func refreshWindows() {
        // Call window refresh logic
        NotificationCenter.default.post(name: NSNotification.Name("RefreshWindows"), object: nil)
    }

    @objc func tileWindows() {
        // Call window tiling logic
        NotificationCenter.default.post(name: NSNotification.Name("TileWindows"), object: nil)
    }
    
    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !isTrusted {
            print("Accessibility permissions are not granted.")
        }
    }
}
