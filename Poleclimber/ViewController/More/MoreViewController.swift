//
//  MoreViewController.swift
//  Poleclimber
//
//  Created by Babu on 22/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

@available(iOS 13.0, *)
@available(iOS 13.0, *)
class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
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
            cell?.imageView?.image = UIImage(systemName: "questionmark.circle")
        }
        else if indexPath.row == 1 {
            cell?.textLabel?.text = "LEGAL AGREEMENT"
            cell?.imageView?.image = UIImage(systemName: "square.and.pencil")
        }
        else if indexPath.row == 5 {
            cell?.textLabel?.text = "FEEDBACK"
            cell?.imageView?.image = UIImage(systemName: "envelope")
        }
        else if indexPath.row == 2 {
            cell?.textLabel?.text = "ABOUT US"
            cell?.imageView?.image = UIImage(systemName: "person")
        }
        
        cell?.imageView?.tintColor = UIColor.black
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: "MoreDetailedViewController") as! MoreDetailedViewController
        if (indexPath.row == 0)
        {
            viewController.title = "HELP"

            //Need to update our dedicated HELP url
            let urlVal = URL(string: "https://www.openreach.com/help-and-support") as Optional
            let vc = SFSafariViewController(url: urlVal!)
            present(vc, animated: true)
        }
        else if (indexPath.row == 1)
        {
            viewController.title = "LEGAL AGREEMENT"
        }
        else if (indexPath.row == 5)
        {
            viewController.title = "FEEDBACK"
            
            if MFMailComposeViewController.canSendMail() {
                
                //Do nothing here
                
            } else {
                // show failure alert
                let alert = UIAlertController(title: "Alert", message: "Simulator is not supported.Please try it on real device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                    @unknown default: break
                    }}))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        else if (indexPath.row == 2)
        {
            viewController.title = "ABOUT US"
        }
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    

}

