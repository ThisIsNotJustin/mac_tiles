//
//  ContentView.swift
//  mac-tiles
//
//  Created by Justin on 1/6/25.
//

import SwiftUI
import Cocoa
import CoreGraphics

struct ContentView: View {
    @StateObject private var windowManager = WindowManager()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Window Tiling Manager")
                .font(.title)
            
            Button("Refresh Windows") {
                windowManager.refresh()
            }
            
            Button("Tile Windows") {
                windowManager.tile()
            }
            
            List(windowManager.activeWindows) { window in
                VStack(alignment: .leading) {
                    Text(window.name)
                        .font(.headline)
                    Text("Position: (\(Int(window.frame.minX)), \(Int(window.frame.minY)))")
                }
            }
        }
        .padding()
        
    }
}

struct MenuBarView: View {
    @StateObject private var windowManager = WindowManager()
    
    var body: some View {
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}

#Preview {
    ContentView()
}
