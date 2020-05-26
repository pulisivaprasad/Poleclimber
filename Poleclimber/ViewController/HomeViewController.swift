//
//  HomeViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 18/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {
   
    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
     override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.isNavigationBarHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
       
    @IBAction func inspectionBtnAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
               let viewController = sb.instantiateViewController(withIdentifier: "ObjectDetectionViewController") as! ObjectDetectionViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
