//
//  ViewController.swift
//  bean_swift_w_sdk
//
//  Created by joseph slater on 9/11/17.
//  Copyright © 2017 joseph slater. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK

class ViewController: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    // Declare variables we will use throughout the app
    var beanManager: PTDBeanManager?
    var device: PTDBean?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beanManager = PTDBeanManager()
        beanManager!.delegate = self
    }
    
    // After the view is added we will start scanning for Bean peripherals
    override func viewDidAppear(_ animated: Bool) {
        startScanning()
    }
    
    // Bean SDK: We check to see if Bluetooth is on.
    func beanManagerDidUpdateState(_ beanManager: PTDBeanManager!) {
        
        if beanManager!.state == BeanManagerState.poweredOn {
            startScanning()
            print("Bean found")
        }
    }
    
    // Scan for Beans
    func startScanning() {
        var error: NSError?
        beanManager!.startScanning(forBeans_error: &error)
        if error != nil {
            
        }
    }
    
    func beanManager(_ beanManager: PTDBeanManager!, didDiscover bean: PTDBean!, error: Error!) {
        if (bean.name == "Bean") {
            device = bean
            connectToDevice(device!)
            print("Connected to Bean")
        } else {
            print("Did not connect to Bean")
        }
    }
    
    func connectToDevice(_ device: PTDBean) {
        var error: NSError?
        beanManager!.connect(to: device, withOptions: nil, error: &error)
    }

//
//    // Change LED text when button is pressed
//    func updateLedStatusText(lightState: Bool) {
//        let onOffText = lightState ? "ON" : "OFF"
//        ledTextLabel.text = "Led is: \(onOffText)"
//    }
//    
//    // Mark: Actions
//    // When we pressed the button, we change the light state and
//    // We update date the label, and send the Bean serial data
//    @IBAction func pressMeButtonToToggleLED(sender: AnyObject) {
//        lightState = !lightState
//        updateLedStatusText(lightState)
//        let data = NSData(bytes: &lightState, length: sizeof(Bool))
//        sendSerialData(data)
//        
//    }
}
