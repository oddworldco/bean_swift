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
//    var someData = [NSArray]()
    var batteryLevel: Int = 0
    var someData: [String: Any] = [:]

    
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
        tempRepeat = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

        print("bean manager called")
     }
    
    func runTimedCode() {
        //self.connectedBean = bean
        self.connectedBean?.delegate = self
                someData["name"] = beanName.text!
        someData["timeStamp"] = Date()
        
        self.connectedBean?.readScratchBank(1)
        self.connectedBean?.readAccelerationAxes()
        self.connectedBean?.readTemperature()
        //self.connectedBean?.readBatteryVoltage()
        print(someData);
        postRequest(data: someData)
        //someData = [:]
    }
    
    func beanManager(_ beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: Error!) {
        self.connectedBean = nil
        print("Disconnected")
        promptText.text = "Enter your device name:"
        beanName.text = ""
        tempOutput.text = "Loading..."
    }
    
    func bean(_ bean: PTDBean!, didUpdateScratchBank bank: Int, data:Data) {
//        print("********************************")
//        print("found scratch!")
//        print(data)
        let data = Data(bytes: [0x71, 0x3d, 0x0a, 0xd7, 0xa3, 0x10, 0x45, 0x40])
        let value: Double = data.withUnsafeBytes { $0.pointee }
//        print(value)
        someData["bodyTemp"] = value

//        print("********************************")
    }
    
    func bean(_ bean: PTDBean!, beanDidUpdateBatteryVoltage error:NSError) {
        print("batteryVoltage")
    }

    
    func bean(_ bean: PTDBean!, didUpdateTemperature degrees_celsius: NSNumber!) {
        print(degrees_celsius)
        
        someData["beanTemp"] = degrees_celsius!
        self.tempOutput.text = degrees_celsius.stringValue
    }
    
    
    func bean(_ bean: PTDBean!, didUpdateAccelerationAxes acceleration: PTDAcceleration) {
        someData["X"] = acceleration.x
        someData["Y"] = acceleration.y
        someData["Z"] = acceleration.z
        
        // Show acceleration
//        print( "********************************")
//        print( "X: \(acceleration.x); Y: \(acceleration.y); Z: \(acceleration.z)" )
//        print( "********************************")
    }
    
    //post request:
//    func createObj(temp: NSNumber!) {
//        let temp = temp
//        print("DATA!")
//        //postRequest(temp: temp)
//    }
    
    func postRequest( data: Any) {
        print("post request!!!!!!!!!")
        
        print("SOMEDATA")
//        [{'bodyTemp': '42.13', 'X': '-0.0703125', 'Y': '0.09375', 'Z': '1.046875', 'beanTemp': '20'}, 'name': 'gaby_bean' , 'timeStamp': '2017-10-18 02:08:16 +0000'}, 'volts':'Optional(())']
        
//        let obj = [
//            "bodyTemp": data.bodyTemp,
//            "X": data.X,
//            "Y": data.Y,
//            "Z": data.Z,
//            "beanTemp": data.beanTemp,
//            "timeStamp": data.timeStamp,
//            "name": data.name
//            ] as [String: Any]
        // "https://oddworld.herokuapp.com/collect_data"
        
//        print(obj)
//        var request = URLRequest(url: URL(string: "https://oddworld.herokuapp.com/collect_data")!)
//        request.httpMethod = "POST"
//        request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/vnd.marketplace.v1", forHTTPHeaderField: "Accept")
//
//
//        print("begin urlsession")
//
//        URLSession.shared.dataTask(with:request, completionHandler: {data, response, error in
//            print(response)
//            print("*************")
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
//            print("******************************")
//        }).resume()
    }
    
    
    
    
    //create service function that gets user data to define object we're posting to
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
}

