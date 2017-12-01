//
//  FormViewController.swift
//  bean_swift_w_sdk
//
//  Created by Gaby Ruiz-Funes on 11/15/17.
//  Copyright © 2017 joseph slater. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {
    var formData: [String: Any] = [:]
    
    // Initialize input fields
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputBBT: UITextField!
    
    // Initialize labels
    @IBOutlet weak var mensesLabel: UILabel!
    
    // Menstruation switch
    @IBOutlet weak var mensesSwitch: UISwitch!
    
    @IBAction func mensesSwitch(_ sender: UISwitch) {
        if(sender.isOn == true){
            print("on")
            mensesLabel.text = "Yes"
            formData["menses"] = true
            print(formData["menses"])
            
        } else {
            print("off")
            mensesLabel.text = "No"
            print(formData["menses"])
        }
    }
    
    
    
@IBOutlet weak var bbtDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        mensesSwitch.setOn(false, animated: false)
        //defaultValues
        formData["menses"] = false
    }
    
    @IBOutlet weak var BBTlog: UILabel!
    
    // Initialize submit button
    @IBAction func submitData(_ sender: Any) {
        if inputName.text == ""  {
            BBTlog.text = "Please enter name to connect"
        } else {
            BBTlog.text = "Data Logged"
        }
        formData["name"] = inputName.text
        formData["oral_temp"] = inputBBT.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let strDate = dateFormatter.string(from: bbtDatePicker.date)
        formData["lhTime"] = strDate
        
        print(strDate);
        
        postRequest(data: formData)
        formData = [:]
    }
    
    
    // Post data
    func postRequest(data: Any) {
        print("post request!!!!!!!!!")
        
        print("SOMEDATA")
        print(data)
        
        var request = URLRequest(url: URL(string: "https://oddworld.herokuapp.com/bbt_data")!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

