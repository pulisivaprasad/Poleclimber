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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
      @IBAction func loginAction(_ sender: UIButton?) {
    //        let vc = UIStoryboard.storyboard(name: "Main").instantiateViewController(withIdentifier: "EEPaymentOptionViewController") as! EEPaymentOptionViewController
    //        self.navigationController?.isNavigationBarHidden = false
    //        self.navigationController?.pushViewController(vc, animated: true)
    //        return
            if emailTextField.text == "" {
    //            emailInformationButton.isHidden = false
                return
            }
            
            if passwordTextField.text == "" {
                //passwordInformationButton.isHidden = false
                return
            }
            
        var parameters = [String: AnyObject]()
        parameters["email"] = emailTextField.text as AnyObject?
        parameters["password"] = passwordTextField.text as AnyObject?
        callApi(loginDict: parameters)
        
    }
    
    func callApi(loginDict: [String: AnyObject])
    {
        Helper.sharedHelper.showGlobalHUD(title: "Logging in...", view: view)
        
        PWebService.sharedWebService.webService(apiName: APIType.signInAccount, parameters: loginDict ) { (status, response, message) in
            
            Helper.sharedHelper.dismissHUD(view: self.view)
            
            if status == 100
            {
//                if (APP_DELEGATE.fbUser == nil) {
//                    userDefault.set(response!["email"], forKey: "email")
//                    userDefault.set(loginDict, forKey: "loginDict")
//                }
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

