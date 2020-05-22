//
//  MoreViewController.swift
//  Poleclimber
//
//  Created by Babu on 22/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
       self.title = "More"
       navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "HELP"
        }
        else if indexPath.row == 1 {
            cell?.textLabel?.text = "LEGAL AGREEMENT"
        }
        else if indexPath.row == 2 {
            cell?.textLabel?.text = "ABOUT"
            
        }

        return cell!

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: "MoreDetailedViewController") as! MoreDetailedViewController
        if (indexPath.row == 0)
        {
            viewController.title = "HELP"
        }
        else if (indexPath.row == 1)
        {
            viewController.title = "LEGAL AGREEMENT"
        }
        else
        {
            viewController.title = "ABOUT"
        }
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    

}
