//
//  LoginViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 06/05/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userIDArr = ["gary", "michael", "ahmed", "clive", "tariq", "sanjiv", "testuser"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        emailTextField.text = "openreach@gmail.com"
//        passwordTextField.text = "test123"

        // Do any additional setup after loading the view.
    }
    
      @IBAction func loginAction(_ sender: UIButton?) {
        guard emailTextField.text != "" else {
          Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the user id.")
            return
        }
            
        guard passwordTextField.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the password.")
            return
        }
        
        if !userIDArr.contains(emailTextField.text!) {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the correct user id.")
            return
        }
        
        if passwordTextField.text != "openreach@123" {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the correct password.")
            return
        }
            
        var parameters = [String: AnyObject]()
        parameters["email"] = emailTextField.text as AnyObject?
        parameters["password"] = passwordTextField.text as AnyObject?
        
        Helper.sharedHelper.showGlobalHUD(title: "Logging in...", view: view)

        perform(#selector(login), with: nil, afterDelay: 2)

        
        //callApi(loginDict: parameters)
    }
    
    @objc func login() {
        Helper.sharedHelper.dismissHUD(view: self.view)

        self.goToHomeAction()
    }
    
    func callApi(loginDict: [String: AnyObject])
    {
        Helper.sharedHelper.showGlobalHUD(title: "Logging in...", view: view)
        
        PWebService.sharedWebService.webService(apiName: APIType.signInAccount, parameters: loginDict ) { (status, response, message) in
            
            Helper.sharedHelper.dismissHUD(view: self.view)
            
            if status == 100
            {
                if (APP_DELEGATE.fbUser == nil) {
                    userDefault.set(response!["email"], forKey: "email")
                    userDefault.set(loginDict, forKey: "loginDict")
                }
                self.goToHomeAction()
            }
            else
            {
                Helper.sharedHelper.ShowAlert(str: message! as NSString , viewcontroller: self)
            }
        }
    }
    
    func goToHomeAction() {
        let vc = UIStoryboard.storyboard(name: "Main").instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

    extension UIStoryboard {
        
        class func storyboard(name: String) -> UIStoryboard {
            return UIStoryboard(name: name, bundle: nil)
        }
    }

