//
//  SignUpViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 07/05/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    @IBAction func loginAction(_ sender: UIButton?) {
//        var parameters = [String: AnyObject]()
//        parameters["email"] = emailTextField.text as AnyObject?
//        parameters["password"] = passwordTextField.text as AnyObject?
//
//        
//                 Helper.sharedHelper.showGlobalHUD(title: "Registering...", view: view)
//                       
//                       PWebService.sharedWebService.webService(apiName: APIType.signUpAccount, parameters: parameters as! [String : AnyObject]) { (status, response, message) in
//                           
//                           Helper.sharedHelper.dismissHUD(view: self.view)
//                           
//                           if status == 100
//                           {
////                               if (APP_DELEGATE.fbUser == nil) {
////                                   userDefault.set(response!["email"], forKey: "email")
////                                   userDefault.set(self.signUpDict, forKey: "loginDict")
////                               }
//               //                Auth.auth().currentUser?.sendEmailVerification { (error) in
//               //                }
//                               
//                               let vc = UIStoryboard.storyboard(name: "Main").instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
//
//                               self.navigationController?.pushViewController(vc, animated: true)
//                           }
//                           else {
//                               Helper.sharedHelper.ShowAlert(str: message! as NSString , viewcontroller: self)
//                           }
//                           
//                       }
//           }
//    

}
