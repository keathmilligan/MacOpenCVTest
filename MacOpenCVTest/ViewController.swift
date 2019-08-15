//
//  ViewController.swift
//  MacOpenCVTest
//
//  Created by Keath Milligan on 12/29/17.
//  Copyright © 2017 Keath Milligan. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    weak var appDelegate: AppDelegate!
    @IBOutlet weak var imageRef: NSImageView!
    @IBOutlet weak var imageProc: NSImageView!
    @IBOutlet weak var imageDebug: NSImageView!
    @IBOutlet weak var imageResult: NSImageView!
    @IBOutlet weak var analyzeResults: NSTextField!
    @IBOutlet weak var fsInvert: NSButton!
    @IBOutlet weak var fsDarken: NSTextField!
    @IBOutlet weak var fsBlur: NSTextField!
    @IBOutlet weak var fsContrast: NSTextField!
    @IBOutlet weak var fsThreshold: NSButton!
    @IBOutlet weak var fsThresholdValue: NSTextField!
    @IBOutlet weak var fcHough1: NSTextField!
    @IBOutlet weak var fcHough2: NSTextField!
    @IBOutlet weak var fcMinDist: NSTextField!
    @IBOutlet weak var fcMinSize: NSTextField!
    @IBOutlet weak var fcMaxSize: NSTextField!
    @IBOutlet weak var circlesFound: NSTextField!
    var processedImage: NSImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.mainView = self
        // Do any additional setup after loading the view.
        let version: String = OpenCVWrapper.openCVVersionString()
        print("OpenCV version:", version)
        setShapeDefaults()
        setCircleDefaults()
        processedImage = nil
        appDelegate.openMostRecent()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setImage(image: NSImage) {
        imageRef.image = image
        imageProc.image = image
        imageDebug.image = image
        imageResult.image = image
    }

    @IBAction func loadImage(_ sender: Any) {
        appDelegate.loadImage()
    }

    @IBAction func resetImage(_ sender: Any) {
        imageProc.image = imageRef.image
        imageDebug.image = imageRef.image
        imageResult.image = imageRef.image
        processedImage = nil
    }

    @IBAction func analyzeImage(_ sender: Any) {
    }
    
    func setShapeDefaults() {
        let defaults = FindShapeSettings()
        fsInvert.state = defaults.invert ? NSControl.StateValue.on : NSControl.StateValue.off
        fsDarken.stringValue = String(defaults.darken)
        fsBlur.stringValue = String(defaults.blur)
        fsContrast.stringValue = String(defaults.contrast)
        fsThreshold.state = defaults.threshold ? NSControl.StateValue.on : NSControl.StateValue.off
        fsThresholdValue.stringValue = String(defaults.thresholdValue)
    }

    @IBAction func findShapeDefaults(_ sender: Any) {
        setShapeDefaults()
    }

    @IBAction func findShapes(_ sender: Any) {
        let settings = FindShapeSettings()
        settings.invert = fsInvert.state == NSControl.StateValue.on
        settings.darken = Int32(fsDarken.stringValue)!
        settings.blur = Int32(fsBlur.stringValue)!
        settings.contrast = Double(fsContrast.stringValue)!
        settings.threshold = fsThreshold.state == NSControl.StateValue.on
        settings.thresholdValue = Double(fsThresholdValue.stringValue)!
        
        OpenCVWrapper.findShapes(imageRef.image, settings: settings, completionHandler: { (result: NSImage?, proc: NSImage?, debug: NSImage?, resultCount: Int32, max: Int32) in
            
            print("count:", resultCount, "max size:", max)
            self.imageProc.image = proc
            self.imageDebug.image = debug
            self.imageResult.image = result
            self.processedImage = result
        })
    }
    
    func setCircleDefaults() {
        let defaults = FindCircleSettings()
        fcHough1.stringValue = String(defaults.h1)
        fcHough2.stringValue = String(defaults.h2)
        fcMinDist.stringValue = String(defaults.minDist)
        fcMinSize.stringValue = String(defaults.minSize)
        fcMaxSize.stringValue = String(defaults.maxSize)
    }
    
    @IBAction func findCircleDefaults(_ sender: Any) {
        setCircleDefaults()
    }

    @IBAction func findCircles(_ sender: Any) {
        let settings = FindCircleSettings()
        settings.h1 = Int32(fcHough1.stringValue)!
        settings.h2 = Int32(fcHough2.stringValue)!
        settings.minDist = Int32(fcMinDist.stringValue)!
        settings.minSize = Int32(fcMinDist.stringValue)!
        settings.maxSize = Int32(fcMaxSize.stringValue)!

        OpenCVWrapper.findCircles(processedImage, ref:imageRef.image, settings: settings, completionHandler: { (result: NSImage?, proc: NSImage?, debug: NSImage?, resultCount: Int32) in
            
            self.circlesFound.stringValue = String(resultCount)
            self.imageProc.image = proc
            self.imageDebug.image = debug
            self.imageResult.image = result
        })
    }
}
