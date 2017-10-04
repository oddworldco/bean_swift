//
//  ViewController.swift
//  bean_swift_w_sdk
//
import UIKit
import Bean_iOS_OSX_SDK

class ViewController: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    // Declare variables we will use throughout the app
    var beanManager: PTDBeanManager?
    var connectedBean: PTDBean?
    
    // After view is loaded into memory, we create an instance of PTDBeanManager
    // and assign ourselves as the delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beanManager = PTDBeanManager()
        beanManager!.delegate = self
    }
    
    // Bean SDK: We check to see if Bluetooth is on.
    func beanManagerDidUpdateState(_ beanManager: PTDBeanManager!) {
        if beanManager!.state == BeanManagerState.poweredOn {
            startScanning()
        } else if beanManager!.state == BeanManagerState.poweredOff {
            print("Please turn on your bluetooth")
        }
    }
    
    // Scan for Peripherals
    func startScanning() {
        print("start scanning")
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
        
        if bean.name == "bean_2" { //TODO: change this to dynamically update based on available beans
            connectedBean = bean
            print("Discovered your Bean: \(bean.name)")
            connectToBean(bean: connectedBean!)
        }
    }
    
    // Connects to Bean
    func connectToBean(bean: PTDBean) {
        var error: NSError?
        beanManager!.connect(to: bean, withOptions: nil, error: &error)
    }
    
    // Bean SDK: After connecting to Bean
    func beanManager(_ beanManager: PTDBeanManager!, didConnect bean: PTDBean!, error: Error!) {
        print("bean manager called")
        self.connectedBean = bean
        self.connectedBean?.delegate = self
        
        self.connectedBean?.readScratchBank(1)
        self.connectedBean?.readAccelerationAxes()
        self.connectedBean?.readTemperature()
        self.connectedBean?.readBatteryVoltage()
        
        //self.connectedBean?.readScratchBank(Int)
    }
    
    func bean(_ bean: PTDBean!, didUpdateScratchBank bank: Int, data:Data) {
        print("found scratch!")
        print(data)
        let data = Data(bytes: [0x71, 0x3d, 0x0a, 0xd7, 0xa3, 0x10, 0x45, 0x40])
        let value: Double = data.withUnsafeBytes { $0.pointee }
        print(value)
        
    }
    
    
    
    func bean(_ bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {
        print(degrees_celsius)
        createObj(temp: degrees_celsius)
    }
    
    
    func bean(_ bean: PTDBean!, didUpdateAccelerationAxes acceleration: PTDAcceleration) {
        
        // Show acceleration
        print( "X: \(acceleration.x); Y: \(acceleration.y); Z: \(acceleration.z)" )
    }
    
    //post request:
    func createObj(temp: NSNumber!) {
        let temp = temp
        print("DATA!")
        //postRequest(temp: temp)
    }
    
    func postRequest(temp: NSNumber!) {
        print("post request!!!!!!!!!")
        
        let customer = [
            "uuid": "uuid",
            "timeStamp": "currentDate",
            "temp": temp,
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
    
    //scan for all beans available
    //update UI with available beans
    //update code with selected bean
    //connect to selected bean
    
    //request scratch data
    //
    //collect temp and accel into an object
    //send to databse
    
    
    
    
    //create service function that gets user data to define object we're posting to
    
    
}

