//
//  RadioButton.swift
//  bean_swift_w_sdk
//
//  Created by Gaby Ruiz-Funes on 11/13/17.
//  Copyright © 2017 joseph slater. All rights reserved.
//

import UIKit

class RadioButton: UIButton {
    var alternateButton:Array<RadioButton>?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
    }
    
    func unselectAlternateButtons(){
        if alternateButton != nil {
            self.isSelected = true
            
            for aButton:RadioButton in alternateButton! {
                aButton.isSelected = false
            }
        }else{
            toggleButton()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    func toggleButton(){
        self.isSelected = !isSelected
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                print("Selected!")
                //self.layer.borderColor = Color.turquoise.cgColor
            } else {
                //self.layer.borderColor = Color.grey_99.cgColor
            }
        }
    }
}
