//
//  AppDelegate.swift
//  MacOpenCVTest
//
//  Created by Keath Milligan on 12/29/17.
//  Copyright © 2017 Keath Milligan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public weak var mainView: ViewController!
    var lastImageURL: URL!

    @IBAction func openImage(_ sender: Any) {
        loadImage()
    }
    
    func loadImage() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        let result = openPanel.runModal()
        if (result == NSApplication.ModalResponse.OK) {
            openFile(url: openPanel.url!)
        }
    }

    func openFile(url: URL) {
        lastImageURL = url
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        let image = NSImage(contentsOf: url)!
        mainView.setImage(image: image)
    }

    func openMostRecent() {
        let dc = NSDocumentController.shared
        if (dc.recentDocumentURLs.count > 0) {
            openFile(url: dc.recentDocumentURLs[0])
        }
    }
    
    func reloadImage() {
        openFile(url: lastImageURL)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func application(_ application: NSApplication, open urls: [URL]){
        if urls.count > 0 {
            openFile(url: urls[0])
        }
    }
}
