//
//  FormController.swift
//  bean_swift_w_sdk
//
//  Created by Gaby Ruiz-Funes on 11/13/17.
//  Copyright © 2017 joseph slater. All rights reserved.
//

import UIKit

class FormController: UIViewController,  UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self,
//           selector: #selector(self.getBeanName(_:)),
//           name: BEAN_NAME_NOTIFICATION,
//           object: nil)
        
        womanRadioButton?.alternateButton = [manRadioButton!]
        manRadioButton?.alternateButton = [womanRadioButton!]
    }
    
    override func awakeFromNib() {
        self.view.layoutIfNeeded()
        
        womanRadioButton.selected = true
        manRadioButton.selected = false
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
}
