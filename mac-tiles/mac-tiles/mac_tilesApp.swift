//
//  mac_tilesApp.swift
//  mac-tiles
//
//  Created by Justin on 1/6/25.
//

import SwiftUI

@main
struct mac_tilesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
