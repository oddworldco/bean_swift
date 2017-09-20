//
//  ViewController.swift
//  bean_swift_w_sdk
//
//  Created by Gaby Ruiz-Funes on 9/17/17.
//  Copyright © 2017 Odd World Co. All rights reserved.
//

import UIKit
import Bean_iOS_OSX_SDK

class ViewController: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate  {
    
    // Declare variables we will use throughout the app
    var beanManager: PTDBeanManager?
    var yourBean: PTDBean?
    
    var tempRepeat: Timer!
    
    // After view is loaded into memory, we create an instance of PTDBeanManager
    // and assign ourselves as the delegate
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
//        let scanError: NSError?
        
        if beanManager!.state == BeanManagerState.poweredOn {
            startScanning()
//            if let e = scanError {
//                print(e)
//            } else {
//                print("Please turn on your Bluetooth")
//            }
        }
    }
    
    // Scan for Beans
    func startScanning() {
        var error: NSError?
        beanManager!.startScanning(forBeans_error: &error)
        if let e = error {
            print(e)
        }
    }
    
    // We connect to a specific Bean
    func beanManager(_ beanManager: PTDBeanManager!, didDiscover bean: PTDBean!, error: Error!) {
        if let e = error {
            print(e)
        }
        
        print("Found a Bean: \(bean.name)")
        if bean.name == "gaby_bean" {
            yourBean = bean
            print("got your bean")
            connectToBean(bean: yourBean!)
            //sendButtonTapped(sender: "test" as AnyObject);
            }
        //postRequest()
    }
    
    // Bean SDK: connects to Bean
    func connectToBean(bean: PTDBean) {
        var error: NSError?
        beanManager!.connect(to: bean, withOptions: nil, error: &error)
    }
    
    func beanManager(_ beanManager: PTDBeanManager!, didConnect bean: PTDBean!, error: Error!) {
        print("bean Manager called")
        tempRepeat = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    func beanTemp(_ beanManager: PTDBeanManager!, didUpdateTemperature degrees_celsius: NSNumber!, error: Error!) {
        print("hello2323123!")

    }
    
    func runTimedCode() {
        print(yourBean)
        yourBean?.readTemperature()
    }
    
    func getbeanTemp(_ bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {
        print("Temp")
        print(degrees_celsius)
        bean.readTemperature()
    }
    
    //post request:
    
    
    func postRequest() {
        print("post request!!!!!!!!!")
        
        let customer = [
            "uuid": "uuid",
            "timeStamp": "currentDate",
            "data": "data",
            ] as [String: Any]
        // "https://oddworld.herokuapp.com/collect_data"
        
        var request = URLRequest(url: URL(string: "https://oddworld.herokuapp.com/collect_data")!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: customer, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/vnd.marketplace.v1", forHTTPHeaderField: "Accept")
        
        
        print("begin urlsession")
        
        URLSession.shared.dataTask(with:request, completionHandler: {data, response, error in
            print(response)
            print("*************")
            if error != nil {
                print(error)
            } else {
                do {
                    guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else { return }
                    
                    guard let errors = json?["errors"] as? [[String: Any]] else { return }
                    if errors.count > 0 {
                        // show error
                        return
                    } else {
                        // show confirmation
                    }
                }
            }
            print("******************************")
        }).resume()
    }
}

