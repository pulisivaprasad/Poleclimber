//
//  ProfileViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 30/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
       self.title = "Profile"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Username"
            cell?.detailTextLabel?.text = PWebService.sharedWebService.currentUser?.first_name
        }
        else if indexPath.row == 1 {
            cell?.textLabel?.text = "Email"
            cell?.detailTextLabel?.text = PWebService.sharedWebService.currentUser?.email
        }
        else if indexPath.row == 2 {
            cell?.textLabel?.text = "Version"
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            cell?.detailTextLabel?.text = appVersion
        }
        
        return cell!

    }
    
    @IBAction func logoutBtnAction(sender: UIButton) {
        let alert = UIAlertController.init(title: "Do you really want to logout?", message: "", preferredStyle: .alert)
                    
                    let yesAction = UIAlertAction.init(title: "Yes", style: .default, handler: { (alert) in
                        
                        userDefault.removeObject(forKey: "loginDict")
                        userDefault.removeObject(forKey: "email")
                        try! Auth.auth().signOut()
                        
                        self.dismiss(animated: true, completion: nil)

                        self.navigationController?.popToRootViewController(animated: true)

                    })
                    
                    let noAction = UIAlertAction.init(title: "No", style: .default, handler: { (alert) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    })
                 
                    alert.addAction(yesAction)
                    alert.addAction(noAction)

                    self.present(alert, animated: true, completion: nil)
    }

}
