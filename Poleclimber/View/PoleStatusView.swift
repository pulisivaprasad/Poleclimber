//
//  PoleStatusView.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 15/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

protocol NavigationDelegate: class {
func submitBtnAction()
}

class PoleStatusView: UIView {
    @IBOutlet weak var closeBtn: UIButton!
   weak var delegate : NavigationDelegate?
    

    @IBAction func closeBtnAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Submit" {
            delegate?.submitBtnAction()
        }
        else{
            self.removeFromSuperview()
        }
    }
    
    @IBAction func stepBtnAction(_ sender: UIButton) {
        closeBtn.setTitle("Submit", for: .normal)
        if sender.isSelected {
            sender.isSelected = false
        }
        else{
            sender.isSelected = true
        }
    }
}
