//
//  DatabaseFlowViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 08/05/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class DatabaseFlowViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Database Flow"
    }
    
    @IBAction func internetOffAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalAlertwithMessage("Dear Pole tester, Please connect to internet to push data to cloud. You may not be able to take further images to test poles.")
    }

    @IBAction func progressAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalHUD(title: "Processing...", view: view)

        perform(#selector(progressActionShow), with: nil, afterDelay: 2)
    }
    
    @objc func progressActionShow() {
        Helper.sharedHelper.dismissHUD(view: self.view)

        Helper.sharedHelper.showGlobalAlertwithMessage("Database updation in progress, please wait!!!")
    }

    
    @IBAction func failAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalAlertwithMessage("Something going wrong...\nraise helpline ticket/call customer care.")
    }
    
    @IBAction func completedAction(sender: UIButton) {
        Helper.sharedHelper.showGlobalAlertwithMessage("App is ready to use.")
    }

}
