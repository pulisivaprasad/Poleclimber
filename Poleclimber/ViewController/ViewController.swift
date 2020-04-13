//
//  ViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 18/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.windows.first { $0.isKeyWindow }?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
              statusBar.backgroundColor = pAppStatusBarColor
            UIApplication.shared.windows.first { $0.isKeyWindow }?.addSubview(statusBar)
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = pAppStatusBarColor
        }
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
