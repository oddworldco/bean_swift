//
//  FormController.swift
//  bean_swift_w_sdk
//
//  Created by Gaby Ruiz-Funes on 11/13/17.
//  Copyright © 2017 joseph slater. All rights reserved.
//

import UIKit

class FormController: UIViewController,  UITextFieldDelegate {
    
    var formData: [String: Any] = [:]

    // Initialize input fields
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputBBT: UITextField!
    
    func textFieldShouldReturn(_ inputName: UITextField, inputBBT: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // Initialize submit Button
    @IBAction func submitData(_ sender: Any) {
        
        formData["name"] = inputName.text
        formData["oral_temp"] = inputBBT.text
        
        postRequest(data: formData)
        formData = [:]
    }
    
    
    
    
    
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
    
    
    
    //create service function that gets user data to define object we're posting to
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

//        NotificationCenter.default.addObserver(self,
//           selector: #selector(self.getBeanName(_:)),
//           name: BEAN_NAME_NOTIFICATION,
//           object: nil)
    }
    
    
//    func getBeanName(_ notification: NSNotification) -> Void {
//        // use guard to display conditional data
//        guard let userInfor = notification.userInfo,
//              let name = userInfo["name"] as? String else {
//                print("Error! No name found!")
//                return
//        }
//
//        DispatchQueue.main.async {
//            print("name!!!")
//            print(name)
//        }
//    }

