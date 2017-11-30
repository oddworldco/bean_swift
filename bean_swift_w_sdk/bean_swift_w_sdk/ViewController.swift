//
//  ViewController.swift
//  bean_swift_w_sdk
//
//
//  ViewController.swift
//  bean_swift_w_sdk
//
import UIKit
import Bean_iOS_OSX_SDK

class ViewController: UIViewController,  UITextFieldDelegate, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    // Declare variables we will use throughout the app
    var beanManager: PTDBeanManager?
    var connectedBean: PTDBean?
    var tempRepeat: Timer!
    var name: String!
    var someData: [String: Any] = [:]
    var memory = [NSString]()
    var batteryLevel: Int = 0
    
    // Create UI variables
    @IBOutlet weak var promptText: UILabel!
    
    //store bean name using core data
    @IBOutlet weak var beanName: UITextField!
    
    @IBOutlet weak var tempOutput: UILabel!
    
    @IBAction func connect(_ sender: Any) {
        if beanName.text == ""  {
            promptText.text = "Please enter name to connect"
        } else {
            startScanning()
            print("SCANNING!!!!!")
            promptText.text = "Searching..."
        }
    }
    
    @IBAction func disconnect(_ sender: Any) {
        beanManager?.disconnectBean(connectedBean, error: nil)
        print("disconnect");
    }
    
    @IBOutlet weak var nameText: UILabel!
    
    // After view is loaded into memory, we create an instance of PTDBeanManager
    // and assign ourselves as the delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beanManager = PTDBeanManager()
        beanManager!.delegate = self
        beanName.delegate = self
    }
    
    // hide keypad on enter:
    func textFieldShouldReturn(_ beanName: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
        
        print("LOOKING FOR:")
        print(beanName.text)
        
        if bean.name == beanName.text! { //TODO: change this to dynamically update based on available beans
            connectedBean = bean
            name = beanName.text
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
        self.promptText.text = "Smarty Pants Connected to:"
        
        tempRepeat = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        print("bean manager called")
        tempOutput.text = "Loading..."
    }
    
    // Call data functions
    func runTimedCode() {
        self.connectedBean?.delegate = self
        someData["name"] = name
        
        self.connectedBean?.readAccelerationAxes()
        self.connectedBean?.readScratchBank(2)
        self.connectedBean?.readTemperature()
        
        print(someData);
        if(someData.count>2){
            postRequest(data: someData)
            someData = [:]
        }
        self.connectedBean?.readBatteryVoltage()
    }
    
    func beanManager(_ beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: Error!) {
        self.connectedBean = nil
        print("Disconnected")
        promptText.text = "Enter your device name:"
        beanName.text = ""
        tempOutput.text = "Disconnected"
    }
    
    
    func bean(_ bean: PTDBean!, didUpdateScratchBank bank: Int, data:Data!) {
        let first4: String
        let first1: String
        let float4: Float?
        let dataString: String = String(data: data, encoding: .utf8)! //?? ""
        let dataCount = dataString.characters.count
        
        if dataCount > 2 {
            first4 = dataString.substring(to:dataString.index(dataString.startIndex, offsetBy: 5))
            first1 = dataString.substring(to:dataString.index(dataString.startIndex, offsetBy:1))
        } else {
            first4 = "0"
            first1 = "-"
        }
        
        //convert to float
        if(first1 == "9"){
            float4 = Float(first4)
            someData["bodyTemp"] = float4!/1000
        } else if(first1 == "-"){
            someData["bodyTemp"] = 0.00
        } else {
            someData["bodyTemp"] = 0.00
        }
    }
    
    func bean(_ bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {
        someData["beanTemp"] = degrees_celsius!
        self.tempOutput.text = degrees_celsius.stringValue
    }
    
    
    func bean(_ bean: PTDBean!, didUpdateAccelerationAxes acceleration: PTDAcceleration) {
        someData["x"] = acceleration.x
        someData["y"] = acceleration.y
        someData["z"] = acceleration.z
    }
    
    
    func postRequest(data: Any) {
        print("post request!!!!!!!!!")
        
        print("SOMEDATA")
        print(data)
        
        var request = URLRequest(url: URL(string: "https://oddworld.herokuapp.com/ios_data")!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/vnd.marketplace.v1", forHTTPHeaderField: "Accept")
        
        
        print("begin urlsession")
        
        URLSession.shared.dataTask(with:request, completionHandler: {data, response, error in
            print(response)
            
            print("*************")
            self.tempOutput.text = "Data Logged!"
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
    
    
    
    //create service function that gets user data to define object we're posting to
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
