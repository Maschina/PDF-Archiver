//
//  AppDelegate.swift
//  Archiver
//
//  Created by Julian Kahnert on 29.12.17.
//  Copyright © 2017 Julian Kahnert. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func showHelp(_ sender: NSMenuItem) {
        let helpURL = URL(string: "https://pdf-archiver.io/faq")
        NSWorkspace.shared.open(helpURL!)
    }
    @IBAction func showPrivacy(_ sender: NSMenuItem) {
        let helpURL = URL(string: NSLocalizedString("privacy", comment: "PDF Archiver privacy website"))
        NSWorkspace.shared.open(helpURL!)
    }
    @IBAction func showPreferences(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("ShowPreferences"), object: nil)
    }
    @IBAction func resetUserDefaults(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("ResetCache"), object: nil)
    }
    @IBAction func showOnboarding(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("ShowOnboarding"), object: nil)
    }
    @IBAction func updateTags(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("UpdateTags"), object: nil)
    }
    @IBAction func changeZoom(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: Notification.Name("ChangeZoom"), object: sender)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
