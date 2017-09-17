//
//  ViewController.swift
//  bean_swift_w_sdk
//
//  Created by joseph slater on 9/11/17.
//  Copyright © 2017 joseph slater. All rights reserved.
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
        postRequest()
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
        print("hello2323123!")
        yourBean?.readTemperature()
    }
    
    func bean(_ bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {
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
        
        var request = URLRequest(url: URL(string: "http://localhost:3000/collect_data")!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: customer, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
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
        }).resume()
    }
    //@IBAction func sendButtonTapped(sender: AnyObject)
    func sendButtonTapped(sender: AnyObject) {
        print("initialize post function")
        
        let userNameValue = "test"
        
        // Send HTTP GET Request
        
        // Define server side script URL
        let scriptUrl = "http://localhost:3000/collect_data"
        
        // Add one parameter
        let urlWithParams = scriptUrl + "?userName=\(userNameValue)"
        
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "POST"
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(String(describing: responseString))")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    print(convertedJsonIntoDict)
                    
                    // Get value by key
                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
                    print(firstNameValue!)
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
    }

}

