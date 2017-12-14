//
//  AppDelegate.swift
//  Demo
//
//  Created by Dave DeLong on 11/20/17.
//

import Cocoa
import MathParser

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var demoWindow: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let window = NSWindow(contentViewController: DemoViewController())
        window.title = "Demo"
        demoWindow = NSWindowController(window: window)
        demoWindow?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

