//
//  PoleStatusView.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 15/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class PoleStatusView: UIView {

    @IBAction func closeBtnAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func stepBtnAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        }
        else{
            sender.isSelected = true
        }
    }
}
