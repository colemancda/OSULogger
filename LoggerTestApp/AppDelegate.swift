//
//  AppDelegate.swift
//  LoggerTestApp
//
//  Created by William Dillon on 6/12/15.
//  Copyright © 2015 Oregon State University (COAS). All rights reserved.
//

import Cocoa
import OSULogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let logger = OSULogger.sharedLogger()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        logger.log("Hello world.", severity: .Information)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }


}

