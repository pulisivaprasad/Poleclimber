//
//  TabBarViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 30/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}
