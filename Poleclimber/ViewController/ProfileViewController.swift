//
//  ProfileViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 30/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var valueSwitch : UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
       self.title = "Profile"
       navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0)
        {
            return 2;
        }
        else
        {
            return 3;
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                
        if indexPath.section == 0
        {
            if indexPath.row == 0  {
                cell?.textLabel?.text = "Username"
                cell?.detailTextLabel?.text = userDefault.object(forKey:"USERNAME") as? String
            }
            else if indexPath.row == 1 {
                cell?.textLabel?.text = "Email"
                cell?.detailTextLabel?.text = PWebService.sharedWebService.currentUser?.email
            }
            //        else if indexPath.row == 3 {
            //            cell?.textLabel?.text = "Data flow"
            //            cell?.detailTextLabel?.text = ""
            //        }
            
        }
        else
        {
            if indexPath.row == 0  {
                cell?.textLabel?.text = "Maximum load count"
                cell?.detailTextLabel?.text = "100"
            }
            else if indexPath.row == 1 {
                cell?.textLabel?.text = "Mobile data usage"
//
//                valueSwitch!.isOn = false
//                valueSwitch!.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
                cell?.detailTextLabel?.text = "YES"
              //  cell?.accessoryView = valueSwitch
            }
            else if indexPath.row == 2 {
                cell?.textLabel?.text = "Enable ID"
                cell?.detailTextLabel?.text = "NO"
            }
        }
        
        cell?.imageView?.tintColor = UIColor.black

        return cell!

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let label = UILabel(frame: CGRect.init(x: 0, y: 10, width: tableView.frame.size.width, height: 30))
        if (section == 0)
        {
            label.text = "SECTION A"
        }
        else
        {
            label.text = "SETTINGS"
        }
        label.font = UIFont(name:"HelveticaNeue-Italic", size: 17.0)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.section == 0)
        {
             return 44
        }
        
        return 50;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3  {
            let sb = UIStoryboard(name: "Main", bundle: nil)
                   let viewController = sb.instantiateViewController(withIdentifier: "DatabaseFlowViewController") as! DatabaseFlowViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func logoutBtnAction(sender: UIButton) {
        let alert = UIAlertController.init(title: "Do you really want to logout?", message: "", preferredStyle: .alert)
                    
                    let yesAction = UIAlertAction.init(title: "Yes", style: .default, handler: { (alert) in
                        
                        userDefault.removeObject(forKey: "loginDict")
                        userDefault.removeObject(forKey: "email")
                       // try! Auth.auth().signOut()
                        
                        self.dismiss(animated: true, completion: nil)

                         let mainStoryboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
                                       
                        let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                       //            centerViewController.identifier = "yes"
                        let centerNav = UINavigationController(rootViewController: centerViewController)
                        centerNav.isNavigationBarHidden = true
                                       
                        self.view.window?.rootViewController = centerNav
                    })
                    
                    let noAction = UIAlertAction.init(title: "No", style: .default, handler: { (alert) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    })
                 
                    alert.addAction(yesAction)
                    alert.addAction(noAction)

                    self.present(alert, animated: true, completion: nil)
    }

}
