//
//  PoleStatusView.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 15/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

protocol NavigationDelegate: class {
    func submitBtnAction(selectedReason: String)
}

class PoleStatusView: UIView {
    @IBOutlet weak var submitBtn: UIButton!
    weak var delegate : NavigationDelegate?
    @IBOutlet weak var reason1: UIButton!
    @IBOutlet weak var reason2: UIButton!
    @IBOutlet weak var reason3: UIButton!
    var selectedBtnText = ""
    

    @IBAction func closeBtnAction(_ sender: UIButton) {
        reason1.isSelected = false
        reason2.isSelected = false
        reason3.isSelected = false
        self.removeFromSuperview()
        
    }
    @IBAction func submitBtnAction(_ sender: UIButton) {
        delegate?.submitBtnAction(selectedReason: selectedBtnText)
    }
    
    @IBAction func stepBtnAction(_ sender: UIButton) {
        submitBtn.backgroundColor = UIColor.red
        submitBtn.isUserInteractionEnabled = true
        selectedBtnText = sender.titleLabel!.text ?? ""

        if sender.tag == 1 {
            reason1.isSelected = true
            reason2.isSelected = false
            reason3.isSelected = false
        }
        else if sender.tag == 2 {
            reason1.isSelected = false
            reason2.isSelected = true
            reason3.isSelected = false
        }
        else{
            reason1.isSelected = false
            reason2.isSelected = false
            reason3.isSelected = true
        }
    }
}
