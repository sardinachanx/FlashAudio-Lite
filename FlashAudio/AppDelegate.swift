//
//  AppDelegate.swift
//  FlashAudio
//
//  Created by Serena Chan on 12/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /*if let loginController = LoginController(nibName: "LoginController", bundle: nil){
            window.contentView!.addSubview(loginController.view)
            loginController.view.frame = (window.contentView! as NSView).bounds
            
        }*/
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

