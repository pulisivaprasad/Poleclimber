//
//  ViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 18/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var inspectionBtn: UIButton!
    @IBOutlet weak var createClime: UIButton!

    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.windows.first { $0.isKeyWindow }?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
              statusBar.backgroundColor = pAppStatusBarColor
            UIApplication.shared.windows.first { $0.isKeyWindow }?.addSubview(statusBar)
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = pAppStatusBarColor
        }
        
        connectionStatusLabel.text = "Status: No Product Connected"
        productLabel.text = "Product Information"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "DJI SDK Version: " + (appVersion ?? "")
    }
    
     override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.isNavigationBarHidden = true
       }
       
    @IBAction func inspectionBtnAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
               let viewController = sb.instantiateViewController(withIdentifier: "ObjectDetectionViewController") as! ObjectDetectionViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
        
}
