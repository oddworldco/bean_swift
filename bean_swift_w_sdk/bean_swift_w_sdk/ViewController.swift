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
//    var someData = [NSString]()
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
        }
    }
    
    @IBAction func disconnect(_ sender: Any) {
        beanManager?.disconnectBean(connectedBean, error: nil)
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
    
    
    
    // Bean SDK: We check to see if Bluetooth is on.
    //    func beanManagerDidUpdateState(_ beanManager: PTDBeanManager!) {
    //        if beanManager!.state == BeanManagerState.poweredOn {
    //            startScanning()
    //        } else if beanManager!.state == BeanManagerState.poweredOff {
    //            print("Please turn on your bluetooth")
    //        }
    //    }
    
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
            print("Discovered your Bean: \(bean.name)")
            connectToBean(bean: connectedBean!)
        }
        promptText.text = "Searching..."
    }
    
    // Connects to Bean
    func connectToBean(bean: PTDBean) {
        var error: NSError?
        beanManager!.connect(to: bean, withOptions: nil, error: &error)
    }
    
    // Bean SDK: After connecting to Bean
    
    func beanManager(_ beanManager: PTDBeanManager!, didConnect bean: PTDBean!, error: Error!) {
        self.promptText.text = "Smarty Pants Connected to:"
        
        //for i in buffer size
        //bufferRepeat = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runUnloadCode), userInfo: nil, repeats: true)
        
        tempRepeat = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        print("bean manager called")
    }
    
    // func runUnloadCode() {
    //self.connectedBean = bean
    //    self.connectedBean?.delegate = self
    //    memory = []
    //    self.connectedBean?.
    //    memory.
    // }
    
    func runTimedCode() {
        //self.connectedBean = bean
        self.connectedBean?.delegate = self
        someData["name"] = beanName.text!
//        someData["timeStamp"] = Date()
//        postRequest(data: someData)
//        print(someData)
//        someData = []
        
//        someData.append("{'name': '\(beanName.text!)' " as NSString)
//        someData.append("'timeStamp': '\(Date())' " as NSString)
//        someData.append("'battery': '\(BATTERY_0_PCNT_VOLTAGE)' " as NSString)
        
        self.connectedBean?.readAccelerationAxes()
        self.connectedBean?.readScratchBank(2)
        self.connectedBean?.readTemperature()
        
        print(someData);
        if(someData.count>1){
            postRequest(data: someData)
            someData = [:]
        }
        //self.connectedBean?.readBatteryVoltage()
    }
    
    func beanManager(_ beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: Error!) {
        self.connectedBean = nil
        print("Disconnected")
        promptText.text = "Enter your device name:"
        beanName.text = ""
        tempOutput.text = "Loading..."
    }
    
    
    
    //func bean(_ bean: PTDBean!, serialDataReceived serial:NSData!) {
    //    print(serial)
    //    let strReceived = NSString(data: serial as Data, encoding: String.Encoding.utf8.rawValue)
    //    someData.append("'Temp': '\(strReceived)'}" as NSString)
    //}
    
    
    func bean(_ bean: PTDBean!, didUpdateScratchBank bank: Int, data:Data!) {
        //       print("********************************")
        //        print("found scratch!")
        //print(data)
        //let bytes = data
        //let string = String(bytes: data, encoding: .utf8)
        //var dataString = String(data: bytes!, encoding: .utf16)
        let dataString: String = String(data: data, encoding: .utf8)! //?? ""
//        print("raw: '\(dataString)'")
        if dataString.characters.count > 2 {
            let first4 = dataString.substring(to:dataString.index(dataString.startIndex, offsetBy: 4))
//            someData.append("'bodyTemp': '\(first4)' " as NSString)
              someData["bodyTemp"] = first4
        } else {
            let first4 = "0"
            someData["bodyTemp"] = first4
//            someData.append("'bodyTemp': '\(first4)' " as NSString)
        }
        //print(first4)
        //let dataString2: Float = dataString
        //let dataString: String = String(describing: data) //?? ""
        //someData.append("'bodyTemp': '\(first4)' " as NSString)
        //        print("********************************")
    }
    
    func bean(_ bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {

//        someData.append("'beanTemp': '\(degrees_celsius!)' }" as NSString)
        someData["beanTemp"] = degrees_celsius!
        self.tempOutput.text = degrees_celsius.stringValue
    }
    
    
    func bean(_ bean: PTDBean!, didUpdateAccelerationAxes acceleration: PTDAcceleration) {
//        someData.append("'X': '\(acceleration.x)', 'Y': '\(acceleration.y)', 'Z': '\(acceleration.z)' "as NSString)
        someData["X"] = acceleration.x
        someData["Y"] = acceleration.y
        someData["Z"] = acceleration.z
    }
    
    
    func postRequest(data: Any) {
        print("post request!!!!!!!!!")
        
        print("SOMEDATA")
        print(data)
        
        //        let data = [
        //            "uuid": "uuid",
        //            "timeStamp": "currentDate",
        //            "temp": temp,
        //            ] as [String: Any]
        // "https://oddworld.herokuapp.com/collect_data"
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
            //            if error != nil {
            //                print(error)
            //            } else {
            //                do {
            //                    guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else { return }
            //
            //                    guard let errors = json?["errors"] as? [[String: Any]] else { return }
            //                    if errors.count > 0 {
            //                        // show error
            //                        return
            //                    } else {
            //                        // show confirmation
            //                    }
            //                }
            //            }
            print("******************************")
        }).resume()
    }
    
    
    
    
    //create service function that gets user data to define object we're posting to
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

