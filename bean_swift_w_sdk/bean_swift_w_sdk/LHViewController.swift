//
//  LHViewController.swift
//  bean_swift_w_sdk
//
//  Created by Gaby Ruiz-Funes on 11/21/17.
//  Copyright © 2017 joseph slater. All rights reserved.
//

import UIKit

class LHViewController: UIViewController {

    var formData: [String: Any] = [:]
    
    // Initialize input fields
    @IBOutlet weak var inputName: UITextField!
    
    // LH switches
        @IBOutlet weak var lhSurge: UISwitch!
        @IBAction func lhSurge(_ sender: UISwitch) {
            if(sender.isOn == true){
                print("on")
                formData["lh_surge"] = true
                noSurge.setOn(false, animated: false)
                lhInconclusive.setOn(false, animated: false)
            }
        }
    
        @IBOutlet weak var noSurge: UISwitch!
        @IBAction func noSurge(_ sender: UISwitch) {
            if(sender.isOn == true){
                print("on")
                formData["lh_surge"] = false
                lhSurge.setOn(false, animated: false)
                lhInconclusive.setOn(false, animated: false)
            }
        }
    
        @IBOutlet weak var lhInconclusive: UISwitch!
        @IBAction func lhInconclusive(_ sender: UISwitch) {
            if(sender.isOn == true){
                print("on")
                formData["lh_surge"] = "inconclusive"
                lhSurge.setOn(false, animated: false)
                noSurge.setOn(false, animated: false)
            }
        }
    
    // Date Picker
    @IBOutlet weak var lhDatePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
                lhSurge.setOn(false, animated: false)
                noSurge.setOn(false, animated: false)
                lhInconclusive.setOn(false, animated: false)
        //defaultValues
        formData["lh_surge"] = "NA"

    }
    
    // Initialize submit button
    @IBAction func submitData(_ sender: Any) {
        
        formData["name"] = inputName.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let strDate = dateFormatter.string(from: lhDatePicker.date)
        formData["lhTime"] = strDate
        
        postRequest(data: formData)
        formData = [:]
    }
    
    
    // Post data
    func postRequest(data: Any) {
        print("post request!!!!!!!!!")
        
        print("SOMEDATA")
        print(data)
        
        var request = URLRequest(url: URL(string: "https://oddworld.herokuapp.com/ios_test")!)
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
